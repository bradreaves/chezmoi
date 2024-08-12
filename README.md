# README

This uses `chezmoi` to install and maintain my dotfiles.

## Roadmap 

- [ ] Convert setup.sh into a series of commands rather than a single long
  running script. (e.g., `setup brew` `setup fisher` etc.)
- [ ] Make script to install brew bundle
- [ ] Confirm I want to sync plists
- [ ] Go through /Library/Preferences and ~/Library Preferences for plists to add/set
- [ ] Fix `chezmoi.toml.tmpl` to make "isDesktop" true if on MacOS


## Done
- [x] Set up .gitconfig
- [x] Setup Chezmoi config
- [x] Make a ~/src and ~/bin at install time
- [x] Make a brew bundle
- [x] Migrate fish prompt to something that can go into CM

## Setup for Linux
	
	# Downloads and installs chezmoi in ~/bin, downloads dotfile repo, and applies it.
	sh -c "$(curl -fsLS get.chezmoi.io)" --init --apply git@github.com:bradreaves/chezmoi.git


## Setup for MacOS

 1. Install [Homebrew](https://brew.sh)
 2. Install `chezmoi`: ```/opt/homebrew/bin/brew install chezmoi```
 3. Init and  apply dotfiles: ```/opt/homebrew/bin/chezmoi init bradreaves/chezmoi --apply```
 4. Install Homebrew packages: ```/opt/homebrew/bin/brew bundle install --file ~/.config/Brewfile```

 0. Start Insync to pull down Google Drive content

 5. Check that `/opt/homebrew/bin/fish` is installed correctly
 6. Add `/opt/homebrew/bin/fish` to /etc/shells
 7. Make fish the default shell: ```chsh -s /opt/homebrew/bin/fish```
 8. Open fish shell
 9. Generate ssh keys and add them to  `~/.ssh/authorized_keys`



10. Add ssh key to Github and NC State Github
11. Update chezmoi reporemote 
12. Sync Chezmoi repo to GitHUb

13. Add 1Blocker, Bitwarden, Pocket, and Zotero plugins to browser
14. Setup Zotero sync and install BetterBibTool
15. Setup Lunar and Stats

