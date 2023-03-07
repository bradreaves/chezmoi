# README

This uses `chezmoi` to install and maintain my dotfiles.

## Setup
	
	# Downloads and installs chezmoi in ~/bin, downloads dotfile repo, and applies it.
	sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply git@github.com:bradreaves/chezmoi.git

## Todo 

- [ ] Set up .gitconfig
- [ ] Go through /Library/Preferences and ~/Library Preferences for plists to add/set
- [ ] Make script to install brew bundle
- [x] Setup Chezmoi config
- [x] Make a ~/src and ~/bin at install time
- [x] Make a brew bundle
