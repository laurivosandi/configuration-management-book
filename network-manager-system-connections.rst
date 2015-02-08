.. date: 2014-05-11

NetworkManager system connections
=================================

In larger setups it makes sense to distribute
your Debian/Ubuntu machines' wireless networks configuration via Puppet or other
configuration management utilities.
What you probably try to do first is to attempt
find already wireless network configuration file on your
laptop ant try to distribute that.
NetworkManager places all it's configurations
under /etc/NetworkManager/system-connections
directory.
My initial network configuration in /etc/NetworkManager/system-connections/bootcamp looked like this:

.. code:: ini

    [connection]
    id=bootcamp
    uuid=35e9aca5-27fb-495b-b230-acb5eac840ba
    type=802-11-wireless
    permissions=user:lauri:;

    [802-11-wireless]
    ssid=bootcamp
    mode=infrastructure
    security=802-11-wireless-security

    [802-11-wireless-security]
    key-mgmt=wpa-psk
    auth-alg=open
    psk-flags=1

    [ipv4]
    method=auto

    [ipv6]
    method=auto
    ip6-privacy=2

Note that /etc/NetworkManager/system-connections and it's files are 
accessible only by root and that's the way it should remain.
You notice that there is permissions=user:lauri:; this means 
this particular connection is owned by user named *lauri* and
not available for other users.
To make the connection available for all users on the system
remove that line.

There is also psk-flags=1 which means that NetworkManager won't store
the secret (WPA2 pre-shared key) for this wireless network.
Instead that task is delegated to the nm-applet which in turn uses
GNOME keyring daemon to fetch the secrets from user's wallet.
This way the secrets are stored in the user's home directory in an 
encrypted fashion assuming the uses sets the passphrase for his wallet properly.
To store the secret in the NetworkManager configuration you need to
add psk=secret to the configuration AND remove the psk-flags=1 line.

My final configuration which I am distributing from my Puppet looks like this:

.. code:: ini

    [connection]
    id=bootcamp
    uuid=35e9aca5-27fb-495b-b230-acb5eac840ba
    type=802-11-wireless

    [802-11-wireless]
    ssid=bootcamp
    mode=infrastructure
    security=802-11-wireless-security

    [802-11-wireless-security]
    key-mgmt=wpa-psk
    auth-alg=open
    psk=salakala

    [ipv4]
    method=auto

    [ipv6]
    method=auto
    ip6-privacy=2
    
The configuration in Puppet looks also pretty straightforward:

.. code:: ruby

    file { "/etc/NetworkManager/system-connections":
        ensure => directory,
        recurse => true,
        mode => 700,
        owner => root,
        group => root,
        source => "puppet:///modules/lauri-koodur/koodur-workstation/etc/NetworkManager/system-connections"
    }

Of course you might find Puppet modules which would achieve similar purpose,
however I didn't find any which have clear configuration options for system-wide
connections.
