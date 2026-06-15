# xymon-wiki

Collaborative knowledge space maintained by the community.  
Contains HOWTOs, troubleshooting notes, deployment examples, platform-specific information, and practical experience not tied to a specific release.

---

## Purpose

This repository and website serve as a central, searchable entry point for operational and technical knowledge related to the Xymon ecosystem.  
The objective is to reduce repetition and avoid divergent or contradictory guidance across scattered threads.

---

## Access the Wiki Website

- Website (public, indexed):  
  [https://xymon-monitoring.github.io/xymon-wiki/](https://xymon-monitoring.github.io/xymon-wiki/)
  
Key pages (canonical Markdown sources):
- [C coding contribution guidelines](docs/contributing/c-coding-contribution-guidelines.md)
- [AI agent contribution directives](docs/contributing/ai-agent-contribution-directives.md)

- Source repository:  
  [https://github.com/xymon-monitoring/xymon-wiki](https://github.com/xymon-monitoring/xymon-wiki)

---

## Knowledge base

General:
- [How to compile Xymon](docs/how-to-compile-xymon.md)
- [Client / Server communication](docs/client-server-communication.md)
- [History of Xymon](docs/history-of-xymon.md)

Windows PowerShell client (XymonPSClient) — the official Xymon client for Windows (all modern versions):
- [Overview](docs/clients/windows-powershell/overview.md)
- [Installation and usage](docs/clients/windows-powershell/installation.md)
- [Local settings](docs/clients/windows-powershell/local-settings.md)
- [Remote settings](docs/clients/windows-powershell/remote-settings.md)

For very old Windows versions, use [bbwin](https://bbwin.sourceforge.net/).

---

## Current issues

### PCRE on RHEL10-based systems

Anything based on RHEL10 (Oracle Linux 10, CentOS Stream 10, Rocky/Alma 10, etc.)
does not ship the legacy "pcre" (PCRE1 / pcre.h) package in the standard
repositories.

* Xymon 4.3.x still depends on legacy PCRE (PCRE 8.x).
* As a result, ./configure fails by default on EL10 due to missing pcre-devel.

What works today:
* Install legacy PCRE from a compat / third-party repository (e.g. pcre-8.45-1.el10.8 and pcre-devel-8.45-1.el10.8).
* Rerun ./configure; the PCRE check passes.

Where this is going:
* EL10 natively provides PCRE2.
* PCRE2 support is under active upstream review:  https://github.com/xymon-monitoring/xymon/pull/5

### RRDtool 1.9.0 compatibility

RRDtool 1.9.0 (released 2024-07-29) introduced incompatible header changes in
rrd.h. This requires changing affected call sites from char ** to const char **.

What is known to work:
* Debian ships an initial compatibility patch here: https://salsa.debian.org/debian/xymon/-/blob/master/debian/patches/101_rrdtool1.9.patch

What is upstream now:
* The updated fix merged via https://github.com/xymon-monitoring/xymon/pull/57  includes a build-time switch (based on pkg-config) to support both RRDtool 1.9.0 and older versions.

Note:
* This version-based switch is a tactical solution and should later be replaced by a cleaner build system approach (see build system work / #35).

---

## Primary Repositories

- [https://github.com/xymon-monitoring/xymon](https://github.com/xymon-monitoring/xymon)  
  Main source code, active development, server and client components.

- [https://github.com/xymon-monitoring/xymon-svn-mirror](https://github.com/xymon-monitoring/xymon-svn-mirror)  
  Preserved legacy history.

- [https://github.com/xymon-monitoring/xymon-client-powershell](https://github.com/xymon-monitoring/xymon-client-powershell)  
  Modern client implementation for Windows environments.

- [https://github.com/xymon-monitoring/xymon-problems](https://github.com/xymon-monitoring/xymon-problems)  
  Repository intended for issues/topics that are not strictly code problems (cleanup pending).

---

## Work Tracking

- [https://github.com/xymon-monitoring/xymon/issues](https://github.com/xymon-monitoring/xymon/issues)  
  Structured tracking of active work, bug reports, design discussions, and tasks. Key topics may be pinned to remain visible.

- Index Issue (recommended)  
  A single pinned "index" issue can be used to track and link to the current key topics so context remains discoverable over time.

---

## Mailing List

- [https://mailman.xymon.com/postorius/lists/xymon.xymon.com/](https://mailman.xymon.com/postorius/lists/xymon.xymon.com/)  
  Primary forum for user questions, troubleshooting, and long-form discussions.

- Alternative subscription by email: `xymon-subscribe@xymon.com`

- [http://lists.xymon.com/archive](http://lists.xymon.com/archive)  
  Public searchable archive of past discussions.

---

## Communication Channels

- [https://github.com/xymon-monitoring/private](https://github.com/xymon-monitoring/private)  
  Private coordination repository used to reserve channel names and keep internal notes related to future Telegram and Signal st
