# README

This uses `chezmoi` to install and maintain my dotfiles.

## Setup
	
	# Downloads and installs chezmoi in ~/bin, downloads dotfile repo, and applies it.
	sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply git@github.com:bradreaves/chezmoi.git

## Todo 

- [ ] Make a ~/src and ~/bin at install time
- [ ] Set linux and macOS profiles
- [ ] Make a brew bundle
- [ ] Setup a function to install the brew bundle
- [ ] Setup a function to install nerd fonts
- [ ] Go through /Library/Preferences and ~/Library Preferences for plists to add/set
- [ ] Set up .gitconfig
