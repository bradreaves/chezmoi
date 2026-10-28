# README

This uses `chezmoi` to install and maintain my dotfiles.

## Setup for Linux
	
	# Downloads and installs chezmoi in ~/bin, downloads dotfile repo, and applies it.
	sh -c "$(curl -fsLS get.chezmoi.io)" --init --apply git@github.com:bradreaves/chezmoi.git


## Setup for MacOS

For this laptop, choose **yes** for desktop/workstation apps (`isDesktop=true`)
and **yes** for a work machine (`isWork=true`) during init. The desktop choice
includes GUI laptops. Init with `--apply` renders `~/.config/Brewfile`; the
Homebrew installation step below is separate.

 1. Install [Homebrew](https://brew.sh)
 2. Install `chezmoi`: ```/opt/homebrew/bin/brew install chezmoi```
 3. If restoring Spacemacs, clone its distribution first as described below. Init and apply dotfiles: ```/opt/homebrew/bin/chezmoi init bradreaves/chezmoi --apply```
 4. Trust the [Emacs Plus tap](https://github.com/d12frosted/homebrew-emacs-plus): `/opt/homebrew/bin/brew trust d12frosted/emacs-plus`. Install Homebrew packages: `/opt/homebrew/bin/brew bundle install --file ~/.config/Brewfile`
 5. Check that `/opt/homebrew/bin/fish` is installed correctly
 6. Add `/opt/homebrew/bin/fish` to /etc/shells
 0. Sign in to Google Drive and Dropbox and sync the folders being restored.

 7. Make fish the default shell: ```chsh -s /opt/homebrew/bin/fish```
 8. Open fish shell
 9. Add new ssh keys to  `~/.ssh/authorized_keys` : `cat ~/.ssh/*.pub >> ~/.ssh/authorized_keys`

10. Run `fisher update` to get fish plugins
11. Run .config/fish/tide_config.fish to set up the terminal prompt.

10. Add ssh key to Github and NC State Github
11. Update chezmoi reporemote: `git remote set-url origin git@github.com:bradreaves/chezmoi.git`
12. Sync Chezmoi repo to GitHUb

13. Add 1Blocker, Bitwarden, Pocket, and Zotero plugins to browser
14. Setup Zotero sync and install BetterBibTool
15. Setup Lunar and Stats

The Brewfile installs `uv` through Homebrew and retains `pipx`. On this Apple
Silicon Mac, the Homebrew `uv` and `uvx` executables are under
`/opt/homebrew/bin`; avoid restoring the old installer-provided binaries over
them. Bitwarden's macOS app and its CLI are separate installations, so the
Brewfile keeps both the app and [`bitwarden-cli`](https://bitwarden.com/help/cli/).

## Restore non-Homebrew tools

After `brew bundle`, restore the scripts repository and run its tool installer:

```fish
git clone git@forgejo.llama-bass.ts.net:cqr/qol-scripts.git ~/bin/scripts
fish ~/bin/scripts/restore-tools --dry-run
fish ~/bin/scripts/restore-tools
```

If the repository already exists, use that checkout. The installer restores
Whisper `20250625`, Zotero MCP `0.13.0` with semantic search, and Playwright CLI
`0.0.63`. uv downloads Python 3.12; Whisper uses pipx, Zotero uses uv, and
Playwright uses npm under `~/.local`. Keep `~/.local/bin` on PATH. The installer
uses Homebrew's Node/npm, rather than old symlinks into the local Hermes tree.
It is an explicit step; `chezmoi init --apply` does not run it.

Do not restore DVC, vobject, Piper TTS, Ansible Dev Tools/Navigator, Yarn Classic,
the old global Claude ACP adapter, or local Hermes/browser-use. These choices
affect the fresh install; the current laptop's packages are unchanged. The
saved Emacs ACP adapters still use the separate lockfile procedure below.

These package versions record the installed snapshot; they do not lock all
dependencies. Zotero still needs its library, local API and regenerated index.
The saved Zotero MCP launcher explicitly names its Python distribution so it
can bootstrap without relying on the old installed environment. See the
[upstream Zotero instructions](https://github.com/54yyyu/zotero-mcp) and
[uv tool selectors](https://docs.astral.sh/uv/guides/tools/).

The Claude desktop cask and native Claude CLI are separate restore steps.
Install the CLI using its [official setup instructions](https://code.claude.com/docs/en/setup)
and sign in before using the agent-shell layer or scripts that invoke `claude`.

## Restore Safari web apps

Recreate these three web apps on the fresh Mac:

| App | URL |
|---|---|
| Calendar | <https://calendar.google.com/calendar/r> |
| Gmail | <https://mail.google.com/mail/> |
| iCloud Mail | <https://www.icloud.com/mail/> |

Open each URL in Safari, sign in to the desired account, then choose
**File → Add to Dock**. Open the resulting app and verify the account and
notification settings. See [Apple's web-app instructions](https://support.apple.com/en-us/104996).

Leave IMC and SIPNOC conference schedules, Discord and Mattermost out of the
restore list.

## Restore device applications

Logitech Options+ is included in the macOS desktop Brewfile. Epson Scan 2 and
the ET-2720 printer/scanner driver use Epson's model-specific installer.
Follow the [device-app restore checklist](.docket/2026-10-26-device-app-restore.md)
for setup, settings recovery and the applications excluded from reinstall.

## Restore Tailscale on macOS

The Brewfile installs the standalone desktop app using `cask "tailscale-app"`.
Use that app's bundled CLI; the restore list excludes the separate `tailscale`
formula and the Mac App Store app.

On the fresh system, open Tailscale, sign in, and approve its system extension
and VPN setup. In Tailscale Settings, find **CLI integration**, select **Show
me how**, then **Install Now**. This installs the launcher at
`/usr/local/bin/tailscale`.

Verify in a new terminal:

```sh
command -v tailscale
tailscale version
tailscale status
```

The command should resolve to `/usr/local/bin/tailscale`. Do not restore the
old `homebrew.mxcl.tailscale` daemon definition. This choice is for the fresh
OS install; the current laptop's Tailscale installation has not been migrated.

See the official [macOS variants](https://tailscale.com/docs/concepts/macos-variants)
and [CLI integration](https://tailscale.com/docs/reference/tailscale-cli?tab=macos)
instructions.

## Shared agent skills

The Shell Script Installer skill is stored once under
`~/.claude/skills/shell-script-installer`. The managed
`~/.agents/skills/shell-script-installer` symlink points to that same directory,
so Claude and Codex use the same saved version.

## Restore Codex

The portable Codex config and global instructions are managed here. Follow the
[Codex restore guide](.docket/2026-10-23-codex-restore.md) for dependencies, local
plugin repositories, credential recovery, and verification before applying the
config. Existing credentials and app-generated integration state are excluded.

## Restore Spacemacs

On a fresh machine, clone the Spacemacs distribution **before applying these
dotfiles**, so its checkout exists before chezmoi creates the private layer files:

```sh
git clone --branch develop https://github.com/syl20bnr/spacemacs.git "$HOME/.emacs.d"
```

Install Emacs, Node.js/npm, and the Claude and Codex CLIs. Chezmoi restores
`~/.spacemacs`, the customized `agent-shell` layer, its adapter manifests, and
`~/.emacs.d/private/splash.org`. Spacemacs installs the declared Emacs packages
when it starts.

After applying the dotfiles, reinstall the local ACP adapters from their lockfile:

```sh
cd "$HOME/.emacs.d/private/agent-shell/local/adapters"
npm ci --ignore-scripts
```

The adapters use the existing Claude and Codex CLI logins. Complete those logins
on the new machine; credentials are not stored in these dotfiles. Generated
`node_modules`, installed Emacs packages, caches, and session state are not managed
here.

