# History

See https://en.wikipedia.org/wiki/Xymon for the source of the text:

_The application was inspired by the open-source version of Big Brother, a network monitoring application, and maintains backward compatibility with it. Between 2002 and 2004 Henrik Storner wrote an open-source software add-on called bbgen toolkit, then in March 2005 a stand-alone version was released called Hobbit. Versions of this were released between 2005 and 2008, but since a prior user of the trademark "Hobbit" existed, the tool was finally renamed Xymon. In January 2012, Quest Software discontinued development of Big Brother._

# ChatGPT version

## Origins: Big Brother (mid-1990s)

Around 1996, Sean MacGuire created "Big Brother" as a simple shell-based tool to monitor servers and services.
​
It used static HTML pages with red/green icons for status display, which was lightweight and scalable at the time.
​
Success led to code bloat, scalability issues, and eventual acquisition by Quest Software, which commercialized it.

## bbgen Toolkit (2002–2004)

Henrik Storner, a Big Brother user since the late 1990s, faced performance limits in large environments.

From 2002 to late 2004, he developed the "bbgen toolkit," an open-source add-on for Big Brother that improved reporting and display efficiency while still relying on a Big Brother server.

## Hobbit: Standalone Server (2005–2008)

On March 30, 2005, version 4.0 decoupled from Big Brother and was renamed "Hobbit," becoming the first full standalone monitoring server.
​
It remained compatible with Big Brother clients for easier migration in existing setups.

Later releases (4.1 in 2005, 4.2 in 2006) added a full Unix client and expanded features.
​
## Renaming to Xymon

Due to "Hobbit" being a protected trademark, the project dropped the Tolkien reference and adopted "Xymon."

The name first appeared in a 4.2 patch around 2008; version 4.3.0 (2010) fully implemented the rename.
​
## Xymon's Current Role

Xymon positions itself as Big Brother's successor, designed for small setups or thousands of hosts/services.

It combines C daemons and shell scripts with a classic red/yellow/green web UI, historical data, and SLA reporting via text files and RRD graphs.