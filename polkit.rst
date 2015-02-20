.. title: Polkit
.. date: 2014-05-29
.. tags: polkit, NetworkManager, udisks, DBus, private

Polkit
======

Introduction
------------

I think I've barely scratched the surface of what can be done
using `Polkit <http://www.freedesktop.org/wiki/Software/polkit/>`_ but
I thought I'd be a good idea to give a short introduction here and also
have it as a reminder for myself in the future.

Polkit (*policy toolkit?*) allows configuring various permissions in a more
fine grained manner on a Linux based desktop.
Technically speaking Polkit allows unprivileged applications to speak to
privileged processes.

Two most common use cases on Ubuntu Desktop involve configuring network wireless
networks and mounting filesystems on internal disks,
which incidently also applies to disks hooked up via eSATA port.

AdminIdentities
---------------

In case of Ubuntu polkit requires the current user to be in *admin* group
previously mentioned actions. In polkit terminology these are also known as
administrator identities:

.. code::

    localhost ~ $ grep -r AdminIdentities /etc/polkit-1/
    /etc/polkit-1/localauthority.conf.d/50-localauthority.conf:AdminIdentities=unix-user:0
    /etc/polkit-1/localauthority.conf.d/51-ubuntu-admin.conf:AdminIdentities=unix-group:sudo;unix-group:admin

On Debian *sudo* group replaces *admin* group:

.. code::

    localhost ~ $ grep -r AdminIdentities /etc/polkit-1/
    /etc/polkit-1/localauthority.conf.d/50-localauthority.conf:AdminIdentities=unix-user:0
    /etc/polkit-1/localauthority.conf.d/51-debian-sudo.conf:AdminIdentities=unix-group:sudo
    
As you probably noticed *user-user:0* refers to *root* and naturally root
has permissions to do anything.

.. comment: polkit.subject-pid: 4238
.. comment: polkit.caller-pid: 4245
.. comment: Action: org.freedesktop.udisks.filesystem-mount-system-internal
.. comment: Vendor: The udisks Project

Policies
--------

The default policies are stored under /usr/share/polkit-1/actions/,
for instance NetworkManager's default policy sans translations in
/usr/share/polkit-1/actions/org.freedesktop.NetworkManager.policy is following:

.. code:: xml

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE policyconfig PUBLIC
     "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
     "http://www.freedesktop.org/standards/PolicyKit/1.0/policyconfig.dtd">
    <policyconfig>

      <vendor>NetworkManager</vendor>
      <vendor_url>http://www.gnome.org/projects/NetworkManager</vendor_url>
      <icon_name>nm-icon</icon_name>

      <action id="org.freedesktop.NetworkManager.enable-disable-network">
        <description>Enable or disable system networking</description>
        <message>System policy prevents enabling or disabling system networking</message>
        <defaults>
          <allow_inactive>no</allow_inactive>
          <allow_active>yes</allow_active>
        </defaults>
      </action>

      <action id="org.freedesktop.NetworkManager.sleep-wake">
        <description>Put NetworkManager to sleep or wake it up (should only be used by system power management)</description>
        <message>System policy prevents putting NetworkManager to sleep or waking it up</message>
        <defaults>
          <allow_inactive>no</allow_inactive>
          <allow_active>no</allow_active>
        </defaults>
      </action>

      <action id="org.freedesktop.NetworkManager.enable-disable-wifi">
        <description>Enable or disable WiFi devices</description>
        <message>System policy prevents enabling or disabling WiFi devices</message>
        <defaults>
          <allow_inactive>no</allow_inactive>
          <allow_active>yes</allow_active>
        </defaults>
      </action>

      <action id="org.freedesktop.NetworkManager.enable-disable-wwan">
        <description>Enable or disable mobile broadband devices</description>
        <message>System policy prevents enabling or disabling mobile broadband devices</message>
        <defaults>
          <allow_inactive>no</allow_inactive>
          <allow_active>yes</allow_active>
        </defaults>
      </action>

      <action id="org.freedesktop.NetworkManager.enable-disable-wimax">
        <description>Enable or disable WiMAX mobile broadband devices</description>
        <message>System policy prevents enabling or disabling WiMAX mobile broadband devices</message>
        <defaults>
          <allow_inactive>no</allow_inactive>
          <allow_active>yes</allow_active>
        </defaults>
      </action>

      <action id="org.freedesktop.NetworkManager.network-control">
        <description>Allow control of network connections</description>
        <message>System policy prevents control of network connections</message>
        <defaults>
          <allow_inactive>yes</allow_inactive>
          <allow_active>yes</allow_active>
        </defaults>
      </action>

      <action id="org.freedesktop.NetworkManager.wifi.share.protected">
        <description>Connection sharing via a protected WiFi network</description>
        <message>System policy prevents sharing connections via a protected WiFi network</message>
        <defaults>
          <allow_inactive>no</allow_inactive>
          <allow_active>yes</allow_active>
        </defaults>
      </action>

      <action id="org.freedesktop.NetworkManager.wifi.share.open">
        <description>Connection sharing via an open WiFi network</description>
        <message>System policy prevents sharing connections via an open WiFi network</message>
        <defaults>
          <allow_inactive>no</allow_inactive>
          <allow_active>yes</allow_active>
        </defaults>
      </action>

      <action id="org.freedesktop.NetworkManager.settings.modify.own">
        <description>Modify personal network connections</description>
        <message>System policy prevents modification of personal network settings</message>
        <defaults>
          <allow_inactive>no</allow_inactive>
          <allow_active>yes</allow_active>
        </defaults>
      </action>

      <action id="org.freedesktop.NetworkManager.settings.modify.system">
        <description>Modify network connections for all users</description>
        <message>System policy prevents modification of network settings for all users</message>
        <defaults>
          <allow_inactive>no</allow_inactive>
          <allow_active>auth_admin_keep</allow_active>
        </defaults>
      </action>

      <action id="org.freedesktop.NetworkManager.settings.modify.hostname">
        <description>Modify persistent system hostname</description>
        <message>System policy prevents modification of the persistent system hostname</message>
        <defaults>
          <allow_inactive>no</allow_inactive>
          <allow_active>auth_admin_keep</allow_active>
        </defaults>
      </action>

    </policyconfig>
    
Note that there are two actions which require user to be in admin group:

* org.freedesktop.NetworkManager.settings.modify.system
* org.freedesktop.NetworkManager.settings.modify.hostname

This is default configuration of Ubuntu and it should work for most usecases.

Overriding default behaviour
----------------------------

In some cases you might want to give permission to certain user(s) or group(s).
For instance to grant user *lauri* permission to mount internal filesystems
you can place following in /etc/polkit-1/localauthority.conf.d/50-internal-storage.pkla

.. code:: ini

    [Storage Permissions]
    Identity=unix-user:lauri;
    Action=org.freedesktop.udisks.filesystem-mount;org.freedesktop.udisks.filesystem-mount-system-internal;org.freedesktop.udisks.filesystem-mount-system-external
    ResultAny=yes
    ResultInactive=yes
    ResultActive=yes

Note that in this case *udisks* is the privileged process which takes
care of mounting various filesystems.


   
    
