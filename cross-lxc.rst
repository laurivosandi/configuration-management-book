.. tags: LXC
.. flags: hidden

Building cross-platform templates using LXC
===========================================

Introduction
------------

LXC works very well for same platform.
Building armhf container on top of amd64 host is a bit trickier.
You may ask what would be the usecases for such scenario?
I see two main usecases for running emulated foreign architecture containers:
cross-compiling software for different target and preparing root filesystem to be deployed.

Emulating foreign architecture
------------------------------

First you need to install QEMU emulation binaries:

.. code:: bash

    apt-get install qemu-user-static


Building container
------------------
    
LXC guys are already putting a lot of effort into making it possible to set up cross platform containers.
So at first you might want to try to do something like this:

.. code:: bash

    lxc-create -n utopic-cubietruck-template -t ubuntu -- --release utopic --arch armhf

This will essentially debootstrap foreign architecture,
copy QEMU userspace emulation binaries from the package mentioned above,
proceed with second stage bootstrap and
install amd64 versions ureadahead, plymouth, upstart, mountall packages
which are troublesome to be emulated.

As an alternative you may want to download prebuilt images from linuxcontainers.org,
however in this case you have to copy the QEMU userspace emulation binaries manually:

.. code:: bash

    lxc-create -n utopic-cubietruck-template -t download -- --dist ubuntu --release utopic --arch armhf
    cp /usr/bin/qemu-arm-static /var/lib/lxc/utopic-cubietruck-template/rootfs/usr/bin/
    
With Ubuntu 12.04 armhf container it seems to work more or less,
with later Ubuntu releases there are several bugs present.
Due to those bugs it seems to be impossible to install packages such as dbus, atd
and pretty much anything that attempts to reload services.


Binding mount points
--------------------

I like to bind APT packages cache from the host so the packages are not downloaded
again for some other container.
I also bind Puppet profile from my puppet server so I can easily apply Puppet profile
inside the container without hooking the template to actual Puppet server instance.
Place following to /var/lib/lxc/utopic-cubietruck-template/fstab:

.. code:: bash

    /var/cache/apt/archives /var/lib/lxc/utopic-cubietruck-template/rootfs/var/cache/apt/archives none bind
    /var/lib/lxc/puppet/rootfs/etc/puppet/ /var/lib/lxc/utopic-cubietruck-template/rootfs/etc/puppet/ none bind

    mkdir -p /var/lib/lxc/utopic-cubietruck-template/rootfs/etc/puppet/ 

    puppet apply /etc/puppet/manifests/site.pp  --modulepath /etc/puppet/modules/ --debug

Disabling services
------------------

Inside the container disable re-loading services by creating file /usr/sbin/policy-rc.d:

.. code:: bash

    echo -en '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d
    chmod +x /usr/sbin/policy-rc.d    


    
This should avoid reloading packages which may block installing oter packages.
    
.. [policy-rc.d]  http://ubuntuforums.org/showthread.php?t=856815
