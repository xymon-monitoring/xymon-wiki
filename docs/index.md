# Xymon Wiki

Collaborative knowledge space maintained by the community — HOWTOs, troubleshooting
notes, deployment examples, platform-specific information, and practical experience
not tied to a specific release.

## What is Xymon?

Xymon is a system for monitoring servers and networks. Inspired by Big Brother, it
works well from a handful of hosts up to networks with thousands of servers and
services. A central server periodically checks network services (HTTP, FTP, SMTP, …)
and — through agents on each host — local disk, logfiles and processes. It builds
status web pages with drill-down, records the history of every item for availability
and trend reporting (with graphs), and raises alerts by e-mail, SMS or pager when
something breaks.

Xymon is the successor to the *bbgen toolkit* (an add-on to Big Brother since 2002)
and was renamed from *Hobbit* in 2009. The easiest way to understand it is to see it
live at **[xymon.com](https://www.xymon.com/)**; for the full introduction, read
[About Xymon](https://www.xymon.com/help/about.html).

## Purpose

A central, searchable entry point for operational and technical knowledge about the
Xymon ecosystem. The objective is to reduce repetition and avoid divergent or
contradictory guidance across scattered threads.

## Knowledge base

General:

- [Xymon server documentation](guides/server-documentation.md) — links to the official xymon.com help pages
- [Compile Xymon](guides/how-to-compile-xymon.md)
- [Client / Server communication](guides/client-server-communication.md)
- [History of Xymon](about/history-of-xymon.md)

Windows PowerShell client (XymonPSClient) — the official Xymon client for Windows
(all modern versions):

- [Overview](clients/windows-powershell/index.md)
- [Installation and usage](clients/windows-powershell/installation.md)
- [Local settings](clients/windows-powershell/local-settings.md)
- [Remote settings](clients/windows-powershell/remote-settings.md)

For very old Windows versions, use [bbwin](https://bbwin.sourceforge.net/).

Contributing:

- [C coding contribution guidelines](contributing/c-coding-contribution-guidelines.md)
- [AI agent contribution directives](contributing/ai-agent-contribution-directives.md)

## Primary repositories

- [xymon](https://github.com/xymon-monitoring/xymon) — main source code; active development, server and client components.
- [xymon-svn-mirror](https://github.com/xymon-monitoring/xymon-svn-mirror) — preserved legacy history.
- [xymon-client-windows-powershell](https://github.com/xymon-monitoring/xymon-client-windows-powershell) — modern client implementation for Windows environments.
- [xymon-problems](https://github.com/xymon-monitoring/xymon-problems) — issues/topics that are not strictly code problems (cleanup pending).

## Work tracking

- [Issues](https://github.com/xymon-monitoring/xymon/issues) — structured tracking of active work, bug reports, design discussions, and tasks. Key topics may be pinned to remain visible.
- Index issue (recommended) — a single pinned "index" issue can track and link the current key topics so context stays discoverable over time.

## Mailing list

- [Postorius (list home)](https://mailman.xymon.com/postorius/lists/xymon.xymon.com/) — primary forum for user questions, troubleshooting, and long-form discussions.
- Subscribe by email — `xymon-subscribe@xymon.com` (works without an account).
- Archives (three views of the same list):
    - [Pipermail](https://lists.xymon.com/xymon/) — original historical archive, 2005 → mid-2024 (post-2024 superseded by HyperKitty).
    - [HyperKitty](https://mailman.xymon.com/hyperkitty/list/xymon@xymon.com/) — current Mailman 3 web archive, 2024-07 → present.
    - [Merged mirror](https://xymon-monitoring.github.io/xymon-discussion-public/) — Pipermail + HyperKitty combined, deduped and searchable, 2005 → present.

## Communication channels

- [private](https://github.com/xymon-monitoring/private) — private coordination repository used to reserve channel names and keep internal notes related to future Telegram and Signal channels.
