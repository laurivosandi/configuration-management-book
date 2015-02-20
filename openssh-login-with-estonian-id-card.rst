.. title: OpenSSH sisselogimine ID-kaardi abil
.. date: 2014-04-19
.. tags: PKCS#11, OpenSSH, SmartCard

OpenSSH sisselogimine ID-kaardi abil
====================================

Sissejuhatus
------------

2007 aastast alates väljastatud ID-kaart sisaldab kahte 1024-bitist
RSA võtit mida saab avada vastavalt PIN1 ning PIN2 koodide abil.
2011 aastast alates hakati väljastama 2048-bitiste võtmetega ID-kaarte.
Neid võtmeid saab kasutada enda autentimiseks mitmetes võrguteenustes,
OpenSSH ei ole siinkohal erandiks.


Sertifikaadi hankimine kaardilt
-------------------------------

Selleks et sisse logida peab sihtmasinas olema ID-kaardi sertifikaat.
Kui kaart on käepärast siis sertifikaadi saab üsna hõlpsalt sellest välja võluda.
Esiteks kontrolli kas kasutuses on OpenSC 0.12.x või OpenSC 0.13.x:

.. code::

    localhost ~ $ opensc-tool -i
    opensc 0.12.2 [gcc  4.7.0]
    Enabled features: zlib readline openssl pcsc(libpcsclite.so.1)
    
Kui kasutuses on OpenSC 0.12.x siis saab kasutada onepin teeki mis alati tagastab
autentimise sertifikaadi:

.. code::

    localhost ~ $ ssh-keygen -D onepin-opensc-pkcs11.so 
    ssh-rsa AAAAB3NzaC1yc2EAAAAEIwDMvQAAAQEAp8DS83SccNQk/fasdERwW9tJjIlxYMMRu5cu
    90rHc6QlgpMg6GCctMHizHy8dEeWpFKmgZ4pgZFaEXa20ce3YvFwXsEGCOaqNk8EIsCrGiBKa9vl
    RqdXyDNkiIhgj4z+M+O/N3McRVEs8JAbY0AYqhFSLZZyuf6VytMc3O0hRZ02kv5EDqJo7vPinhQ9
    3uH+CocIop/jCdTma120ITwkAyMH2yBr3Gz6PcVX56C1RdYkyCYp/TNbwm3BVQAtQ/akG4MUcwX1
    Sq9WpjoGkapTcWbcZIydr8p9odpXOKQEvS3aZGAPVb0lqn7c4s4FD6RcZ2R4t2WZyBmBL2fMDR9e
    kQ==

OpenSC 0.13.0 versioonis eemaldati segastel põhjustel onepin moodul
ning standardne PKCS#11 teek tagastab nii autentimise kui allkirjastamise
sertifikaadi:

.. code::

    localhost ~ $ ssh-keygen -D opensc-pkcs11.so 
    ssh-rsa AAAAB3NzaC1yc2EAAAAEIwDMvQAAAQEAp8DS83SccNQk/fasdERwW9tJjIlxYMMRu5cu
    90rHc6QlgpMg6GCctMHizHy8dEeWpFKmgZ4pgZFaEXa20ce3YvFwXsEGCOaqNk8EIsCrGiBKa9vl
    RqdXyDNkiIhgj4z+M+O/N3McRVEs8JAbY0AYqhFSLZZyuf6VytMc3O0hRZ02kv5EDqJo7vPinhQ9
    3uH+CocIop/jCdTma120ITwkAyMH2yBr3Gz6PcVX56C1RdYkyCYp/TNbwm3BVQAtQ/akG4MUcwX1
    Sq9WpjoGkapTcWbcZIydr8p9odpXOKQEvS3aZGAPVb0lqn7c4s4FD6RcZ2R4t2WZyBmBL2fMDR9e
    kQ==
    ssh-rsa AAAAB3NzaC1yc2EAAAAEF70dVQAAAQEAv8MIa/OA4fjYaom31ChhY8zWrHgee5N7Gihp
    DvzR4GFML2W8rob5x+VZaXe4NbNi/tYkoB8JifsGgaOEXOVoHUUX2HGclKtPE7C8bf0fsiwDfh+7
    /gfZ4r/QdNMLxmWwxwo7Yd+b9Gxg6/utI0jTR6W5BMrCmxIuXBk/bA6ly7clCOsn56p4XEhsaI5n
    s3o8IhJpWhvw3p3s4cqLe/gUb4xtZmWTSeLIHSzr4WKR8TzqtjrGqSjFogdH08UGA/KsrDDS41LR
    crQiOVSqIopMVpgpRQF3zox3feAXAcQdYsVZ6GeXPMfqD8HqywKo94qjGmTiRN+wcMQyulOl6zqD
    5Q==
    
Sertifikaadi saab faili salvestada nii:

.. code:: bash

    ssh-keygen -D opensc-pkcs11.so | head -n 1 > 38810240348.pub
    
Sertifikaadi räsit saab kontrollida järgnevalt:

.. code::

    localhost ~ $ ssh-keygen -lf 38810240348.pub 
    2048 fc:06:ae:62:3d:d9:44:5d:99:92:ae:73:9f:ec:77:08 38810240348.pub (RSA)
    
Ning selle serverisse kopeerida:

.. code:: bash

    ssh-copy-id -i 38810240348 kasutaja@masin

Sertifikaadi hankimine Sertifitseerimiskeskuse LDAP-ist
-------------------------------------------------------

Sertifitseerimiskeskuse LDAP serverist (peaks!) saab alla laadida kõigi
kehtivate ID-kaartide ning Mobiil-ID sertifikaate isikukoodi järgi:

.. code::

    localhost ~ $ ldapsearch -x -h ldap.sk.ee -b c=EE "(serialNumber=38810240348)"
    # extended LDIF
    #
    # LDAPv3
    # base <c=EE> with scope subtree
    # filter: (serialNumber=38810240348)
    # requesting: ALL
    #

    # V\C3\95SANDI\2CLAURI\2C38810240348, authentication, ESTEID, EE
    dn:: Y249VsOVU0FORElcMkNMQVVSSVwyQzM4ODEwMjQwMzQ4LG91PWF1dGhlbnRpY2F0aW9uLG89R
     VNURUlELGM9RUU=
    cn:: VsOVU0FOREksTEFVUkksMzg4MTAyNDAzNDg=
    serialNumber: 38810240348
    userCertificate;binary:: MIIE2jCCA8KgAwIBAgIQOaLS5izHIURQUtLcYsRqkTANBgkqhkiG9
     w0BAQUFADBkMQswCQYDVQQGEwJFRTEiMCAGA1UECgwZQVMgU2VydGlmaXRzZWVyaW1pc2tlc2t1cz
     EXMBUGA1UEAwwORVNURUlELVNLIDIwMTExGDAWBgkqhkiG9w0BCQEWCXBraUBzay5lZTAeFw0xMjA
     5MTQwNjQ2NTJaFw0xNzA5MTMyMDU5NTlaMIGVMQswCQYDVQQGEwJFRTEPMA0GA1UECgwGRVNURUlE
     MRcwFQYDVQQLDA5hdXRoZW50aWNhdGlvbjEjMCEGA1UEAwwaVsOVU0FOREksTEFVUkksMzg4MTAyN
     DAzNDgxETAPBgNVBAQMCFbDlVNBTkRJMQ4wDAYDVQQqDAVMQVVSSTEUMBIGA1UEBRMLMzg4MTAyND
     AzNDgwggEjMA0GCSqGSIb3DQEBAQUAA4IBEAAwggELAoIBAQCnwNLzdJxw1CT99qx0RHBb20mMiXF
     gwxG7ly73SsdzpCWCkyDoYJy0weLMfLx0R5akUqaBnimBkVoRdrbRx7di8XBewQYI5qo2TwQiwKsa
     IEpr2+VGp1fIM2SIiGCPjP4z4783cxxFUSzwkBtjQBiqEVItlnK5/pXK0xzc7SFFnTaS/kQOomju8
     +KeFD3e4f4Khwiin+MJ1OZrXbQhPCQDIwfbIGvcbPo9xVfnoLVF1iTIJin9M1vCbcFVAC1D9qQbgx
     RzBfVKr1amOgaRqlNxZtxkjJ2vyn2h2lc4pAS9LdpkYA9VvSWqftzizgUPpFxnZHi3ZZnIGYEvZ8w
     NH16RAgQjAMy9o4IBUzCCAU8wCQYDVR0TBAIwADAOBgNVHQ8BAf8EBAMCBLAwUQYDVR0gBEowSDBG
     BgsrBgEEAc4fAQEDAzA3MBIGCCsGAQUFBwICMAYaBG5vbmUwIQYIKwYBBQUHAgEWFWh0dHA6Ly93d
     3cuc2suZWUvY3BzLzAhBgNVHREEGjAYgRZsYXVyaS52b3NhbmRpQGVlc3RpLmVlMB0GA1UdDgQWBB
     TLKJsxSanAZh94nSSS3zsjluI2CDAgBgNVHSUBAf8EFjAUBggrBgEFBQcDAgYIKwYBBQUHAwQwGAY
     IKwYBBQUHAQMEDDAKMAgGBgQAjkYBATAfBgNVHSMEGDAWgBR7avJVUFy42XoIh0Gu+qIrPVtXdjBA
     BgNVHR8EOTA3MDWgM6Axhi9odHRwOi8vd3d3LnNrLmVlL3JlcG9zaXRvcnkvY3Jscy9lc3RlaWQyM
     DExLmNybDANBgkqhkiG9w0BAQUFAAOCAQEABrSySeKo3m0DizPtJwOixcfD2ScWNon/nagAYysqAS
     t/9f3fB7wpvEtGHByIZepfpRuIMRPYyR93TsJ9T5MxSOL0oTeXXhsl12uX9cwrxPfb+2nZgn7u43M
     WbqTw/VTpEgnnI7dVNL4XBqYS4AzN/n5QaNPdaS+KwpqUVlx3VlZ17REsziS+QfMuIcjl1gdNWcSl
     44mYefMvxNn+6I6xnUoacvcYv/8RuSFDTua3CfkQbC97qkW6nto6Kz/GVU2WeDBKVYg63gpmi5Tiz
     C6af8XZpMArfP/LhSvsNMOhhhTV7rb4gGtoOcWK8IMGrYSwOXGqpw7nG4AkKJPrtV6UqA==
    objectClass: top
    objectClass: person
    objectClass: organizationalPerson
    objectClass: inetOrgPerson

    # V\C3\95SANDI\2CLAURI\2C38810240348, digital signature, ESTEID, EE
    dn:: Y249VsOVU0FORElcMkNMQVVSSVwyQzM4ODEwMjQwMzQ4LG91PWRpZ2l0YWwgc2lnbmF0dXJlL
     G89RVNURUlELGM9RUU=
    cn:: VsOVU0FOREksTEFVUkksMzg4MTAyNDAzNDg=
    serialNumber: 38810240348
    userCertificate;binary:: MIIEmDCCA4CgAwIBAgIQIMosGr22sKdQUtMK6OHfXTANBgkqhkiG9
     w0BAQUFADBkMQswCQYDVQQGEwJFRTEiMCAGA1UECgwZQVMgU2VydGlmaXRzZWVyaW1pc2tlc2t1cz
     EXMBUGA1UEAwwORVNURUlELVNLIDIwMTExGDAWBgkqhkiG9w0BCQEWCXBraUBzay5lZTAeFw0xMjA
     5MTQwNjQ3MzhaFw0xNzA5MTMyMDU5NTlaMIGYMQswCQYDVQQGEwJFRTEPMA0GA1UECgwGRVNURUlE
     MRowGAYDVQQLDBFkaWdpdGFsIHNpZ25hdHVyZTEjMCEGA1UEAwwaVsOVU0FOREksTEFVUkksMzg4M
     TAyNDAzNDgxETAPBgNVBAQMCFbDlVNBTkRJMQ4wDAYDVQQqDAVMQVVSSTEUMBIGA1UEBRMLMzg4MT
     AyNDAzNDgwggEjMA0GCSqGSIb3DQEBAQUAA4IBEAAwggELAoIBAQC/wwhr84Dh+NhqibfUKGFjzNa
     seB57k3saKGkO/NHgYUwvZbyuhvnH5Vlpd7g1s2L+1iSgHwmJ+waBo4Rc5WgdRRfYcZyUq08TsLxt
     /R+yLAN+H7v+B9niv9B00wvGZbDHCjth35v0bGDr+60jSNNHpbkEysKbEi5cGT9sDqXLtyUI6yfnq
     nhcSGxojmezejwiEmlaG/Denezhyot7+BRvjG1mZZNJ4sgdLOvhYpHxPOq2OsapKMWiB0fTxQYD8q
     ysMNLjUtFytCI5VKoiikxWmClFAXfOjHd94BcBxB1ixVnoZ5c8x+oPwerLAqj3iqMaZOJE37BwxDK
     6U6XrOoPlAgQXvR1Vo4IBDjCCAQowCQYDVR0TBAIwADAOBgNVHQ8BAf8EBAMCBkAwUQYDVR0gBEow
     SDBGBgsrBgEEAc4fAQEDAzA3MBIGCCsGAQUFBwICMAYaBG5vbmUwIQYIKwYBBQUHAgEWFWh0dHA6L
     y93d3cuc2suZWUvY3BzLzAdBgNVHQ4EFgQUZCyvODINo2M+V8aM6JW4nIzAo5QwGAYIKwYBBQUHAQ
     MEDDAKMAgGBgQAjkYBATAfBgNVHSMEGDAWgBR7avJVUFy42XoIh0Gu+qIrPVtXdjBABgNVHR8EOTA
     3MDWgM6Axhi9odHRwOi8vd3d3LnNrLmVlL3JlcG9zaXRvcnkvY3Jscy9lc3RlaWQyMDExLmNybDAN
     BgkqhkiG9w0BAQUFAAOCAQEATbgtcf9Gd7cS70/rfxM64ak/xSpCUWyKA8YQ/NWHd0B+R1u2S+5/P
     NBu2rJRxYDopabnbPXEOgnpvKCuV+uMqX3EiiRQgPHGsfYW6zB9J5K+J99MKHUq/LNGXT7HF500o2
     yEOvqfolCQzaNxW9c+MeSqqR4tviDqGlspkm3S4DFfgSZiSv2k5KQ8RZ+YT02dx2LlrFijPW3BW0E
     dL0IGI8F163LWcT/wuHzLrsOktbpENAFAkb/OrDooIQZWYDR06q7CBcCoYZBw1pKPpw04/pq/LvCG
     XTdKrgE11B563952s8EZJ27pIeI2le3EpzRHT4ALuzd29XrZWjfc5/7Dhw==
    objectClass: top
    objectClass: person
    objectClass: organizationalPerson
    objectClass: inetOrgPerson

    # V\C3\95SANDI\2CLAURI\2C38810240348, authentication, ESTEID (MOBIIL-ID), EE
    dn:: Y249VsOVU0FORElcMkNMQVVSSVwyQzM4ODEwMjQwMzQ4LG91PWF1dGhlbnRpY2F0aW9uLG89R
     VNURUlEIChNT0JJSUwtSUQpLGM9RUU=
    cn:: VsOVU0FOREksTEFVUkksMzg4MTAyNDAzNDg=
    serialNumber: 38810240348
    userCertificate;binary:: MIIEYTCCA0mgAwIBAgIQPBN05E8iKkpQcBpwcfSzYjANBgkqhkiG9
     w0BAQUFADBkMQswCQYDVQQGEwJFRTEiMCAGA1UECgwZQVMgU2VydGlmaXRzZWVyaW1pc2tlc2t1cz
     EXMBUGA1UEAwwORVNURUlELVNLIDIwMTExGDAWBgkqhkiG9w0BCQEWCXBraUBzay5lZTAeFw0xMjE
     wMDYxMTQ4MDBaFw0xNTEwMDYyMDU5NTlaMIGhMQswCQYDVQQGEwJFRTEbMBkGA1UECgwSRVNURUlE
     IChNT0JJSUwtSUQpMRcwFQYDVQQLDA5hdXRoZW50aWNhdGlvbjEjMCEGA1UEAwwaVsOVU0FOREksT
     EFVUkksMzg4MTAyNDAzNDgxETAPBgNVBAQMCFbDlVNBTkRJMQ4wDAYDVQQqDAVMQVVSSTEUMBIGA1
     UEBRMLMzg4MTAyNDAzNDgwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBALTVzNqzoYPYz6bN9G0
     qlMoI6Z+eH47bgG1fcs9QIKPEbdZfVTx4ftoO0aHR9wNHIZ8yuocjrJ9l2yRJysyHmtUnQK78fRX7
     0QUeqpMC8zjLn1PXEsThUaa316b2S8fNP8MkmUsQnsbr3cuxRvD5Lz2G78y7LFR+GisDb0HlmaqtA
     gMBAAGjggFTMIIBTzAJBgNVHRMEAjAAMA4GA1UdDwEB/wQEAwIEsDBRBgNVHSAESjBIMEYGCysGAQ
     QBzh8BAwEBMDcwEgYIKwYBBQUHAgIwBhoEbm9uZTAhBggrBgEFBQcCARYVaHR0cDovL3d3dy5zay5
     lZS9jcHMvMCEGA1UdEQQaMBiBFmxhdXJpLnZvc2FuZGlAZWVzdGkuZWUwHQYDVR0OBBYEFCCVStiA
     oAPzaDxcWA9TqZwPqSEuMCAGA1UdJQEB/wQWMBQGCCsGAQUFBwMCBggrBgEFBQcDBDAYBggrBgEFB
     QcBAwQMMAowCAYGBACORgEBMB8GA1UdIwQYMBaAFHtq8lVQXLjZegiHQa76ois9W1d2MEAGA1UdHw
     Q5MDcwNaAzoDGGL2h0dHA6Ly93d3cuc2suZWUvcmVwb3NpdG9yeS9jcmxzL2VzdGVpZDIwMTEuY3J
     sMA0GCSqGSIb3DQEBBQUAA4IBAQBpOlhkebqN3atoVc23bSHayADOyzVu0UlnbCxRs9TqNwjE1SH5
     x7KGK7FQlpZh3Dh2bFG97dnN9LPrvUdSpyDgA9ZmUcxIwVkBK0HH2ee4SuWslVx15d1eCLgPXsYF1
     LhjFUIAIqWEEsaDyA49vCfuFeaB6pEftSb9k48TNdLf1AN0goYJTQagA3X8J0vzsMiAFzmx4pO/Ft
     fXAErS3VPLM/9INgApcvQtynYks7qTzuhLdUPcQndfoY8lAgAbufxm3QXEh5VhzXrVRDfOt0ixFib
     3QUmeAmEX60uIasVvfM3VoyonYPffIvkCn9cuvljDfMlloqkVdw6QG5q8RPYf
    objectClass: top
    objectClass: person
    objectClass: organizationalPerson
    objectClass: inetOrgPerson

    # V\C3\95SANDI\2CLAURI\2C38810240348, digital signature, ESTEID (MOBIIL-ID), 
     EE
    dn:: Y249VsOVU0FORElcMkNMQVVSSVwyQzM4ODEwMjQwMzQ4LG91PWRpZ2l0YWwgc2lnbmF0dXJlL
     G89RVNURUlEIChNT0JJSUwtSUQpLGM9RUU=
    cn:: VsOVU0FOREksTEFVUkksMzg4MTAyNDAzNDg=
    serialNumber: 38810240348
    userCertificate;binary:: MIIEHzCCAwegAwIBAgIQc2rTECgZ41xQcBpxGh1AQjANBgkqhkiG9
     w0BAQUFADBkMQswCQYDVQQGEwJFRTEiMCAGA1UECgwZQVMgU2VydGlmaXRzZWVyaW1pc2tlc2t1cz
     EXMBUGA1UEAwwORVNURUlELVNLIDIwMTExGDAWBgkqhkiG9w0BCQEWCXBraUBzay5lZTAeFw0xMjE
     wMDYxMTQ4MDFaFw0xNTEwMDYyMDU5NTlaMIGkMQswCQYDVQQGEwJFRTEbMBkGA1UECgwSRVNURUlE
     IChNT0JJSUwtSUQpMRowGAYDVQQLDBFkaWdpdGFsIHNpZ25hdHVyZTEjMCEGA1UEAwwaVsOVU0FOR
     EksTEFVUkksMzg4MTAyNDAzNDgxETAPBgNVBAQMCFbDlVNBTkRJMQ4wDAYDVQQqDAVMQVVSSTEUMB
     IGA1UEBRMLMzg4MTAyNDAzNDgwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBAMfRnrXX5N6tlXx
     oea8f5B6lulPkxULXFokgTJrRIMRQSP80DoKaQ0oC/AgoYr1pvhTKaybZLUhC2ykTBHosExzLM9zo
     NtXo5ru4eqCRBb/18ALkAnzzTaKEcEoP6JNp9IbqdCsFpN4XLYYmqcE+9Py9OS19DpTAtcZf5UDGr
     OpLAgMBAAGjggEOMIIBCjAJBgNVHRMEAjAAMA4GA1UdDwEB/wQEAwIGQDBRBgNVHSAESjBIMEYGCy
     sGAQQBzh8BAwEBMDcwEgYIKwYBBQUHAgIwBhoEbm9uZTAhBggrBgEFBQcCARYVaHR0cDovL3d3dy5
     zay5lZS9jcHMvMB0GA1UdDgQWBBQzCR7T4h+soZPEVECAkiKnP6SZBzAYBggrBgEFBQcBAwQMMAow
     CAYGBACORgEBMB8GA1UdIwQYMBaAFHtq8lVQXLjZegiHQa76ois9W1d2MEAGA1UdHwQ5MDcwNaAzo
     DGGL2h0dHA6Ly93d3cuc2suZWUvcmVwb3NpdG9yeS9jcmxzL2VzdGVpZDIwMTEuY3JsMA0GCSqGSI
     b3DQEBBQUAA4IBAQBr4NMz0bOjeP4wGA5oDPioEW50g7PCz3KFd9NKG4UuixDg+az/IwNbNl0/FuM
     9pYMThK1M6jYbo3g3ODE3g1vT+hu0w9KEnC10VSzRNwrl63CK8mxV5opefdTkuRepzFoAluKBSbVT
     3l1pn07JNJjcIJR/hu/SvQ1k5tkclEuAZJWD2mhJER4ozwO8mHJQ0rIL+qvRsLWGac0ghDrLTlUw9
     GovAEd8LRUrZLN2jt4hoCcvp1ILfvXOMp3KOvHzI5Og5DIzFuu9RVbweszH0UaPDPOMj4Cfme9qpj
     VjBhB7lyJQtllSJsyydIolZX1QDtUfeYZkl9ZS5o+jxDMPm802
    objectClass: top
    objectClass: person
    objectClass: organizationalPerson
    objectClass: inetOrgPerson

    # search result
    search: 2
    result: 0 Success

    # numResponses: 5
    # numEntries: 4


Selleks et neid sertifikaate OpenSSH jaoks söödavasse formaati viia saab
kasutada `Martin Paljaku <https://github.com/martinpaljak/>`_ kirjutatud
`Python teeki <https://github.com/martinpaljak/python-esteid/>`_:

.. code:: bash

    sudo apt-get install build-essential libssl-dev swig libsasl2-dev libldap-dev python-dev
    sudo pip install python-esteid
    esteid ssh 38810240348 > 38810240348.pub
    
Kontrollida saab jällegi *ssh-keygen* abil:

.. code::

    localhost ~ $ ssh-keygen -lf  38810240348.pub 
    2048 fc:06:ae:62:3d:d9:44:5d:99:92:ae:73:9f:ec:77:08  lauri.vosandi@eesti.ee ESTEID (RSA)

Sertifikaat ise erineb kuna selles on kirjas omaniku e-posti aadress kuid
räsi on sama mis ID-kaardist sertifikaati laadides. Sertifikaadisaab serverisse
kopeerida nii nagu eelmiseski näites:

.. code:: bash

    ssh-copy-id -i 38810240348 kasutaja@masin
    
Sisselogimine
-------------

Järgnevalt saab testida kas ID-kaardiga üldse sisse logida saab:

.. code:: bash

    ssh -I opensc-pkcs11.so kasutaja@masin

Ilmselt iga kord seda võtit sisse toksida muutub tüütuks, seepärast
võib lisada vastava võtme SSH kliendi konfiguratsiooni:

.. code:: bash

    echo "PKCS11Provider /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so" \
        | sudo tee -a /etc/ssh/ssh_config

Kokkuvõte
---------

Nii olemegi seadistanud oma arvutis SSH kliendi nõnda et selle abil
saab kaugmasinatesse sisse logida ID-kaardi abil.
Järgmisel korral teeme selgeks kuidas SSH agent abil PIN-i 
küsida, et ka sftp:// võrguketaste haakimine mõnusaks teha.
