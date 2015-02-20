.. flags: hidden

Tallinx migration
=================

Background
----------

Educational institution management in Estonia is dictated by the local authorities.
Tallinn Education Department [#tallinna-haridusamet]_ is the corresponding legal entity of Tallinn.
They manage roughly 200 institutions which sums up to approximately 6000 computers
solely in Tallinn.

Starting from the end of 2013 Microsoft does not consider Estonia a developing country anymore.
The implication of the change was that the
Microsoft Windows and Microsoft Office license fees would
rise from current 6 EUR to 60 EUR per month per machine.
According to Ernst & Young analysis Tallinn could save 490 000 EUR
within 5 years if they would give up Microsoft Office now.
Replacing Windows with Linux would save additional 210 000 EUR.
This was the main motivation for Tallinn Education Department to try out alternatives.
As change from Microsoft Office to LibreOffice was certain, replacing operating
system was more questionable.

In March of 2014 they decided to pilot Linux in 5 educational institutions:
Mustamäe Upper Secondary School [#mg]_,
Tallinn Mahtra Primary School [#mahtra]_,
Merivälja school [#meripohi]_,
Tallinn Mesimummu kindergarten [#mummula]_ and
Tallinn Tammetõru kindergarten [#1alg]_.
Procurement competition was won by Arvuti Traumapunkt OÜ [#atrauma]_ and
Silver Püvi hired me to take care of setting up infrastructure servers.
Most of the work so far has been done remotely in conjunction with local
IT-support.
Before the migration I had around 7 years of open-source hacking experience,
however I never had experience with remote management or
centralized authentication.

.. [#tallinna-haridusamet] http://www.tallinn.ee/eng/haridus/Tallinn-Education-Department
.. [#mg] http://www.mg.edu.ee/
.. [#mahtra] http://www.mahtra.tln.edu.ee/
.. [#meripohi] http://www.meripohi.edu.ee/
.. [#mummula] http://mummula.net/
.. [#1alg] http://www.1alg.tln.edu.ee/
.. [#atrauma] http://www.atrauma.ee/

Status quo
----------

We had to find suitable combination of software and technologies
that would satisfy the needs of schools and guarantee certain degree of freedom
from external software vendors eg Microsoft, Google and similar.

.. figure:: dia/edu-ee.svg

	Current architecture

I picked Puppet for remote management due to the fact that
Margus Ernits had demonstrated successfully managing Ubuntu machines at Estonian IT College using Puppet.
We also considered SaltStack, but since Salt lacked a usable web interface
we chose in favor of Puppet because it can be easily set up with Foreman.
To store authentication and authorization data I picked OpenLDAP.
For user management I devised a minimalist service which makes it possible
to add users simply by inserting Estonian national identification number [#ldap2rest]_.
For central fileserver initially NFS and Samba were considered, but due to lack of
encryption SSH was picked which I had used successfully for personal use.
OwnCloud was also considered, but OwnCloud 6 paired with LDAP had severe performance issues
which made it unusable for our installation.
Central Syslog instance was set up to collect failed login attempts etc.
In addition to that we set up X11rdp server, to make possible using
same software ecosystem from home machines via remote desktop tools.

.. [#ldap2rest] https://github.com/v6sa/ldap2rest

Future
------

Currently there are several plans to develop the infrastructure further.
OwnCloud 7 seems to fix most performance issues associated with the previous version,
so we're planning to switch fileserver to OwnCloud in the spring of 2015.
This makes the file sharing process significantly easier for users,
as currently file access is restricted using POSIX filesystem permissions
which is not exactly user friendly.

There are also plans to distribute authentication databases among
organizations, this means substituting central OpenLDAP with multiple 
embedded Linux based Samba4 boxes which would fill the domain controller role.
This would make it possible to authenticate multitude of operating systems
including Windows with the same domain controller.
Estonian Education and Research Network [#eenet]_ also wants us to pilot
their Candient user management software on Samba4 domain controllers
so the boxes would work in conjunction with TAAT [#taat]_ service which would make it possible to use same authentication
information on various educational network web services.
Samba4 provides out-of-the-box Kerberos5 support which means that
it is possible to develop real single sign-on ecosystem connected to TAAT service.

.. figure:: dia/edu-ee-goal.svg

	Ideal architecture

New machines are currently installed manually from Lubuntu 12.04 CD or bootable memory stick,
paired with Puppet and then populated with the software and configuration from the Puppet master.
Such workflow has several issues - local IT-support has to be heavily involved in the process,
in addition to that
package updates and configuration changes may render the 
machine unusable as described in the thesis proposal [#proposal]_.

We're planning to switch to traditional MATE desktop based Ubuntu 14.04 during the summer of 2015.
By doing so we also want to introduce bulletproof mechanism to
provision machines and update software.
As atomic updating mechanisms are gaining momentum
eg Ubuntu Core [#ubuntu-core]_ we also want have a modern system to update systems.
Currently distributing Btrfs snapshots over multicast or P2P channels seems to
be most attractive option, but that needs further investigation.

To decrease hardware costs we're also exploring options of replacing some
of the workstations with embedded Linux based terminals which connect to central LTSP5 server.
Removing disks and booting Ubuntu from NFS-root [#nfsroot]_ over ethernet also
seems a viable option.
In long run we want to keep the ecosystem flexible so all the services could
be run locally if wished.
To simplify migration to open-source we of course default to central services
managed by us.



.. [#eenet] http://www.eenet.ee/EENet/EENet_en
.. [#taat] http://taat.edu.ee/main/about/?lang=en
.. [#proposal] https://www.sharelatex.com/project/54745b33c647a8077accc1e6
.. [#ubuntu-core] https://wiki.ubuntu.com/Core
.. [#nfsroot] http://lauri.vosandi.com/products.html
