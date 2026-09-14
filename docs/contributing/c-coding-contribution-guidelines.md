# C Coding Contribution Guidelines (Draft)

Scope

- General expectations for contributing C changes.
- Goals: stability, reviewability, and evidence-based validation.

## Principles

1) Stability first
- Prefer minimal, low-risk changes.
- Assume changes can reach downstream distributions and production systems.

2) One concern per PR
- One bugfix or one narrowly scoped change per PR.
- Do not mix functional fixes with refactors, formatting, or unrelated cleanups.

3) Reviewability is mandatory
- Keep diffs small and self-contained.
- Minimize touched files and avoid new layers unless strictly required.

4) Evidence-based claims only
- Do not claim "tested", "validated", or "fixed" without concrete evidence.

## Patch and PR Scope

Allowed by default

- Focused bugfixes.
- Small refactors required to implement the fix safely.
- Targeted build/detection adjustments tied to a documented failure mode.

Not allowed unless explicitly agreed

- Drive-by cleanups (whitespace, reformatting, broad renames).
- Deletions of legacy code paths unrelated to the fix.
- New compatibility frameworks or large abstraction layers.

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

## Testing Expectations (Minimum)

For any PR that touches build logic or external dependencies:

- Provide:
  - configure/build confirmation (commands + key output excerpts)
  - runtime sanity check if applicable

Always include environment details:

- OS
- compiler
- relevant dependency versions
- install method (packages vs custom)

## PR Description Template (Required?)

- Problem:
- Reproduction:
- Root cause:
- Change summary:
- Risk assessment:
- Build tested on:
  - OS:
  - Compiler:
  - Dependency versions:
  - Install method:
- Runtime checks (if applicable):
- Notes for packagers/maintainers:

## External Baseline References

### Patch submission and review, elsewhere

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

### Writing portable C

- Autoconf manual: portable C and C++ programming
  https://www.gnu.org/software/autoconf/manual/autoconf.html#Portable-C-and-C_002b_002b
- The Open Group Base Specifications, Issue 8 (POSIX.1-2024)
  https://pubs.opengroup.org/onlinepubs/9799919799/
- comp.lang.c FAQ
  https://c-faq.com/

### Safety and undefined behaviour

- SEI CERT C Coding Standard
  https://cmu-sei.github.io/secure-coding-standards/sei-cert-c-coding-standard/
- LLVM: what every C programmer should know about undefined behavior
  https://blog.llvm.org/2011/05/what-every-c-programmer-should-know.html

### Language and library reference

- cppreference, C section
  https://en.cppreference.com/c
