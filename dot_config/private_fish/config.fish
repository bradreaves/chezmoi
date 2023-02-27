if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Brad Reaves handy functions/abbreviations


## nvim management

function vim --wraps=nvim --description 'alias vim=nvim'
  nvim $argv
end

function vi --wraps=nvim --description 'alias vi=nvim'
  nvim $argv
end

# Get to old vim if nvim gets borked
function oldvim --wraps=nvim --description 'alias oldvim=/usr/bin/vim'
  /usr/bin/vim $argv
end

## SSH helper functions

### Copy ssh key to clipboard
abbr --add cpsshkey "cat ~/.ssh/id_ecdsa.pub | pbcopy"

## Notes for future

# Checking for OS: https://github.com/fish-shell/fish-shell/issues/8203
# See also "fish-core-utils" plugin -- has a is:macos function (etc)


## Other aliases

abbr --add cm "chezmoi"
abbr --add cmcd "cd /Users/bgr/.local/share/chezmoi" # Go to chezmoi directory

abbr --add gofish "source ~/.config/fish/conf.d/*"
