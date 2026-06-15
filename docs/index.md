# Xymon Wiki

Collaborative knowledge space maintained by the community — HOWTOs, troubleshooting
notes, deployment examples, platform-specific information, and practical experience
not tied to a specific release.

## Purpose

A central, searchable entry point for operational and technical knowledge about the
Xymon ecosystem. The objective is to reduce repetition and avoid divergent or
contradictory guidance across scattered threads.

## Knowledge base

General:

- [Xymon server documentation](guides/server-documentation.md) — links to the official xymon.com help pages
- [Compile Xymon](guides/how-to-compile-xymon.md)
- [Client / Server communication](guides/client-server-communication.md)
- [History of Xymon](guides/history-of-xymon.md)

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
