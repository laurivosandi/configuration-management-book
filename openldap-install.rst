.. title: OpenLDAP serveri paigaldus
.. author: Lauri Võsandi <lauri.vosandi@gmail.com>
.. tags: OpenLDAP, 389

OpenLDAP serveri paigaldus
==========================

Sissejuhatus
------------

Liikvel on peamiselt kaks avatud lähtekoodiga LDAP serverit, mis
**mõlemad** on pärit Michigani ülikoolist ning baseeruvad samal koodibaasil:

* `OpenLDAP <http://www.openldap.org/>`_
* `389 <http://directory.fedoraproject.org/>`_ tuntud ka kui Fedora
  Directory Server

Ubuntus on mõlemad olemas. Debiani 389 on veel testimisfaasis, seega *wheezy*
väljalaskest seda ei leia.
Eesti ID-kaardi jaoks leiab hunniku
`Pythoni skripte <https://github.com/martinpaljak/python-esteid/>`_
mis saab paigaldada lihtsa *pip* *install* *python-esteid* käsuga ning mille abil saab:

* Importida ldap.sk.ee serverist sertifikaate isikukoodi järgi
* Küsida kas mõni sertifikaat kehtib

Sertifikaadist saab välja lõigata:

* Eesnime
* Perekonnanime
* Sünnikuupäeva
* Dokumendi koodi

Paigaldus
---------

Kõigepealt tuleks seadistada domeeninimeta masinanimi failis */etc/hostname*:

.. code:: bash

    echo "ldap" > /etc/hostname
    
Seejärel lisada */etc/hosts* faili vastavad kirjed sellises järjekorras
et täielik masinanimi (*fully qualified domain name*) on esimene:

.. code::

    127.0.0.1 ldap.povi.ee ldap localhost

    ::1		localhost ip6-localhost ip6-loopback
    fe00::0		ip6-localnet
    ff00::0		ip6-mcastprefix
    ff02::1		ip6-allnodes
    ff02::2		ip6-allrouters
    
Järgnevalt võib üle kontrollida kas nimelahendus toimib:

.. code:: bash

    hostname          # Peaks tagastama ldap
    hostname --fqdn   # Peaks tagastama ldap.povi.ee
    
Lisaks peab nimeserver õige vastuse andma päringu pihta:

.. code:: bash

    host ldap.koodur.com # Peaks tagastama ldap.povi.ee has address x.x.x.x

Ubuntus ning Debianis saame alustada tarkvarapaketi paigaldusega:

.. code:: bash

    apt-get install slapd ldap-utils
    
Paigalduse käigus küsitakse administraatori jaoks parooli,
see on OpenLDAP serverisse loodava *admin* kasutaja parool.



OpenLDAP seadistamine
---------------------
    
OpenLDAP on alates versioonist 2.4 üle läinud andmebaasipõhisele konfiguratsioonile,
mis tähendab seda et LDAP serveri seadistamine käib LDAP klientrakenduse kaudu [#cn_config]_.
Mulle meeldib rakendusi seadistada tekstifailide kaudu nii nagu Linuxilistes
kombeks ja Debian Wheezys sisalduv OpenLDAP seda veel õnneks toetab:

.. code:: bash

    sudo apt-get install slapd
    sudo /etc/init.d/slapd stop
    rm -Rf /etc/ldap/slap.d/
    
Loo konfiguratsioonifail /etc/ldap/slapd.conf:

.. code:: none

    #allow bind_v2
    include         /etc/ldap/schema/core.schema
    include         /etc/ldap/schema/cosine.schema
    include         /etc/ldap/schema/inetorgperson.schema
    include         /etc/ldap/schema/openldap.schema
    include         /etc/ldap/schema/nis.schema
    include         /etc/ldap/schema/misc.schema
    include         /etc/ldap/schema/openssh-lpk.schema
    include         /etc/ldap/schema/extra.schema
    pidfile         /var/run/slapd/slapd.pid
    argsfile        /var/run/slapd/slapd.args
    loglevel        none
    modulepath	/usr/lib/ldap
    moduleload	back_hdb
    sizelimit 500
    tool-threads 1
    backend		hdb
    database        hdb
    suffix          "dc=koodur,dc=com"
    rootdn          "cn=root,dc=koodur,dc=com"
    rootpw          "salakala"
    directory       "/var/lib/ldap"
    dbconfig set_cachesize 0 2097152 0
    dbconfig set_lk_max_objects 1500
    dbconfig set_lk_max_locks 1500
    dbconfig set_lk_max_lockers 1500
    index           objectClass eq
    lastmod         on
    checkpoint      512 30

    access to attrs=userPassword,shadowLastChange
            by dn="cn=root,dc=koodur,dc=com" write
            by anonymous auth
            by self write
            by * none

    access to dn.base="" by * read

    access to *
            by dn="cn=root,dc=koodur,dc=com" write
            by * read

    TLSCACertificateFile /etc/ldap/root.crt
    TLSCertificateFile /etc/ldap/ldap.crt
    TLSCertificateKeyFile /etc/ldap/ldap.key

Mina lisasin andmebaasi schema SSH võtmete hoiustamiseks faili /etc/ldap/schema/openssh-lpk.schema, ülal konfiguratsioonis on juba sellele viidatud:

.. code:: none

    #
    # LDAP Public Key Patch schema for use with openssh-ldappubkey
    # Author: Eric AUGE <eau@phear.org>
    # 
    # Based on the proposal of : Mark Ruijter
    #

    attributetype ( 1.3.6.1.4.1.24552.500.1.1.1.13
        NAME 'sshPublicKey' 
	    DESC 'MANDATORY: OpenSSH Public key' 
	    EQUALITY octetStringMatch
	    SYNTAX 1.3.6.1.4.1.1466.115.121.1.40)

    objectclass ( 1.3.6.1.4.1.24552.500.1.1.2.0
        NAME 'ldapPublicKey'
        SUP top AUXILIARY
	    DESC 'MANDATORY: OpenSSH LPK objectclass'
	    MAY ( sshPublicKey $ uid ) )

Lisaks paigaldasin ka ldap2rest jaoks täiendavate attribuutidega schema faili /etc/ldap/schema/extra.schema:

.. code:: ldif
	    
    attributetype ( 1.3.6.1.4.1.4203.666.1.91
            NAME 'recoveryEmail'
            EQUALITY caseIgnoreMatch
            SUBSTR caseIgnoreSubstringsMatch
            SYNTAX 1.3.6.1.4.1.1466.115.121.1.15{1024} )

    attributetype ( 1.3.6.1.4.1.4203.666.1.92
            NAME 'esteid'
            SYNTAX 1.3.6.1.4.1.1466.115.121.1.15{11} )

    attributetype ( 1.3.6.1.4.1.4203.666.1.93
            NAME 'gender'
            EQUALITY caseIgnoreMatch
            SUBSTR caseIgnoreSubstringsMatch
            SYNTAX 1.3.6.1.4.1.1466.115.121.1.15{1024} )

    attributetype ( 1.3.6.1.4.1.4203.666.1.95
            NAME 'dateOfBirth'
            SUP name )

    objectClass     ( 1.3.6.1.4.1.4203.666.1.100
        NAME 'esteidAccount'
            DESC 'Extra attributes'
        SUP top
        AUXILIARY
            MAY  ( esteid $ recoveryEmail $ dateOfBirth $ gender )
        )

	    
TLS võtmete loomine
-------------------

Ilma TLS-ita on üsna võimatu modernset LDAP lahendust käima saada, 
näiteks sssd [#sssd]_ ei võimaldagi autentida ilma TLS-ita.
Selleks loo võtmed LDAP serverile:

.. code:: bash

    # Loo CA, seda võiks teha mõnes isoleeritud masinas kust root.key rändama ei läheks
    openssl req -days 3650 -nodes -new -x509 -keyout /etc/ldap/root.key -out /etc/ldap/root.crt
    
    # Loo CSR
    openssl req -days 3650 -nodes -new -keyout /etc/ldap/ldap.key -out /etc/ldap/ldap.csr
    
    # Signeeri CSR
    openssl x509 -req -days 3650 -in /etc/ldap/ldap.csr -out /etc/ldap/ldap.crt -CA /etc/ldap/root.crt -CAkey /etc/ldap/root.key -CAcreateserial
    

Vana andmebaasi import
----------------------

Kui sul on andmed juba mõnest LDAP serverist importida vaja siis slapcat abil saab
nad LDIF faili salvestada [#recovery]_:

.. code:: bash

    slapcat -v -l dump.ldif

Eeldusel et nüüdseks on kõik vajalikud schemad kirjeldatud OpenLDAP konfiguratsioonis
võime proovida andmeid importida:

.. code:: bash

    /etc/init.d/slapd stop
    rm -Rf /var/lib/ldap/*
    slapadd -l dump.ldif
    chown -R openldap:openldap /var/lib/ldap/*
    /etc/init.d/slapd start


Testimine
---------

Kui OpenLDAP on paigaldatud võib alustada sellest, et küsida OpenLDAP serveris
kirjeid:

.. code:: bash

    ldapsearch "objectClass=*" -D "cn=admin,dc=ldap,dc=povi,dc=ee" -W
    
Väljapool LDAP serverit päringuid tehes tuleb *ldapsearch* käsule ette sööta ka masina aadress:

.. code:: bash

    ldapsearch "objectClass=*" -D "cn=admin,dc=ldap,dc=povi,dc=ee" -W -h ldap.povi.ee
    
OpenLDAP kontekstis nimetatakse kasutaja autentimist LDAP serveriga *bindimiseks*.
See tähendab et logides vastu vaatavad *Bind failed* veateated tähendavad seda,
et kasutaja/parool on valesti sisestatud:

.. code:: python

    import ldap
    try:
        l = ldap.open("ldap.povi.ee")
        l.protocol_version = ldap.VERSION3
        username = "cn=admin,dc=ldap,dc=povi,dc=ee"
        password = "verysecure"
        l.simple_bind(username, password) # This does not raise expection with wrong pass?!
        print "Bind successful"
    except ldap.LDAPError, e:
        print "Bind failed:", e


Käitamine:

.. code:: bash

    python test.py

Sama asja võiks igaks juhuks ka PHP-s ära katsetada:

.. code:: php

    <?php

    $ldaphost = "ldap.povi.ee";
    $ldapconn = ldap_connect($ldaphost);

    ldap_set_option($ldapconn, LDAP_OPT_PROTOCOL_VERSION, 3);
    ldap_set_option($ldapconn, LDAP_OPT_REFERRALS, 0);
    if ($ldapconn) {
        echo 'Connected <br/>';
        $userdn = "cn=admin,dc=ldap,dc=povi,dc=ee";
        $password = "verysecure";

        if ($bind = ldap_bind($ldapconn, $userdn, $password)) {
            echo "Bind successful\n";
        } else {
            echo "Bind failed\n";
        }
    }

    ?>

Käitamine:

.. code:: bash

    php test.php
    
    
.. [#sssd] https://fedorahosted.org/sssd/
.. [#revert_config] http://serverfault.com/questions/488810/switching-openldap-from-cn-config-to-slapd-conf
.. [#cn_config] http://www.zytrax.com/books/ldap/ch6/slapd-config.html
.. [#recovery] http://mindref.blogspot.se/2011/06/ldap-database-backup-restore.html
