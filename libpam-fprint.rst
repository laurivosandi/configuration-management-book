.. title: Configuring fingerprint reader for Ubuntu 11.10
.. date: 2011-10-30 19:05:44
.. author: Lauri Võsandi <lauri.vosandi@gmail.com>
.. tags: Ubuntu, PAM

Configuring fingerprint reader for Ubuntu 11.10
===============================================

Here's another hopefully useful how-to for getting Thinkpad T420 fingerprint reader running under Ubuntu 11.10:

Install required packages:

.. code:: bash

    sudo apt-get install fprint-demo libpam-fprint

Add udev rule for setting the group ownership of fingerprint reader device:

.. code:: bash

    echo "ATTRS{idVendor}==\"147e\", ATTRS{idProduct}==\"2016\", MODE=\"0664\", GROUP=\"fingerprint\"" \
        | sudo tee /etc/udev/rules.d/99-fingerprint.rules

Create group and add user to that group:

.. code:: bash

    sudo groupadd fingerprint
    sudo gpasswd -a lauri fingerprint

Reconfigure PAM and enable "Fingerprint reader":

.. code:: bash

    pam-auth-update

**Reboot the machine so the udev would create the fingerprint reader device node with proper permissions**. At the moment I am not familiar how to force udev to recreate the node and unplugging the fingerprint reader is not "feasible".

Finally scan your fingerprints:

.. code:: bash

    fprint_demo

Both, authentication in the login manager and sudo, should work with fingerprints now!
