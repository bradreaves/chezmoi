# Restore Codex after reinstall

This guide accompanies `dot_codex/private_config.toml.tmpl`. Chezmoi restores
the reviewed model, interface and plugin preferences, custom MCP definitions,
and global `AGENTS.md`. The live laptop configuration was left unchanged.

## Install prerequisites on macOS

Install Homebrew and chezmoi using the repository README, then install the
dependencies below. These are explicit restore steps; this change does not
update the Brewfile or run an installer automatically.

```sh
brew install uv node gh
```

Install the ChatGPT desktop app and its Codex integration using the current
official installer, and sign in again. Confirm `codex`, `uvx` and `npx` are
available. The template uses `/opt/homebrew/bin` on Apple Silicon and
`/usr/local/bin` on Intel Macs. Its npx servers receive that directory on PATH
so Node can also be found when launched from a desktop application.
On Linux, install uv into `~/.local/bin`, and put Node/npm's `npx` on PATH.

## Restore local plugin sources

Restore these before starting Codex with the saved configuration:

| Marketplace | Required source |
|---|---|
| `bgr-claude-plugins` | `~/src/bgr-claude-plugins`, origin `ssh://git@forgejo.llama-bass.ts.net/cqr/bgr-claude-plugins.git` |
| `teaching-tools` | NC State Google Drive: `My Drive/_Teaching/teaching-tools` |
| `claude-plugins-official` | `https://github.com/anthropics/claude-plugins-official.git` |
| `marimo-pair` | `https://github.com/marimo-team/marimo-pair.git` |

The saved local paths follow the new home directory. The teaching-tools path
still assumes the same Google Drive account and directory layout; edit that
source if Drive uses a different mount path. Wait for Drive to download the
teaching-tools files. Its availability has not been verified off this laptop.

Plugin enablement choices are saved. Plugin caches, revision/update records,
and the app's bundled marketplace paths are regenerated. Use the app's plugin
manager to restore missing plugins, and authenticate connected services again.

## Custom MCP dependencies

`uvx` and `npx` fetch their packages on first use, so internet access is needed.
The `mcp<2` constraint and the two `@latest` selectors are retained. Zotero's
distribution is explicitly selected as `zotero-mcp-server[semantic]==0.13.0`
with Python 3.12; the command it provides is named `zotero-mcp`. Other package
versions and transitive dependencies are not locked by this backup.

| Server | Saved launcher/package | Additional prerequisite |
|---|---|---|
| `mcp-obsidian` | `uvx --with 'mcp<2' mcp-obsidian` | Restore the vault and enable Obsidian's Local REST API plugin; provide `OBSIDIAN_API_KEY`. |
| `time` | `uvx --with 'mcp<2' mcp-server-time` | Timezone remains `America/New_York`. |
| `whois` | `npx -y @bharathvaj/whois-mcp@latest` | Network access for WHOIS queries. |
| `zotero` | `uvx --python 3.12 --with 'mcp<2' --from 'zotero-mcp-server[semantic]==0.13.0' zotero-mcp` | Install Zotero, restore/sync the library and attachments, enable its local API, and open Zotero. Local mode and the default embedding model are retained; caches are regenerated. |
| `github` | `https://api.githubcopilot.com/mcp/` | Provide `GITHUB_PERSONAL_ACCESS_TOKEN` with permissions appropriate to the repositories/tools used. |
| `powerpoint-web` | `npx -y @playwright/mcp@latest --isolated` | Install the required Playwright browser when prompted; isolated browser sessions need fresh sign-in. |

The app-generated `node_repl`, computer-use server, notification executable,
trusted-browser hashes and bundled runtime paths are deliberately omitted.
Reinstall/enable the desktop app's computer-use integration and the Herdr
integration through their own setup flows. The disabled old computer-use
server is not restored. Trust projects and hook code again after reviewing it.

## Recover credentials without putting them in Git

The old Obsidian key is not saved here. After restoring Obsidian, obtain or
regenerate a key in the Local REST API plugin's settings. Store it in Bitwarden
if desired; the exact old key is not required when a new key can be generated.
For GitHub, recover a suitable token from your password manager or create a new
one. Neither credential recovery nor off-device secret backup is verified by
this change. Codex login credentials are also excluded; sign in again.

For a terminal session, run the following in **Bash**. The prompts hide input
and keep the credential values out of shell history:

```bash
read -r -s -p 'Obsidian API key: ' OBSIDIAN_API_KEY
printf '\n'
export OBSIDIAN_API_KEY
read -r -s -p 'GitHub MCP token: ' GITHUB_PERSONAL_ACCESS_TOKEN
printf '\n'
export GITHUB_PERSONAL_ACCESS_TOKEN
codex
```

The saved Obsidian server uses `env_vars = ["OBSIDIAN_API_KEY"]`; GitHub uses
`bearer_token_env_var = "GITHUB_PERSONAL_ACCESS_TOKEN"`. Exporting these in one
terminal does not configure an already-running app or a Finder-launched app.
Use an environment-aware launcher for the desktop app if these MCP servers
are needed there. Do not paste the keys back into the managed config.

## Apply and verify

After installing dependencies and restoring the local sources, review and
apply the configuration explicitly:

```sh
chezmoi diff ~/.codex/config.toml ~/.codex/AGENTS.md
chezmoi apply --parent-dirs ~/.codex/config.toml ~/.codex/AGENTS.md
codex login
codex mcp list
codex plugin marketplace list
```

On the current laptop, the first diff can display the existing plaintext key;
review it locally and do not paste it into logs or chat. Applying replaces the
live config with the portable baseline, so review app-generated additions
before applying again. The template does not merge future live changes.

Test each desired MCP connection after restoring credentials and opening its
application. A config parse and list check does not establish that external
services authenticate or that the whole reinstall works. The saved template
was checked in a separate temporary home; no fresh OS reinstall was performed.

Official references: [Codex MCP configuration](https://learn.chatgpt.com/docs/extend/mcp?surface=cli)
documents forwarding environment variables and bearer-token variables;
[plugin packaging and marketplaces](https://developers.openai.com/plugins/build/plugins)
documents marketplace sources, caches and plugin enablement.
