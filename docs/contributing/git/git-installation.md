Git installation and auth
=========================

Purpose
-------
This document covers Git and GitHub CLI installation and login.


Installation
------------
Recommended environment: Linux or WSL (same as CI).

Linux / WSL:
```
sudo apt update
sudo apt install -y git gh
```

macOS:
```
brew install git gh
```

Windows (choose one):
```
winget install Git.Git GitHub.cli
```
```
choco install git gh
```


Authenticate gh (once, browser-based)
-------------------------------------
Run:
```
gh auth login
```

Choose:

- GitHub.com
- HTTPS
- Authenticate Git with GitHub credentials: Yes
- Login method: Browser

Verify:
```
gh auth status
```

Verify / configure Git identity
------------------------------

After authentication, verify that a Git identity is configured.

Verify:
```
git config --show-origin --get user.name
git config --show-origin --get user.email
```

If required, configure one:

Global (all repositories):
```
git config --global user.name "Username"
git config --global user.email "your@email"
```

GitHub-provided no-reply addresses are valid:
`id+username@users.noreply.github.com`


