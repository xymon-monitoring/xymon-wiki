# Downstream repositories

A downstream repository packages or integrates Xymon for a platform — an RPM,
a Debian package, a FreeBSD port, a container image. Xymon itself lives in
`xymon-monitoring/xymon`; a downstream builds from it and adds only what its
platform needs.

## Where a change belongs

**Upstream provides mechanism and location; downstream provides activation and
policy.** Xymon's behaviour, its build and what `make install` produces are
upstream. What a package installs, requires, starts, migrates or labels — and
any choice only a distribution can make — is downstream.

Three consequences hold for every downstream:

- **Upstream serves every platform, not only those with a downstream listed
  here.** A sample a platform needs to run Xymon — a service unit or init
  script for each init system, a logrotate, sysctl or firewall snippet — is
  mechanism: upstream ships it under `tools/`, whether or not a listed
  downstream uses it, and a downstream only installs and enables it. Package
  format and init system vary independently — RPM systems with SysV init
  exist, as do non-RPM systems with systemd — so the format never decides
  which samples exist. A sample does not go in upstream's `rpm/`, which
  `xymon-rpm` does not build from.
- **A downstream may compensate for an upstream gap** until upstream fixes it,
  as long as the compensation names the upstream pull request that will remove
  it. Without that, the workaround becomes a permanent divergence nobody
  recognises as removable.
- **The boundary moves.** Where a change belongs is dated, not settled: when the
  upstream fix merges, the compensation becomes divergence and should go.

A change to what `make install` produces reaches every downstream at once, so
the packagers are told before it merges.

## The repositories

Each keeps its own detailed rules; this page does not repeat them.

| downstream | repository | its rules |
|---|---|---|
| RPM (EL, Fedora) | [`xymon-monitoring/xymon-rpm`](https://github.com/xymon-monitoring/xymon-rpm) | [`CONTRIBUTING.md`, *Which repository*](https://github.com/xymon-monitoring/xymon-rpm/blob/main/CONTRIBUTING.md#which-repository) |
