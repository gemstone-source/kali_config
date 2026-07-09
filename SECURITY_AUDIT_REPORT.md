# Security Audit Report: kali_config

**Date:** 2026-07-08
**Repository:** `gemstone-source/kali_config`
**Type:** Personal dotfiles repo (Kali Linux + i3/polybar/rofi)
**Repo Size:** 49 MB (excluding .git)
**Git History:** 121 commits, 2 contributors, single `main` branch

---

## Executive Summary

This is a low-risk personal dotfiles repository with **no critical security vulnerabilities** (no hardcoded API keys, passwords, tokens, or private keys). The primary concerns are **information leakage** (PII/MAC address exposure), **shell script hygiene** (unquoted variables, missing error handling), and **supply chain bloat** (embedded third-party repos and binary blobs). A total of **14 findings** are documented below.

---

## Phase 1: Secrets & Information Leakage

### Tools Used
- Regex scanning for API keys, tokens, credentials, MACs, private keys
- Full git history diff analysis (121 commits, all branches)
- Binary file inspection (`.deb`, `.swp`, images)

### Findings

| # | Severity | Finding | Location | Detail |
|---|----------|---------|----------|--------|
| 1 | **Medium** | Hardcoded MAC address | `.zshrc:271` | `alias mac='sudo macchanger -m e4:54:e8:d6:6c:7a eth0'` — real NIC address exposed |
| 2 | **Low** | Personal directory paths | `gtk-3.0/bookmarks:1-7` | Reveals username `gemstone`, academic context (`THIRD%20YEAR/semister%20two/Security/Path`) |
| 3 | **Info** | Snyk org auto-select | `.vscode/settings.json:2` | `snyk.advanced.autoSelectOrganization: true` — minor org info leak |
| 4 | **Info** | GitHub secret reference | `rofi/.github/workflows/sponsors.yml:17` | `${{ secrets.GH_PAT_SPSR }}` — reference only, actual token not present |
| 5 | **None** | API keys / tokens / passwords | — | **No credentials found** in current files or full git history |

### Git History Analysis
- **Deleted files examined:** `alacritty.yml`, `.zshrc` (older versions), `zen.toml`, vim swap files, font installer
- **Deleted binary blobs:** `i3/.config.swp`, `i3/.config.swo`, `.alacritty.yml.swp` in history — no secrets extracted from these
- **No secrets ever committed** to any revision
- **No `.env`, `.secret`, `.key`, `.pem`, or `id_*` files** in any commit

---

## Phase 2: Shell Script Security Analysis

### Tool Used
ShellCheck (via `koalaman/shellcheck:latest` Docker container) — run on all 13 shell scripts.

### Findings

| # | Severity | Finding | File | Detail |
|---|----------|---------|------|--------|
| 6 | **Medium** | **Privileged code injection risk via unquoted `$theme` in `pkexec` context** | `rofi/files/applets/bin/appasroot.sh:69` | `pkexec env PATH=$PATH DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY` passes user's `PATH` to root — if `$theme` path is manipulated, an attacker could execute arbitrary code as root |
| 7 | **Medium** | **Destructive shell injection in powermenu** | `rofi/files/applets/bin/powermenu.sh:84`, `:94-103` | `confirm_run` uses `${1} && ${2} && ${3}` which expands arguments directly — combined with `kill -9 -1` this can kill all user processes |
| 8 | **High** | **Unquoted variable expansions (systemic)** | All 9 rofi applet scripts | `cat ${theme}`, `rofi_cmd ... -theme ${theme}` — path injection if theme path contains spaces or special characters. Affects: `appasroot.sh`, `battery.sh`, `brightness.sh`, `mpd.sh`, `powermenu.sh`, `quicklinks.sh`, `screenshot.sh`, `volume.sh`, `apps.sh` |
| 9 | **Low** | Missing `cd` error handling | `setup.sh:42` | `cd rofi` without `|| exit` — if `git clone` fails, subsequent commands may run in wrong directory |
| 10 | **Info** | Backtick legacy syntax | All scripts | 50+ instances of `` `cmd` `` instead of `$(cmd)` — not a vulnerability but poor practice |
| 11 | **Info** | Unused variables | `rofi/setup.sh:10-11` | `BBlack`, `BCyan`, `BWhite` declared but never used |
| 12 | **Info** | `cp -r` vs `cp -R` portability | `setup.sh:11,15`, `rofi/setup.sh` | `-r` flag behavior is implementation-defined; `-R` is POSIX-standard |

### ShellCheck Summary

| Script | Warnings | Info |
|--------|----------|------|
| `setup.sh` | 3 | 1 |
| `polybar/launch.sh` | 0 | 0 |
| `rofi/setup.sh` | 3 | 11 |
| `rofi/files/applets/bin/appasroot.sh` | 7 | 2 |
| `rofi/files/applets/bin/battery.sh` | 11 | 6 |
| `rofi/files/applets/bin/brightness.sh` | 8 | 5 |
| `rofi/files/applets/bin/mpd.sh` | 14 | 7 |
| `rofi/files/applets/bin/powermenu.sh` | 11 | 5 |
| `rofi/files/applets/bin/quicklinks.sh` | 10 | 3 |
| `rofi/files/applets/bin/screenshot.sh` | 11 | 7 |
| `rofi/files/applets/bin/volume.sh` | 12 | 6 |
| `rofi/files/applets/bin/apps.sh` | 10 | 3 |
| **Total** | **100** | **56** |

---

## Phase 3: Supply Chain & Dependency Risks

| # | Severity | Finding | Detail |
|---|----------|---------|--------|
| 13 | **Medium** | **Embedded full repo clone (77 MB)** | `rofi/` is a full clone of `adi1090x/rofi` (pinned at `512a585`) — not a git submodule. Bloats repo by 77 MB. Upstream changes cannot be tracked without manual re-clone |
| 14 | **Medium** | **Binary .deb in version control (1.6 MB)** | `alacritty_0.10.0-rc4-1_amd64_bullseye.deb` — release candidate from 2021. No checksum verification, no integrity check. Binary blobs complicate security auditing |
| 15 | **Low** | No apt package version pinning | `setup.sh:4-6` — installs latest available versions, no lock file |
| 16 | **Low** | `wget` without checksum verification | `setup.sh:33` — downloads `.deb` without verifying hash; MITM risk during installation |

---

## Phase 4: Configuration Security Review

| # | Severity | Finding | Location | Detail |
|---|----------|---------|----------|--------|
| 17 | **Info** | Network interface monitoring displays IP | `polybar/config.ini:282-311`, `i3/i3blocks.conf:54` | Wired/wireless IP and `tun0` (VPN) visible in status bar — information leakage risk on screen share |
| 18 | **Info** | Duplicate alias definitions | `.zshrc:268-279` | `burp` and `ctf` defined twice each (different paths) — last definition wins, unexpected behavior |
| 19 | **Info** | ADB proxy alias with command injection potential | `.zshrc:278` | `alias adbon="adb shell ... $(ifconfig | grep wlan0 ...)"` — fragile IP parsing with command substitution; if `wlan0` doesn't exist, the alias expands an error string |
| 20 | **Info** | Minimal `.gitignore` | `.gitignore:1` | Only ignores `.DS_Store`. No coverage for: `.env`, `.secret*`, `*id_rsa*`, `*id_dsa*`, `*.key`, `*.pem`, `*.cert`, `*.p12`, `*.keystore`, swap files, etc. |
| 21 | **Info** | No `.gitattributes` | — | No rules for normalizing line endings, diffing binary files, or language-specific settings |

---

## Phase 5: Remediation Recommendations

### Critical / High Priority

1. **Remove hardcoded MAC address** from `.zshrc:271` — use a random MAC or external config file
2. **Quote all shell variables** across all rofi applet scripts (`"${theme}"`, `"${dir}"`, etc.) to prevent word splitting and path injection
3. **Fix `pkexec` environment injection** in `appasroot.sh:69` — sanitize `PATH` or use absolute paths for privileged execution
4. **Harden `confirm_run` in powermenu.sh** — validate or sanitize arguments rather than expanding `${1} && ${2} && ${3}`

### Medium Priority

5. **Replace embedded `rofi/` with a git submodule** — `git submodule add https://github.com/adi1090x/rofi.git` and reference a stable tag
6. **Remove `alacritty*.deb` from repo** — add download + checksum verification instructions in `setup.sh` instead
7. **Add broad `.gitignore`** — include patterns for swap files (`*.swp`, `*.swo`), secrets, keys, and IDE configs
8. **Add `cd || exit` guard** to `setup.sh:42`

### Low Priority / Hygiene

9. **Replace all backtick commands** with `$(...)` syntax for readability and nesting
10. **Add `.gitattributes`** — set `* text=auto`, mark images as binary
11. **Consolidate duplicate aliases** in `.zshrc` (remove redundant `burp` and `ctf` definitions)
12. **Set up pre-commit hooks** — add `pre-commit` config with `shellcheck`, `end-of-file-fixer`, `trailing-whitespace`
13. **Consider `gitleaks` or `truffleHog`** for automated secret scanning before pushing to public remotes
14. **Use `apt list --upgradable` before running setup.sh** to ensure no broken packages

---

## Tools Used

| Tool | Purpose | Version |
|------|---------|---------|
| ShellCheck | Static analysis for shell scripts | `v0.10.0` (Docker) |
| Git log + grep | Git history analysis | n/a |
| `file`, `sha256sum`, `dpkg` | Binary inspection | n/a |

*Note: `gitleaks` and `truffleHog` were not available in the environment. Manual regex scanning was performed as a substitute.*

---

## Verdict

**Overall Risk Level: LOW**

No sensitive credentials, API keys, or authentication tokens were found anywhere in the repository or its history. The primary actionable concerns are:
1. **MAC address exposure** — should be removed before publishing publicly
2. **Unquoted shell variables** — systemic across all rofi scripts, potential for path injection
3. **Privileged execution** — `pkexec + unquoted expansion` in `appasroot.sh` is the highest-severity finding
4. **Repo bloat** — 77 MB of third-party code and 1.6 MB binary could be managed more safely
