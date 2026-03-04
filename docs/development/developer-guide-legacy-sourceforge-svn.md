# System Monitoring with Xymon - Developer Guide (GitHub era)

This page is the GitHub-era entry point for Xymon development.  
The legacy Developer Guide content (SourceForge/SVN era) is preserved below verbatim for reference and review. Nothing has been removed.

---

## GitHub development entry point

### Main repositories and tracking
- Code repository: https://github.com/xymon-monitoring/xymon
- Issues / work tracking: https://github.com/xymon-monitoring/xymon/issues
- Wiki source repository: https://github.com/xymon-monitoring/xymon-wiki
- Wiki website: https://xymon-monitoring.github.io/xymon-wiki/

### Contribution guidelines (canonical Markdown sources)
- [C coding contribution guidelines](docs/contributing/c-coding-contribution-guidelines.md)
- [AI agent contribution directives](docs/contributing/ai-agent-contribution-directives.md)

### Git quick start
Clone:
```sh
git clone https://github.com/xymon-monitoring/xymon.git
cd xymon
```

Create a branch:
```sh
git checkout -b fix/<short-topic>
```

Sync with upstream:
```sh
git fetch origin
git rebase origin/main
```

Inspect changes:
```sh
git status -sb
git diff
git log --oneline --decorate --graph --max-count=20
```

---

## Legacy content (verbatim, SourceForge/SVN era)

== Getting Started with hobbit development on sourceforge ==
=== Reference Books ===
* [[C Programming]]
* UNIX Advance programming
* UNIX Network Programming

=== SVN tutorial ===
==== References ====
* [http://artis.imag.fr/~Xavier.Decoret/resources/svn/index.html Getting started with SVN]
*[http://gcc.gnu.org/wiki/SvnSetup GCC SVN tutorial]
====SVN for Xymon Tutorials ====
Followings are some examples using svn to interact with hobbit on sourceforge.net.
* list out the sub directory of xymon SVN directory.
<pre>
[tjyang@ibm hobbitmon]$ svn ls https://hobbitmon.svn.sourceforge.net/svnroot/hobbitmon
branches/
sandbox/
tags/
trunk/
[tjyang@ibm hobbitmon]$

</pre>
* find out changes in last 7 days.
<pre>
[tjyang@ibm hobbitmon]$ svn log -v -r HEAD:\{`date +%Y-%m-%d -d'7 days ago'`\} \
 https://hobbitmon.svn.sourceforge.net/svnroot/hobbitmon

------------------------------------------------------------------------
r6033 | storner | 2009-01-08 07:43:23 -0600 (Thu, 08 Jan 2009) | 1 line
Changed paths:
   M /trunk/client/Makefile

Make sure client scripts are executable
------------------------------------------------------------------------
r6032 | storner | 2009-01-07 06:00:45 -0600 (Wed, 07 Jan 2009) | 1 line
Changed paths:
   M /branches/4.2.3/build/md5.dat
   A /branches/4.2.3/hobbitd/webfiles/hostlist_footer
   A /branches/4.2.3/hobbitd/webfiles/hostlist_form
   A /branches/4.2.3/hobbitd/webfiles/hostlist_header
   M /branches/4.2.3/lib/headfoot.c
   M /branches/4.2.3/lib/headfoot.h
   M /branches/4.2.3/web/Makefile
   A /branches/4.2.3/web/hobbit-hostlist.c
   A /branches/4.2.3/web/hobbit-hostlist.sh.DIST

Added hostlist CGI from trunk
------------------------------------------------------------------------
r6031 | storner | 2009-01-07 05:59:22 -0600 (Wed, 07 Jan 2009) | 2 lines
Changed paths:
   M /branches/4.2.3/build/generate-md5.sh

Adapted to work with Subversion and new source directories.

------------------------------------------------------------------------
r6030 | storner | 2008-12-17 05:39:49 -0600 (Wed, 17 Dec 2008) | 2 lines
Changed paths:
   A /branches/4.2.3 (from /branches/4.2.2:6029)

New branch off the 4.2.2 release for maintenance - will become 4.2.3 (if needed).

------------------------------------------------------------------------
[tjyang@ibm hobbitmon]$

</pre>
* Checking out hobbit source tree using svn.
<pre>

[tjyang@fc6 ]$ svn co https://hobbitmon.svn.sourceforge.net/svnroot/hobbitmon hobbitmon 
<snip>
A    hobbitmon/tags/rel_4_0-20041201/web/bb-findhost.cgi.1
A    hobbitmon/tags/rel_4_0-20041201/web/bb-ack.c
A    hobbitmon/tags/rel_4_0-20041201/web/hobbitsvc-trends.c
A    hobbitmon/tags/rel_4_0-20041201/web/bb-snapshot.c
A    hobbitmon/tags/rel_4_0-20041201/web/hobbitsvc.c
A    hobbitmon/tags/rel_4_0-20041201/web/bb-eventlog.cgi.1
A    hobbitmon/tags/rel_4_0-20041201/web/bb-rep.cgi.1
A    hobbitmon/tags/rel_4_0-20041201/web/bb-replog.cgi.1
A    hobbitmon/tags/rel_4_0-20041201/web/bb-hist.c
A    hobbitmon/tags/rel_4_0-20041201/web/bb-csvinfo.c
A    hobbitmon/tags/rel_4_0-20041201/web/bb-webpage.c
Checked out revision 5644.

[tjyang@fc6 hobbitmon]$ ls -la
total 28
drwxrwxr-x  6 tjyang tjyang 4096 Aug  4 09:11 .
drwxr-xr-x 38 tjyang tjyang 4096 Aug  4 09:09 ..
drwxrwxr-x  3 tjyang tjyang 4096 Aug  4 09:11 branches
drwxrwxr-x  6 tjyang tjyang 4096 Aug  4 10:04 .svn
drwxrwxr-x 67 tjyang tjyang 4096 Aug  4 10:04 tags
drwxrwxr-x 16 tjyang tjyang 4096 Aug  4 09:11 trunk
[tjyang@fc6 hobbitmon]$

to revert all the changes you made to hobbit src tree.
 svn revert --recursive .
</pre>
* As one of [http://sourceforge.net/project/memberlist.php?group_id=128058 hobbit developers], you can create a branch.
* Following example create a instance of hobbit by tjyang.
<pre>
[tjyang@fc6 hobbitmon]$ svn mkdir branches/tjyang
A         branches/tjyang
[tjyang@fc6 hobbitmon]$ svn copy trunk  branches/tjyang
A         branches/tjyang/trunk
[tjyang@fc6 hobbitmon]$ svn commit -m "T.J. Yang's copy of hobbit"
Authentication realm: <https://hobbitmon.svn.sourceforge.net:443> SourceForge Subversion area
Password for 'tjyang':
Adding         branches/tjyang
Adding         branches/tjyang/trunk

Committed revision 5645.
[tjyang@fc6 hobbitmon]$

</pre>

* creating a subdirectory.
<pre>
[tjyang@fc6 trunk]$ svn status
A      pkg
M      README
[tjyang@fc6 trunk]$ mkdir pkg/tww
[tjyang@fc6 trunk]$ svn status
?      pkg/tww
A      pkg
M      README
[tjyang@fc6 trunk]$ svn add  pkg/tww
A         pkg/tww
[tjyang@fc6 trunk]$ pwd
/home/tjyang/hobbitmon/branches/tjyang/trunk
[tjyang@fc6 trunk]$ ls
bbdisplay  bbproxy  Changes  common     configure.client  COPYING  debian  hobbitd  lib  README         RELEASENOTES  web
bbnet      build    client   configure  configure.server  CREDITS  docs    include  pkg  README.CLIENT  rpm
[tjyang@fc6 trunk]$ pwd
/home/tjyang/hobbitmon/branches/tjyang/trunk
[tjyang@fc6 trunk]$ ls
bbdisplay  bbproxy  Changes  common     configure.client  COPYING  debian  hobbitd  lib  README         RELEASENOTES  web
bbnet      build    client   configure  configure.server  CREDITS  docs    include  pkg  README.CLIENT  rpm
[tjyang@fc6 trunk]$ ls
bbdisplay  bbproxy  Changes  common     configure.client  COPYING  debian  hobbitd  lib  README         RELEASENOTES  web
bbnet      build    client   configure  configure.server  CREDITS  docs    include  pkg  README.CLIENT  rpm
[tjyang@fc6 trunk]$ history |grep commit
 1159  svn commit -m "T.J. Yang's copy of hobbit"
 1217  history |grep commit
 1240  history |grep commit
[tjyang@fc6 trunk]$  svn commit -m "add pkg directory"
Sending        trunk/README
Adding         trunk/pkg
Adding         trunk/pkg/tww
Transmitting file data .
Committed revision 5646.
[tjyang@fc6 trunk]$

</pre>

== Development Road Map ==
=== Henrik, Feb 9 2009 ===
On February 9, Henrik posted the following roadmap to the list.  I 
haven't heard much lately so I don't know if it has changed.

Version 4.4:
* SNMP support for data collection
* Status updates based on data collected in the RRD files (this is really nice - essentially, *any* value you put into an RRD file can trigger a new or modified status in Xymon. So you could eg. change the status of your "http" test to go red, if the response time of a webpage exceeds 5 seconds).
* Status "flap" handling, to catch statuses that change rapidly.

Version 4.5:
* Support for communication between clients and Xymon to use compression and/or encryption.
* Support for client authentication via SSL certificates (so you cannot spoof a client message).

Version 4.6:
* Revised web interface - eliminate the need for webserver-based authentication, and provide more fine-grained authorization for the various Xymon components.
* Per-user custom login pages, so the login will always show those systems that the user has responsibility for / is allowed to access.

Somewhere along the road I will also introduce a new "ping" test
daemon - I am getting to the point where ping'ing all hosts take 
longer than 5 minutes (I have a lot of hosts). So something needs
to be done, and I think I know how to do it.

=== Changes ===


=== Todos ===
 Tasks that most team member agree to implement.

=== Design Document ===
[[Hobbit Design Document]]

=== Wish Lists ===
* Test Suite for software quality assurance.
* Migrate all the bb modules from deadcat.net to hobbit.
* SLA Report built in.
* Better Theme support.
* Provide encrypted communication pipe between hobbit server and hobbit client.
* hobbit messages compression.
* ipv6
* 4.2.x maintenance release.
* Rewrite of the alerts module to work properly. ;) It's quite flawed at the moment.

== Xymon volunteers Roles and Responsibility ==

This is a list of people offer their time and skill to Xymon community in following areas of R&R.
# Project Admin
## Has right as project admin on sourceforge.
## Assign tickets to different persons listed below.
## [http://sourceforge.net/project/memberlist.php?group_id=128058 Grant new developer privilege on sourceforge].
## Get people to work as a team with limited and un-paid  resources. 
#Development
## Understand Xymon source tree.
## Do source code documentation.
## Work on ticket from issue tracker.
## Apply patches submitted from the Xymon community.
## Implement new requested features
# Documentation
## Keep troff files updated with Xymon features.
### maintain troff2html process.
## Create a publish-grade manuals and process for Xymon using Latex.
### use latex2troff tool to generate Xymon troff manpage sources.
### Automate the document generation in "make" command process.
# End User Support
## Answer questions raised in xymon user email list.
## Maintain [http://en.wikibooks.org/wiki/System_Monitoring_with_Xymon/Other_Docs/FAQ Xymon FAQ].
## Test out new Xymon features or verify a bug.
#Module Development
## Write new Xymon client external modules.
## Write Xymon Server side external modules.
## Maintain orphan Xymon modules.
## Maintain Xymon module development guides.
{| class="wikitable sortable" style="font-size: 85%; text-align: center; width: 100%;"
|-
! Name
! Project Admin
! Development
! Documentation
! End User Support
! Module Development
|-
! Henrik Størner 
| 
|  Yes
| 
| 
|
|-
! T.J. Yang
| 
| Yes
| Yes
| 
| Yes
|-
! Jerald Sheets
| 
| 
| Yes
|
| 
|-
! Josh Luthman
| 
| 
|
| 
|
|-
! Malcolm Hunter
| 
| 
| Yes
| Yes
| 
|-
! Japheth J.C. Cleaver
| 
| 
| 
| 
| 
|-
! Steve Holmes
| 
| 
| Y
| Y
| ?
|-
! Damien Martins (aka doctor madness)
| 
| N
| Y
| Y
| N
|-
! dubby
| 
| 
| 
| Yes
| 
|-
! Flemming
| 
| 
| 
| Yes
| 
|-
! [http://www.df7cb.de/ Christoph Berg]
| 
| Yes
| 
| 
| Yes
|-
! Vadim Pushkin
| 
| 
| 
| Yes
| 
|-
! Martin Ward
| 
| Yes
| 
| 
| 
|-
! Buchan Milne
| 
| Yes
| 
| 
| 
|-
! Rich Smrcina
| 
| Yes
| 
| 
| 
|-
! Kenneth Langford 
| 
| Yes
| 
|
| 
|-
!  Padraig Lennon
| 
| 
| 
| 
| 
|-
! David Baldwin
| 
| Yes
| 
| 
| 
|-
! Ralph Mitchell
| 
| 
| Yes
| Yes
| 
|-
! Dummy Template Replace Here
| Admin Y/N
| Dev Y/N
| Doc Y/N
| User Support Y/N
| Module devel Y/N
|-
! Olivier AUDRY
| 
| Yes
| 
| 
| Yes
|-
! Neil Franken
| 
| Yes
| 
| Yes 
| 
|-
! Peter Toft
| 
| 
| 
|
| 
|}

== Packager Who is who ==
* blingme:  Mandriva
* Christoph Berg (Myon):     debian

== Developers Who is who ==
=== [http://sourceforge.net/project/memberlist.php?group_id=128058 Developers with write access] ===
* Henrik Stoerner: http://www.hswn.dk
** Make Big Brother system monitor to be open again.
** Rewrite Big Brother shell scrip part into C code to speed up the performance.
** [http://www.amazon.co.uk/gp/registry/registry.html/ref=w_h_em-si-html_viewall/026-3569182-7564469?id=2EMUDL12T4WA4 Amazon Wish List]

* [http://sourceforge.net/people/viewprofile.php?user_id=2101940 Martin Ward]

* Rich Smrcina 
* Buchan Milne 
* [http://en.wikibooks.org/wiki/User:Tjyang T.J. Yang]
** hobbit wiki book project.
** [http://en.wikibooks.org/wiki/System_Monitoring_with_Hobbit/Developer_Guide#Autoconfiscate_Hobbit Autoconfiscate Hobbit].
** Hobbit documentation project.
*** Will use latex to create hobbit manual.
** Digitation of hobbit software build,package build and deployment process.
** OpenSolaris VMWare appliance for Hobbit Development.
** Using EXTJS 3.0 for hobbit menu system.

=== Developers ===
* Vernon Everett
** hobbit wiki and documentation.

* Etienne GRIGNON  (etienne.grignon@gmail.com )
** BBWin:  http://sourceforge.net/projects/bbwin

* Francesco Duranti <fduranti@q8.it>
** Ability to patch hobbit source code.
** http://www.hswn.dk/hobbiton/2006/10/msg00080.html

* [http://www.thewrittenword.com TWW Inc. ]
**  Package the hobbit client and server using TWW toolsets.

=== List of Names contributed to this hobbit project ===
<pre>
Manon Goo <manon@manon.de>
Alex Tang <altitude@cic.net>
Tim Hudson (tjh@cryptsoft.com)
Steve Reid <steve@edmweb.com>
Thomas Roessler <roessler@does-not-exist.org>
Wei Dai <weidai@eskimo.com>
Eric Young (eay@cryptsoft.com)
Charles Goyard <cg@fsck.Fr>
Marco Avvisano
Paul Backer
Olivier Beau
Adamets Bluejay
Brian Buchanan
Massimo Carnevali
Douwe Dijkstra
Francesco Duranti
Lars Ebeling
Tom Georgoulias
Laurent Grilli
Kevin Hanrahan
Asif Iqbal
Charles Jones
Thomas J Jones
Uwe Kirbach
Joshua Krause
Patrick Lin
Brian Lynch
Thomas Mattsson
Michael Fisher
Daniel J McDonald
Werner Michels
Christian Perrier
Jure Peternel
William Richardson
Torsten Richter
Chris Ricker
Tim Rotunda
Thomas Rucker
Mirko Saam
Thomas Schfer
Tom Schmidt
Eric Schwimmer
Bill Simaz
Gavin Stone-Tolcher
Jeff Stoner
David Stuffle
Christian Thibodeau
Rick Waegner
Rob Watson
</pre>

== Autoconfiscate Hobbit ==
This section describe the conversion of hobbit source tree into autotool control.
=== Why the autoconfiscation ? ===
* To be more portable across OS platforms.
* Plan for I18n and L10n.
* To become true GNU software which require use of autotool.

=== Learn autotool ===
* [http://www.lrde.epita.fr/~adl/autotools.html the autotools tutorial] and read the [http://www.lrde.epita.fr/~adl/dl/autotools.pdf pdf slides].
* hand on testing on hello world example.
* [http://mij.oltrelinux.com/devel/autoconf-automake/ example of using autoscan].

=== Convert hobbit source tree ===
* make sure your autotool sets has following version.
<pre>
GNU Autoconf 2.61 (November 2006)
GNU Automake 1.10 (October 2006)
GNU Libtool 1.5.24 (June 2007)
GNU Gettext 0.17 (November 2007)
</pre>
* download the [http://www.hswn.dk/beta/hobbit-snapshot.tar.gz latest hobbit source tar ball].
* run autoscan to get configure.scan and then modify it as configure.ac.
* convert lib/Makefile demotool/Makefile ... etc into Makfile.am.
* Fine tune configure.ac to take configuration options as configure options.
* Support Linux and Solaris OS setting in configure.ac.

=== References ===
* [http://www.lrde.epita.fr/~adl/autotools.html Great Autotool tutorials and links started here]
* [http://mij.oltrelinux.com/devel/autoconf-automake/ Another tutorial]
* [http://vindaci.members.sonic.net/cbreak/projects/autotools/ Autotool for Beginners]

== Xymon Documentation ==
#Current
## Henrik Stroner use troff to generate manual pages so that we have the RTFM type of documentation.
## Also troff2html is used to create html page for web browser viewing.
#Enhancements Proposals.
## Use latex+dia+make+wiki to create publishing grade docs
## Use Table of Conetent, index, references and Figures to describe Xymon related topic.
## Generate Xymon User Guide.
## Generate Xymon Developer Guide
## Generate Xymon System Admin Guide.
## Generate Xymon Slide for presentation purpose.
## Use Wiki documentation content incubation.
## Generate html.RTF and pdf for different purpose.
# Request Development Team to use doxygen syntax for source code documentation.

=== MediaWiki to DocBook ===
* use mvc to gain hobbit wiki source
* convert mediawiki source to latex.

=== Man pages ===

=== Reuse content from existing hobbit documentation source ===
*  http://www.hswn.dk/hobbit/help/manpages/

== Xymon test suite ==
Run through test cases to verify the code changes are ok.

=== Performance test scripts ===
=== Quality assurance test scripts ===
==== shell scripts ====
* test script in build directory of hobbit-4.0.3 to make sure depended software are in build machine.
<pre>    
build/perl.sh
build/fping.sh             
build/rrd.sh   
build/ssl.sh
build/ldap.sh          
build/pcre.sh
</pre>

=== Test script by Perl ===

=== Test script by Python ===
=== Test script by DejaGNU ===

=== Dtrace probes in hobbit server ===
[http://blogs.sun.com/barts/entry/putting_user_defined_dtrace_probe An example of putting dtrace probe int an application].

== Packaging ==
=== Hobbit Client for OpenSolaris IPS format ===

* Features of This hobbit client
** This hobbit client will use a local account and group to avoid NIS and NFS dependency.
** It will use SMF to start/top hobbit client.
** It will use sudo or Solaris 10's ACL to achieve reading restricted information off OpenSolaris.
** hobbit-client-serverconf is simple version of hobbit client without local messages processing.
** hobbit-client-local will do some processing filtering, it need more depended software.
** it use /opt/hobbitclient42 as installation path.
** svcadm disable/enable network:/hobbit-client-serverconf 

==== OpenSolaris info ====
* OpenSolaris 2008.05
<pre>
-bash-3.2# uname -a
SunOS opensolaris 5.11 snv_86 i86pc i386 i86pc
-bash-3.2# cat /etc/release
                       Open Solaris 2008.05 snv_86_rc2a X86
           Copyright 2008 Sun Microsystems, Inc.  All Rights Reserved.
                        Use is subject to license terms.
                             Assembled 23 April 2008
-bash-3.2#

</pre>

* Installed Sun and SUNW gcc-3.4.3 compilers.
** if not installed run "pkg install sunstudioexpress" and "pkg install SUNWgcc".
<pre>

-bash-3.2# pkg info sunstudioexpress SUNWgcc
          Name: sunstudioexpress
       Summary: Sun Studio Express - C, C++, & Fortran compilers and Tools
         State: Installed
     Authority: opensolaris.org (preferred)
       Version: 0.2008.5
 Build Release: 5.11
        Branch: 0.86
Packaging Date: Wed Apr 30 21:10:32 2008
          Size: 566.2 MB
          FMRI: pkg:/sunstudioexpress@0.2008.5,5.11-0.86:20080430T211032Z

          Name: SUNWgcc
       Summary: gcc - The GNU C compiler
         State: Installed
     Authority: opensolaris.org (preferred)
       Version: 3.4.3
 Build Release: 5.11
        Branch: 0.86
Packaging Date: Sat Apr 26 18:22:21 2008
          Size: 60.4 MB
          FMRI: pkg:/SUNWgcc@3.4.3,5.11-0.86:20080426T182221Z
-bash-3.2#

</pre>

=== Using shell script to automate package building ===
==== RPM ====
<pre>
[root] cat build/makerpm.sh
#!/bin/sh

REL=$1
if [ "$REL" = "" ]; then
        echo "Error - missing release number"
        exit 1
fi

cd ~/hobbit
rm -rf rpmbuild

# Setup a temp. rpm build directory.
mkdir -p rpmbuild/RPMS rpmbuild/RPMS/i386 rpmbuild/BUILD rpmbuild/SPECS rpmbuild/SRPMS rpmbuild/SOURCES
cat >rpmbuild/.rpmmacros <<EOF1
# Default macros for my enviroment.
%_topdir `pwd`/rpmbuild
%_tmppath /tmp
EOF1
cat >rpmbuild/.rpmrc <<EOF2
# rpmrc
buildarchtranslate: i386: i386
buildarchtranslate: i486: i386
buildarchtranslate: i586: i386
buildarchtranslate: i686: i386
EOF2

cat rpm/hobbit.spec | sed -e "s/@VER@/$REL/g" >rpmbuild/SPECS/hobbit.spec
cp rpm/hobbit-init.d rpmbuild/SOURCES/
cp rpm/hobbit.logrotate rpmbuild/SOURCES/

mkdir -p rpmbuild/hobbit-$REL
for f in bbdisplay bbnet bbpatches bbproxy build common docs hobbitd include lib scripts
do
        find $f/ | grep -v RCS | cpio -pdvmu ~/hobbit/rpmbuild/hobbit-$REL/
done
cp -p Changes configure COPYING CREDITS README ~/hobbit/rpmbuild/hobbit-$REL/
find ~/hobbit/rpmbuild/hobbit-$REL -type d|xargs chmod 755

cd rpmbuild
tar zcf SOURCES/hobbit-$REL.tar.gz hobbit-$REL
rm -rf hobbit-$REL
HOME=`pwd` rpmbuild -ba --clean SPECS/hobbit.spec
rpm --addsign RPMS/i?86/hobbit-$REL-*.i?86.rpm
mv RPMS/i?86/hobbit-$REL-*.i?86.rpm SRPMS/hobbit-$REL-*.src.rpm ../rpm/pkg/
[root]
</pre>

=== Using CPAM tools to automate package building ===

== How to participate the hobbit development ==
* subscribe to hobbit mailing list
* create an account on en.wikibooks.org to participate in hobbit documentation effort.
* learn from http://en.wikibooks.org/wiki/CPAM_with_TWW to participate in hobbit automated cross-platform software packaging effort.
=== Setup your development environment ===

==== On OpenSolaris x86 ====
===== Using prebuilt OpenSoalris VMWare Image =====
* Download OpenSolaris VMWare Image from here(TBA).
* Install VMWare player 3.0 from here(TBA).
===== Using VirtualBox OpenSolaris Image =====
==== On Solaris 10 Intel ====
* host info
<pre>
bash-3.00# which cvs
/opt/csw/bin/cvs
bash-3.00# uname -a
SunOS unknown 5.10 Generic i86pc i386 i86pc
bash-3.00# which gcc
/opt/csw/gcc3/bin/gcc
bash-3.00# which gmake
/opt/csw/bin/gmake
bash-3.00#
</pre>

==== On RedHat Linux ====

==== Setup your TWW developement ====
* download TWW tools onto your system
* compile hobbit*.[sb|pb].

=== checkout source code from sourceforge.net  ===
=== Read the source codes  ===
=== Feedback to Hobbit ===
* include your fix,patch, modules addition to sourceforge.net

== Hobbit Functional diagrams ==
=== Hobbit server ===
<pre>

So the core design looks like this:


   Network tests --\
                    \
            TCP:1984 \           IPC
   Clients ----------> hobbitd --------> hobbitd_channel ---> worker module
                     /         Sh. mem.                 stdin
                    /
   Custom tests ---/


     
</pre>

=== Windows Hobbit client  ===

[http://bbwin.sourceforge.net/ BB Win]

== Hobbit Modules Development ==
== Developing Hobbit by Existing Internet Development Environment ==
=== Custom Monitoring Scripts for Hobbit ===

[[System Monitoring with Hobbit/HOWTO/Custom Monitoring Scripts for Hobbit]]
http://www.hswn.dk/hobbit/help/hobbit-tips.html#scripts

== Developing Hobbit by CPAM/TWW Development Environment ==
=== Why use CPAM/TWW tool ? ===
* Pros
** Hobbit server and client need to be cross-platform thus the need of CPAM/TWW.
** Like Emacs editor, it can will be run everywhere without license. TWW tools is GPL opensource so it can be ported to any OS.
** A structural and automated approach to deal with packages creation and management.
* Cons
** Another learning curve need to climb.
** Changing people's development habit is hard.

=== Supported OS ===
* Solaris Sparc
* RH AS 3.0
* HP-UX 11.11
== Hobbit package sources ==
=== Hobbit client on MS windows Overview ===
# bbwin (Xymon client) is implemented in c++. It requires opensource software like boost c++ libary and tinyXML. 
# The packaging tool it used is Microsoft's opensource packaging tool - [http://sourceforge.net/projects/wix/ WiX]to do the Win32 packaging.
# The detals building instruction is [http://bbwin.svn.sourceforge.net/viewvc/bbwin/trunk/Build.txt?revision=21&view=markup build.txt] on bbwin project site. 
# You have two ways to build BBWin.msi, 
## Use Microsoft's make: nmake
## Use "Build Soultion" in VS2008.

Following is a procedure to create a Windows XP development box so you can create your own  BBWin.msi.

== Prepare your Xymon win32  build environment ==
# Install [http://msdn.microsoft.com/en-us/library/ms669985 hhc.exe],it is used to compile html doc into windows chm help file.
## add "C:\Program Files\HTML Help Workshop" into PATH so hhc.exe is accessible.
# Install Visual Studio 2008 Standard or Professional Edition.
# Make sure your cmd.exe has following PATH name addition. echo %PATH% %INCLUDE% %LIB% in your DOS prompt.
## PATH
## "LIB=C:\Program Files\Microsoft Platform SDK\Lib\.;C:\Program Files\Microsoft Visual Studio 8\VC\LIB;"
## INCLUDE
 <pre>
 INCLUDE=C:\Program Files\Microsoft Platform SDK\Include\.;
 C:\Program Files\Microsoft Platform SDK\Include\atl;C:\Program Files\Microsoft Visual Studio 8\VC\include
 </pre>
# Install a svn client for your windows machine.
##  [http://tortoisesvn.net/downloads tortoise svn]
# [http://www.microsoft.com/downloads/details.aspx?FamilyId=A55B6B43-E24F-4EA3-A93E-40C0EC4F68E5&displaylang=en Windows Server 2003 SP1 Platform SDK Web Install]: It is use to have the complete sdk to develop programs on Microsoft OS. Remeber to install all options (include 64 bit and 32 bit) to avoid "atlthunk.lib not found" issue.
## [http://www.microsoft.com/downloads/details.aspx?familyid=7B0B0339-613A-46E6-AB4D-080D4D4A8C4E&displaylang=en install visual service pack 1]:
## [http://blogs.msdn.com/windowssdk/archive/2008/02/22/using-visual-c-2008-express-with-the-windows-sdk-short-version.aspx MSDN blog about VS2008 and SDK]
#[http://wix.sourceforge.net/releases/ WiX opensource packaging tool from Microsoft]: this is use to turn the compiled binary into MS MSI package format.
# [http://www.boost.org/ Boost C++ library]:These powerful C++ libraries are used for some agents and will be certainly used in the BBWin core service in the future. 
##  [http://www.boostpro.com/download/ Download the pre-compiled 1.35 one for VS2008] and install it under C:\boost directory.
# [http://www.grinninglizard.com/tinyxml/ TinyXML]: BBWin used the excellent TinyXML library for the configuration loading XML. You do not need to download and install it. TinyXML sources are included in BBWin sources.
# Prepare your source code editors:
## [http://notepad-plus.sourceforge.net notepade++]:
## [http://www.xemacs.org/Download/win32/ XEmacs for win32]:

# checkout bbwin src.
## Using command "svn co https://bbwin.svn.sourceforge.net/svnroot/bbwin bbwin"
# Change the Makefile code for C:\boost installation.
## Modify Makefile to point INCLUDE to C:\boost and LIB to include C:\boost\lib\*.lib
## Modify C/C++ include c:\boost and Linker to include c:\boost\lib\*.
# Optional software installation
## install cygwin to have a strong unix enviroment on your windows box. So you can run command like following to clean up *.obj file that current makefile can't do.
## Clean up Release directory by Deleting Setup/*.msi
<pre>
$ rm Setup/*
$ rm Release/*
</pre>
==== Build the bbwin using command line approach ====
BBWin.msi creation process is automated in "C:\BBWin\trunk\Setup\Makefile".
This makefile will be called from "C:\BBWin\trunk\Makefile"
* Make sure your nmake command is available.
<pre>
C:\bbwin-src\trunk>nmake -help

Microsoft (R) Program Maintenance Utility Version 8.00.50727.762
Copyright (C) Microsoft Corporation.  All rights reserved.

Usage:  NMAKE @commandfile
        NMAKE [options] [/f makefile] [/x stderrfile] [macrodefs] [targets]

Options:

/A Build all evaluated targets
/B Build if time stamps are equal
/C Suppress output messages
/D Display build information
/E Override env-var macros
/ERRORREPORT:{NONE|PROMPT|QUEUE|SEND} Report errors to Microsoft
/G Display !include filenames
/HELP Display brief usage message
/I Ignore exit codes from commands
/K Build unrelated targets on error
/N Display commands but do not execute
/NOLOGO Suppress copyright message
/P Display NMAKE information
/Q Check time stamps but do not build
/R Ignore predefined rules/macros
/S Suppress executed-commands display
/T Change time stamps but do not build
/U Dump inline files
/Y Disable batch-mode
/? Display brief usage message

C:\bbwin-src\trunk>
</pre>
* cd to c:\bbwin top source directory.
* type "nmake" to kick off the build.

==== Compilation error ====
===== atlbase.h not found =====
* Error message
<pre>
C:\bbwin\trunk\Core\Agents\common>nmake

Microsoft (R) Program Maintenance Utility Version 9.00.30729.01
Copyright (C) Microsoft Corporation.  All rights reserved.

        cl -Zi -Od -DDEBUG -c -DCRTAPI1=_cdecl -DCRTAPI2=_cdecl -nologo -GS -D_X
86_=1  -DWIN32 -D_WIN32 -W3 -D_WINNT -D_WIN32_WINNT=0x0500 -DNTDDI_VERSION=0x050
00000 -D_WIN32_IE=0x0500 -DWINVER=0x0500 /EHsc /I ../.. /I C:\boost\include\boos
t-1_33_1  -D_MT -MTd SystemCounters.cpp
SystemCounters.cpp
SystemCounters.cpp(20) : fatal error C1083: Cannot open include file: 'atlbase.h
': No such file or directory
NMAKE : fatal error U1077: '"C:\Program Files\Microsoft Visual Studio 9.0\VC\BIN
\cl.EXE"' : return code '0x2'
Stop.

C:\bbwin\trunk\Core\Agents\common>
</pre>
* make sure you have following directory and file, if not then you need to use VS non-Express version.
<pre>
C:\Program Files\Microsoft Visual Studio 8\VC\atlmfc\include\atlbase.h
</pre>
* [http://www.gamedev.net/community/forums/topic.asp?topic_id=484760 Possible fix]

===== Temporary Fix for following =====
* Goal is to get rid of " -D_MT -MTd" when using cl MS compiler.
* Run this command in cygwin shell on your codebase, "find . -type f -name Makefile -exec perl -pi -e 's!cvarsmt!conlibsdll!' {} \;" , to replace cvarsmt with conlibsdll.  I don't know the exact impact of not building code with multihreading library.

===== * LINK : warning LNK4098: defaultlib 'LIBCMT' conflicts with use of other libs; use /NODEFAULTLIB:library =====
<pre>
*** C:\bbwin09\trunk\Core\Agents\procs *** "C:\Program Files\Microsoft Visual Studio 8\VC\BIN\nmake.exe" -nologo  /L                  
	link /DLL  procs.obj procs.res -out:procs.dll /LIBPATH:C:\boost\lib libboost_date_time-vc80-mt-s.lib
Microsoft (R) Incremental Linker Version 8.00.50727.762
Copyright (C) Microsoft Corporation.  All rights reserved.

LIBCMT.lib(invarg.obj) : error LNK2005: __initp_misc_invarg already defined in LIBCMTD.lib(invarg.obj)
LIBCMT.lib(invarg.obj) : error LNK2005: __invoke_watson already defined in LIBCMTD.lib(invarg.obj)
LIBCMT.lib(invarg.obj) : error LNK2005: __set_invalid_parameter_handler already defined in LIBCMTD.lib(invarg.obj)
LIBCMT.lib(invarg.obj) : error LNK2005: __get_invalid_parameter_handler already defined in LIBCMTD.lib(invarg.obj)
LIBCMT.lib(invarg.obj) : error LNK2005: "void __cdecl _invoke_watson(unsigned short const *,unsigned short const *,unsigned short const *,unsigned int,unsigned int)" (?_invoke_watson@@YAXPBG00II@Z) already defined in LIBCMTD.lib(invarg.obj)
LIBCMT.lib(invarg.obj) : error LNK2005: __invalid_parameter already defined in LIBCMTD.lib(invarg.obj)
LIBCMT.lib(invarg.obj) : error LNK2005: "void __cdecl _invalid_parameter(unsigned short const *,unsigned short const *,unsigned short const *,unsigned int,unsigned int)" (?_invalid_parameter@@YAXPBG00II@Z) already defined in LIBCMTD.lib(invarg.obj)
LIBCMT.lib(invarg.obj) : error LNK2005: ___pInvalidArgHandler already defined in LIBCMTD.lib(invarg.obj)
   Creating library procs.lib and object procs.exp
LINK : warning LNK4098: defaultlib 'LIBCMT' conflicts with use of other libs; use /NODEFAULTLIB:library
procs.dll : fatal error LNK1169: one or more multiply defined symbols found
NMAKE : fatal error U1077: '"C:\Program Files\Microsoft Visual Studio 8\VC\BIN\link.EXE"' : return code '0x491'
Stop.
*** C:\bbwin09\trunk\Core\Agents\sample *** "C:\Program Files\Microsoft Visual Studio 8\VC\BIN\nmake.exe" -nologo  /L                  
*** C:\bbwin09\trunk\Core\Agents\bbwinupdate *** "C:\Program Files\Microsoft Visual Studio 8\VC\BIN\nmake.exe" -nologo  /L                  

C:\bbwin09\trunk\Core>
</pre>

* http://msdn.microsoft.com/en-us/library/Aa267384
* [http://www.omnetpp.org/listarchive/msg07806.php Possible fix with similar issue].
* [http://www.omnetpp.org/listarchive/msg07798.php vc6 to vc8].
* Try to link with "/NODEFAULTLIB:library".
<pre>
C:\bbwin09\trunk\Core\Agents\procs>nmake clean
nmake clean

Microsoft (R) Program Maintenance Utility Version 8.00.50727.762
Copyright (C) Microsoft Corporation.  All rights reserved.

	erase /Q /S procs.res procs.obj procs.dll procs.exp procs.lib procs.obj
Deleted file - C:\bbwin09\trunk\Core\Agents\procs\procs.res
Deleted file - C:\bbwin09\trunk\Core\Agents\procs\procs.obj
Deleted file - C:\bbwin09\trunk\Core\Agents\procs\procs.exp
Deleted file - C:\bbwin09\trunk\Core\Agents\procs\procs.lib

C:\bbwin09\trunk\Core\Agents\procs>nmake
nmake

Microsoft (R) Program Maintenance Utility Version 8.00.50727.762
Copyright (C) Microsoft Corporation.  All rights reserved.

	cl -Zi -Od -DDEBUG -c -DCRTAPI1=_cdecl -DCRTAPI2=_cdecl -nologo -GS -D_X86_=1  -DWIN32 -D_WIN32 -W3 -D_WINNT -D_WIN32_WINNT=0x0500 -D_WIN32_IE=0x0500 -DWINVER=0x0500 /EHsc /I ../.. /I ../common /I C:\boost\include\boost-1_33_1  -D_MT -MTd procs.cpp
procs.cpp
C:\boost\include\boost-1_33_1\boost/date_time/c_time.hpp(68) : warning C4996: 'localtime': This function or variable may be unsafe. Consider using localtime_s instead. To disable deprecation, use _CRT_SECURE_NO_WARNINGS. See online help for details.
        C:\Program Files\Microsoft Visual Studio 8\VC\include\time.inl(114) : see declaration of 'localtime'
C:\boost\include\boost-1_33_1\boost/date_time/c_time.hpp(75) : warning C4996: 'gmtime': This function or variable may be unsafe. Consider using gmtime_s instead. To disable deprecation, use _CRT_SECURE_NO_WARNINGS. See online help for details.
        C:\Program Files\Microsoft Visual Studio 8\VC\include\time.inl(101) : see declaration of 'gmtime'
C:\boost\include\boost-1_33_1\boost/utility/enable_if.hpp : warning C4819: The file contains a character that cannot be represented in the current code page (950). Save the file in Unicode format to prevent data loss
C:\boost\include\boost-1_33_1\boost/lexical_cast.hpp : warning C4819: The file contains a character that cannot be represented in the current code page (950). Save the file in Unicode format to prevent data loss
C:\boost\include\boost-1_33_1\boost/utility/enable_if.hpp : warning C4819: The file contains a character that cannot be represented in the current code page (950). Save the file in Unicode format to prevent data loss
C:\boost\include\boost-1_33_1\boost/type_traits/is_base_and_derived.hpp : warning C4819: The file contains a character that cannot be represented in the current code page (950). Save the file in Unicode format to prevent data loss
C:\boost\include\boost-1_33_1\boost/lexical_cast.hpp : warning C4819: The file contains a character that cannot be represented in the current code page (950). Save the file in Unicode format to prevent data loss
C:\boost\include\boost-1_33_1\boost/tokenizer.hpp : warning C4819: The file contains a character that cannot be represented in the current code page (950). Save the file in Unicode format to prevent data loss
C:\boost\include\boost-1_33_1\boost/lexical_cast.hpp : warning C4819: The file contains a character that cannot be represented in the current code page (950). Save the file in Unicode format to prevent data loss
C:\boost\include\boost-1_33_1\boost/lexical_cast.hpp : warning C4819: The file contains a character that cannot be represented in the current code page (950). Save the file in Unicode format to prevent data loss
C:\boost\include\boost-1_33_1\boost/tokenizer.hpp : warning C4819: The file contains a character that cannot be represented in the current code page (950). Save the file in Unicode format to prevent data loss
C:\boost\include\boost-1_33_1\boost/lexical_cast.hpp : warning C4819: The file contains a character that cannot be represented in the current code page (950). Save the file in Unicode format to prevent data loss
C:\boost\include\boost-1_33_1\boost/format/internals.hpp : warning C4819: The file contains a character that cannot be represented in the current code page (950). Save the file in Unicode format to prevent data loss
C:\boost\include\boost-1_33_1\boost/format/alt_sstream_impl.hpp : warning C4819: The file contains a character that cannot be represented in the current code page (950). Save the file in Unicode format to prevent data loss
C:\boost\include\boost-1_33_1\boost/format/internals.hpp : warning C4819: The file contains a character that cannot be represented in the current code page (950). Save the file in Unicode format to prevent data loss
C:\boost\include\boost-1_33_1\boost/format/alt_sstream_impl.hpp(252) : warning C4996: 'std::char_traits<char>::copy': Function call with parameters that may be unsafe - this call relies on the caller to check that the passed values are correct. To disable this warning, use -D_SCL_SECURE_NO_WARNINGS. See documentation on how to use Visual C++ 'Checked Iterators'
        C:\Program Files\Microsoft Visual Studio 8\VC\include\iosfwd(446) : see declaration of 'std::char_traits<char>::copy'
        C:\boost\include\boost-1_33_1\boost/format/alt_sstream_impl.hpp(223) : while compiling class template member function 'int boost::io::basic_altstringbuf<Ch,Tr,Alloc>::overflow(int)'
        with
        [
            Ch=char,
            Tr=std::char_traits<char>,
            Alloc=std::allocator<char>
        ]
        C:\boost\include\boost-1_33_1\boost/format/format_class.hpp(136) : see reference to class template instantiation 'boost::io::basic_altstringbuf<Ch,Tr,Alloc>' being compiled
        with
        [
            Ch=char,
            Tr=std::char_traits<char>,
            Alloc=std::allocator<char>
        ]
        procs.cpp(235) : see reference to class template instantiation 'boost::basic_format<Ch>' being compiled
        with
        [
            Ch=char
        ]
	Rc /r -DWIN32 -D_WIN32 -DWINVER=0x0500 -DDEBUG -D_DEBUG  /fo procs.res procs.rc
	link /NODEFAULTLIB:library  procs.obj procs.res -out:procs.dll /LIBPATH:C:\boost\lib libboost_date_time-vc80-mt-s.lib
Microsoft (R) Incremental Linker Version 8.00.50727.762
Copyright (C) Microsoft Corporation.  All rights reserved.

LIBCMT.lib(invarg.obj) : error LNK2005: __initp_misc_invarg already defined in LIBCMTD.lib(invarg.obj)
LIBCMT.lib(invarg.obj) : error LNK2005: __invoke_watson already defined in LIBCMTD.lib(invarg.obj)
LIBCMT.lib(invarg.obj) : error LNK2005: __set_invalid_parameter_handler already defined in LIBCMTD.lib(invarg.obj)
LIBCMT.lib(invarg.obj) : error LNK2005: __get_invalid_parameter_handler already defined in LIBCMTD.lib(invarg.obj)
LIBCMT.lib(invarg.obj) : error LNK2005: "void __cdecl _invoke_watson(unsigned short const *,unsigned short const *,unsigned short const *,unsigned int,unsigned int)" (?_invoke_watson@@YAXPBG00II@Z) already defined in LIBCMTD.lib(invarg.obj)
LIBCMT.lib(invarg.obj) : error LNK2005: __invalid_parameter already defined in LIBCMTD.lib(invarg.obj)
LIBCMT.lib(invarg.obj) : error LNK2005: "void __cdecl _invalid_parameter(unsigned short const *,unsigned short const *,unsigned short const *,unsigned int,unsigned int)" (?_invalid_parameter@@YAXPBG00II@Z) already defined in LIBCMTD.lib(invarg.obj)
LIBCMT.lib(invarg.obj) : error LNK2005: ___pInvalidArgHandler already defined in LIBCMTD.lib(invarg.obj)
   Creating library procs.lib and object procs.exp
LINK : warning LNK4098: defaultlib 'LIBCMT' conflicts with use of other libs; use /NODEFAULTLIB:library
LIBCMTD.lib(crt0.obj) : error LNK2019: unresolved external symbol _main referenced in function ___tmainCRTStartup
procs.dll : fatal error LNK1120: 1 unresolved externals
NMAKE : fatal error U1077: '"C:\Program Files\Microsoft Visual Studio 8\VC\BIN\link.EXE"' : return code '0x460'
Stop.

C:\bbwin09\trunk\Core\Agents\procs>
</pre>

==== build the bbwin using GUI approach ====
* check out the source code
* open up bbwin.sln
<pre>
follow text will turn into wiki procedure above.
Build file for BBWin
    2 ==============================================================
    3 
    4 This file explains you how to build BBWin from the sources.
    5 
    6 
    7 Getting the last sources 
    8 ========================
    9 
   10 BBWin is developed in C++ (the Standard Template Library and the Standard C++ Library
   11 are used)
   12 The source of BBWin are available from the sourceforge subversion
   13 repository for the BBWin projects :
   14 http://svn.sourceforge.net/viewcvs.cgi/bbwin/
   15 
   16 
   17 Install the tools
   18 =================
   19 
   20 BBWin has been developed thanks to many tools. You should install them to 
   21 build BBWin easily without troubles.
   22 
   23 Windows Platform SDK 2003 : it is used for the development environment.
   24 It is use to have the complete sdk to develop programs on Microsoft OS.
   25 You can download it for free from microsoft website :
   26 http://www.microsoft.com/downloads/details.aspx?FamilyId=A55B6B43-E24F-4EA3-A93E-40C0EC4F68E5&displaylang=en
   27 You will need 1 gb of free space if you install every thing :)

   28 BBWin Makefiles are using the nmake tool and Makefile templates from the SDK.
   29 This SDK is very important for anyone who would like to start developing under Windows.
   30 
   31 Visual C++ Toolkit : it is the compiler used to build the bbwin release
   32 It is the original compiler from Visual Studio 2003 Professional (Code optimisation is included)
   33 You can download it for free from the Microsoft website :
   34 http://msdn.microsoft.com/visualc/vctoolkit2003/
   35 
   36 Wix Toolkit : this package is used to build the BBWin MSI installer
   37 You should install it and have the bin directory in your current path
   38 http://sourceforge.net/projects/wix/
   39 
   40 TinyXML : BBWin used the excellent TinyXML library for the configuration loading XML.
   41 You do not need to install it. TinyXML sources are included in BBWin sources.
   42 
   43 Boost Lib : These powerful C++ libraries are used for some agents and will be
   44 certainly used in the BBWin core service in the future.
   45 You should get the boost C++ from the website : 
   46 http://www.boost.org/
   47 Build it in the directory C:\boost so you won't have to change BBWin Makefiles.
   48 If you want to build BBWin with Visual C++ Express 2005, please read the following page :
   49 http://www.boost.org/tools/build/v1/vc-8_0-tools.html
   50 
   51 
   52 I recommand you the Notepad++ editor if you are looking for a nice free code editor.
   53 You can download it from : 
   54 http://notepad-plus.sourceforge.net
   55 
   56 
   57 
   58 Building the BBWin with Visual C++ Express 2005
   59 ===============================================
   60 
   61 Open the BBWin.sln file at the top directory of the project
   62 First, you should prepare your Visual C++ configuration by adding
   63 in the default bin, include and lib directories the different directories from :
   64 
   65 - the platform SDK
   66 - the boost libraries
   67 
   68 Then just build the solution.
   69 
   70 
   71 Building the BBWin with Visual C++ ToolKit 2003
   72 ===============================================
   73 
   74 Open a Platform SDK Build command line environment (installed with the Platform SDK)
   75 Go the top directory of the BBWin source tree
   76 Type nmake
   77 Go get a cup of coffee
   78 It's ready !
   79 
   80 If you get errors, it may be due to some errors in your include or lib path.
   81 Make sure the environment variables %Lib%; %Path% and %Include% are correctly 
   82 configured. You may need to add some directories.
   83 
   84 Building process order
   85 ======================
   86 
   87 1) BBWin core service
   88 2) Agents
   89 3) Externals (needing compilation)
   90 4) Setup MSI
   91 
</pre>

* Example of using nmake to create a BBwin.msi
<pre>
C:\tmp\test\trunk\Setup>nmake clean

Microsoft (R) Program Maintenance Utility Version 8.00.50727.42
Copyright (C) Microsoft Corporation.  All rights reserved.

        erase /q /s BBWin.dll BBWin.exp UpgradeConfiguration.obj BBWin.res BBWin
.wixobj BBWin.msi BBWin.lib
Deleted file - C:\tmp\test\trunk\Setup\BBWin.wixobj
Deleted file - C:\tmp\test\trunk\Setup\BBWin.msi

C:\tmp\test\trunk\Setup>nmake

Microsoft (R) Program Maintenance Utility Version 8.00.50727.42
Copyright (C) Microsoft Corporation.  All rights reserved.

        candle /nologo BBWin.wxs
BBWin.wxs
        light /nologo BBWin.wixobj

C:\tmp\test\trunk\Setup>
</pre>

==== bbwin 0.9 package source ====

{{BookCat}}

