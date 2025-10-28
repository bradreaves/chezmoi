#!/usr/bin/env fish

# Install scripts after external repository is cloned/updated
set scripts_dir ~/bin/scripts

if test -f "$scripts_dir/.install.fish"
    echo "Installing shell scripts from ~/bin/scripts..."
    cd "$scripts_dir"
    fish .install.fish
    cd -
else
    echo "Warning: Scripts directory not found at $scripts_dir"
    echo "External repository may not be cloned yet. Run 'chezmoi update' to fetch it."
end
