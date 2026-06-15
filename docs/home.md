# Welcome to the xymon-wiki

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

## Howto's
* [How to Compile Xymon](how-to-compile-xymon.md)

## [History](history-of-xymon.md)

## Clients

### Windows PowerShell Client
This is the official Xymon client for Windows.
All modern versions of Windows are supported.

See [this page](clients/windows-powershell/overview.md) for the documentation.

To monitor really old versions of Windows, you can use [bbwin](https://bbwin.sourceforge.net/)