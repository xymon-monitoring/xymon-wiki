# External references

Reading maintained outside this project: how other projects take patches, and
general C practice. Nothing on this page governs Xymon — the rules live in the
repository they apply to, behind its review gate:
[CONTRIBUTING.md](https://github.com/xymon-monitoring/xymon/blob/main/CONTRIBUTING.md)
for the contribution rules, and
[AGENTS.md](https://github.com/xymon-monitoring/xymon/blob/main/AGENTS.md) for
coding agents.

## Conditional Logic and Compatibility


Preferred pattern

- One canonical code path whenever possible.
- If compatibility is required, centralize it:
  - a single wrapper or compatibility unit
  - controlled by one build-time detected flag

Avoid

- Scattering `#ifdef` at call sites.
- Multiple overlapping detection modes.
- Duplicated logic across several locations.

## Build / Detection Changes


- Treat build detection as production logic: incorrect detection can break builds downstream.
- Any detection change must document:
  - what is detected
  - detection ordering/precedence
  - which flag/macro is set
  - where it is consumed

## Patch submission and review, elsewhere

- Linux kernel: submitting patches
  https://docs.kernel.org/process/submitting-patches.html
- Mozilla: code review best practices
  https://firefox-source-docs.mozilla.org/browser/FrontendCodeReviewBestPractices.html
- OpenOCD: patch guidelines
  https://openocd.org/doc-release/doxygen/patchguide.html
- Git book: contributing via GitHub
  https://git-scm.com/book/en/v2/GitHub-Contributing-to-a-Project
- GitHub docs: contributing to a project
  https://docs.github.com/en/get-started/exploring-projects-on-github/contributing-to-a-project

## Writing portable C

- Autoconf manual: portable C and C++ programming
  https://www.gnu.org/software/autoconf/manual/autoconf.html#Portable-C-and-C_002b_002b
- The Open Group Base Specifications, Issue 8 (POSIX.1-2024)
  https://pubs.opengroup.org/onlinepubs/9799919799/
- comp.lang.c FAQ
  https://c-faq.com/

## Safety and undefined behaviour

- SEI CERT C Coding Standard
  https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/
- LLVM: what every C programmer should know about undefined behavior
  https://blog.llvm.org/2011/05/what-every-c-programmer-should-know.html

## Language and library reference

- cppreference, C section
  https://en.cppreference.com/c
