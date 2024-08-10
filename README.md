# README

This uses `chezmoi` to install and maintain my dotfiles.

## Setup
	
	# Downloads and installs chezmoi in ~/bin, downloads dotfile repo, and applies it.
	sh -c "$(curl -fsLS get.chezmoi.io)" --init --apply git@github.com:bradreaves/chezmoi.git

## Roadmap 

- [ ] Convert setup.sh into a series of commands rather than a single long
  running script. (e.g., `setup brew` `setup fisher` etc.)
- [ ] Make script to install brew bundle
- [ ] Confirm I want to sync plists
- [ ] Go through /Library/Preferences and ~/Library Preferences for plists to add/set


## Done
- [x] Set up .gitconfig
- [x] Setup Chezmoi config
- [x] Make a ~/src and ~/bin at install time
- [x] Make a brew bundle
- [x] Migrate fish prompt to something that can go into CM

