.. date: 2014-10-06
.. tags: tallinx
.. redirect_from: /2014/10/tallinna-piloodiga-liitumine.html

Tallinna koolide Linuxeerimise piloodiga liitumine
==================================================

Esiteks paigalda arvutisse Lubuntu 14.04 [#lubuntu]_ nii et /home oleks eraldi partitsioonil,
ehk siis umbkaudu 20GB juurfailisüsteemi jaoks ning ülejäänud ruum /home jaoks.
Saaleala (swap) võib keelata kui masinas on 4GB või rohkem operatiivmälu.

Tee kindlaks, et su DHCP server pakub masinatele korrektset domeeni suffiksit.
Ehk siis näiteks Mustamäe Gümnaasiumi puhul peaks täielik masinanimi olema
blah.mg.edu.ee. Kui domeeni suffiksit pole võimalik seadistada, a'la Atea võrgus
siis pange masina paigaldamise ajal masina nimele vastav prefiks, a'la
mg-blah1.edu.ee. Nii saame masinaid mõistlikul moel filtreerida Foremani vaadetes.

Täieliku masinanime saad kontrollida nii:

.. code:: bash

    hostname --fqdn

Masinanime saad muuta modifitseerides /etc/hostname faili, seal peaks olema
masinanimi ilma domeeni suffiksita. Peale selle muutmist võiks masina taaskäivitada.
    
Puppeti paigaldus
-----------------

Kui masin on paigaldatud siis võib jätakata Puppeti paigaldusega:

.. code:: bash

    sudo apt-get install puppet
    
Seadista puppet viitama meie serveri pihta failis /etc/puppet/puppet.conf:

.. code:: ini

    [main]
    logdir=/var/log/puppet
    vardir=/var/lib/puppet
    ssldir=/var/lib/puppet/ssl
    rundir=/var/run/puppet
    factpath=$vardir/lib/facter
    templatedir=$confdir/templates
    prerun_command=/etc/puppet/etckeeper-commit-pre
    postrun_command=/etc/puppet/etckeeper-commit-post
    server = puppet.povi.ee

    [master]
    ssl_client_header = SSL_CLIENT_S_DN 
    ssl_client_verify_header = SSL_CLIENT_VERIFY

    [agent]
    report = true
    waitforcert = 120
    runinterval = 1800

Igaks juhuks kontrolli üle, et Puppet ei oleks keelatud:

.. code:: bash

    sudo puppet agent --enable

Taaskäivita Puppeti agent:

.. code:: bash

    sudo /etc/init.d/puppet restart

Kui kõik masinad on paigaldatud saada `mulle  <mailto:lauri.vosandi@gmail.com>`_:

* Masinate nimekiri mis ma peaks Puppetis heaks kiitma.
* Mis lisaseadmed on ühendatud USB kaudu
* Mis printerid peaks ühendama üle võrgu ning mis võrguseaded neil on

.. [#lubuntu] http://cdimage.ubuntu.com/lubuntu/releases/14.04.1/release/lubuntu-14.04.1-desktop-i386.iso
