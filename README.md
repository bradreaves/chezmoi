# README

This uses `chezmoi` to install and maintain my dotfiles.

## Setup for Linux
	
	# Downloads and installs chezmoi in ~/bin, downloads dotfile repo, and applies it.
	sh -c "$(curl -fsLS get.chezmoi.io)" --init --apply git@github.com:bradreaves/chezmoi.git


## Setup for MacOS

 1. Install [Homebrew](https://brew.sh)
 2. Install `chezmoi`: ```/opt/homebrew/bin/brew install chezmoi```
 3. Init and  apply dotfiles: ```/opt/homebrew/bin/chezmoi init bradreaves/chezmoi --apply```
 4. Install Homebrew packages: ```/opt/homebrew/bin/brew bundle install --file ~/.config/Brewfile```
 5. Check that `/opt/homebrew/bin/fish` is installed correctly
 6. Add `/opt/homebrew/bin/fish` to /etc/shells
 0. Start Insync to pull down Google Drive content

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

