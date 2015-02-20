.. title: Configuring fingerprint reader in Ubuntu 13.04
.. date: 2013-04-25 15:13:31
.. author: Lauri Võsandi <lauri.vosandi@gmail.com>
.. tags: Ubuntu, PAM

Configuring fingerprint reader in Ubuntu 13.04
==============================================

Compared to Ubuntu 11.10, this is much-much easier. Just install PAM fingerprint module:

.. code:: bash

    sudo apt-get install libpam-fprintd

No need to run pam-auth-update anymore, because fingerprint login is enabled immideately after the module is installed.

Final step is to enroll your fingerprints:

.. code:: bash

    fprintd-enroll


