# README

This uses `chezmoi` to install and maintain my dotfiles.

## Setup
	
	# Downloads and installs chezmoi in ~/bin, downloads dotfile repo, and applies it.
	sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply git@github.com:bradreaves/chezmoi.git

## Todo 

- [ ] Convert setup.sh into a series of commands rather than a single long
  running script. (e.g., `setup brew` `setup fisher` etc.)
- [ ] Migrate fish prompt to something that can go into CM
- [ ] Go through /Library/Preferences and ~/Library Preferences for plists to add/set
- [ ] Make script to install brew bundle
- [ ] Confirm I want to sync plists
- [x] Set up .gitconfig
- [x] Setup Chezmoi config
- [x] Make a ~/src and ~/bin at install time
- [x] Make a brew bundle
