---
name: Shell Script Installer
description: Use this skill when the user wants to create, write, or install shell scripts. Prefers Fish shell, handles writing fish/bash/zsh/sh scripts and installing them to ~/bin/scripts with proper permissions and git workflow. Activates when user mentions "shell script", "bash script", "fish script", "install script", or wants to create command-line utilities.
---

# Shell Script Installer Skill

This skill helps you create and install shell scripts to the user's PATH.

## When to Use This Skill

Activate this skill when the user:
- Asks to create a shell script (fish, bash, zsh, sh)
- Wants to install a script to their PATH
- Needs a command-line utility or tool
- Mentions writing executable scripts

## Shell Preference

**Default to Fish shell** for all new scripts unless:
- User explicitly requests bash/zsh/sh
- Building on or extending an existing bash script
- The script requires bash-specific features not available in Fish
- There's a compelling compatibility reason (e.g., sharing with non-Fish users)

## Installation Directory

Install all scripts to: `~/bin/scripts`

**IMPORTANT:** `~/bin/scripts` is a git repository. All script creation and editing must use proper git workflow.

## Workflow

Follow these steps in order:

### 1. Understand Requirements
- Ask what the script should do
- Determine the script name (without extension)
- Determine shell interpreter (default: **fish**, fallback to bash only if necessary)

### 2. Set Up Git Workspace
- Navigate to the scripts repository: `cd ~/bin/scripts`
- Check current git status to ensure clean state
- Create a new branch for this script: `git checkout -b add-<script-name>`
- The branch name should be descriptive (e.g., `add-backup-tool`, `add-git-helper`)

### 3. Write the Script
- Create the script in the repository: `~/bin/scripts/<script-name>`
- Include proper shebang line:
  - For Fish: `#!/usr/bin/env fish`
  - For Bash: `#!/usr/bin/env bash`
- Add helpful comments
- Include error handling where appropriate
- Follow shell scripting best practices for the chosen shell

### 4. Review with User
- Show the complete script to the user
- Explain what it does
- Ask if they'd like to make any changes

### 5. Iterate (if needed)
- If user requests changes, edit the script in place
- Each iteration happens on the same git branch
- Repeat review until user is satisfied

### 6. Test (Interactive)
- Ask the user if they want to test the script before committing
- Make the script executable: `chmod +x ~/bin/scripts/<script-name>`
- Offer a test command or let them test manually
- Review test results with the user
- If tests fail, go back to iteration (step 5)

### 7. Commit and Merge
- Ask for confirmation: "Ready to commit and install `<script-name>`?"
- If confirmed:
  - Stage the script: `git add <script-name>`
  - Commit with **detailed structured message** (see "Git Commit Message Standards" section below)
    - Include Features section listing all capabilities
    - Include Technical details section with implementation notes
    - Include Co-Authored-By attribution for AI assistance
  - Switch back to main branch: `git checkout main`
  - Merge the feature branch: `git merge add-<script-name>`
  - **REQUIRED: Delete the feature branch:** `git branch -d add-<script-name>`
    - **CRITICAL:** Always delete merged feature branches to keep the repository clean
    - Never leave merged branches lingering in the repository
    - This is mandatory, not optional

### 8. Verify PATH
- Check if ~/bin/scripts is in the user's PATH
- If not, inform the user and provide instructions to add it:
  ```fish
  # For Fish: add to ~/.config/fish/config.fish
  fish_add_path $HOME/bin/scripts
  ```
  ```bash
  # For bash: add to ~/.bashrc or ~/.bash_profile
  # For zsh: add to ~/.zshrc
  export PATH="$HOME/bin/scripts:$PATH"
  ```

### 9. Final Verification
- Test that the script is accessible: `which <script-name>`
- Provide usage instructions
- Suggest restarting the shell or sourcing the config if PATH was just updated

## Structured Logging Standards

**CRITICAL:** All scripts must implement structured logging using the `logger` command.

### Logging Format
- Use `logger` command with structured key=value format
- Tag format: `scriptname[PID]` (use `$$` for PID in bash, `$fish_pid` in fish)
- **IMPORTANT:** In Fish, always use `$fish_pid` to get the process ID, NOT `$$` or `%self`
- Preserve user-facing output (echo/printf) while adding diagnostic logging to syslog

### Log Level Mapping
Map script events to appropriate log levels:

- **`user.info`**: Process status, file operations, success events
  - Example: "Processing file", "Operation completed successfully"

- **`user.warning`**: Unsupported formats, non-critical issues, recoverable errors
  - Example: "Unsupported file format", "Feature not available"

- **`user.error`**: Missing dependencies, failures, exit conditions
  - Example: "Required tool not found", "Failed to write file"

- **`user.debug`**: File creation, skipped files, detailed operations
  - Example: "Created directory", "Skipping cached file"

### Logging Examples

**Fish:**
```fish
logger -t (basename (status filename))"[$fish_pid]" -p user.info "action=start status=processing"
logger -t (basename (status filename))"[$fish_pid]" -p user.error "action=fail error=\"missing dependency\""
```

**Bash:**
```bash
logger -t "$(basename "$0")[$$]" -p user.info "action=start status=processing"
logger -t "$(basename "$0")[$$]" -p user.error "action=fail error=\"missing dependency\""
```

## Best Practices

### CLI Standards (REQUIRED)
- **Always include `--help` / `-h` argument** with usage information
- **Always include `--version` / `-v` argument** showing script version
- **Always include `--test` argument** that runs unit and regression tests of the code
- **Always include `--fish-completions` argument** that installs fish shell tab completions to `~/.config/fish/completions/<script-name>.fish`
  - Completions must include all flags (--help, --version, --test, --fish-completions, and any script-specific flags)
  - Completions should include context-aware argument completion where applicable
  - Must error if completion file already exists (prevents accidental overwrite)
- Document all command-line options clearly
- Follow standard Unix conventions for flags and arguments

### Installation Documentation (REQUIRED)
- **Include installation instructions in a comment** at the top of every script
- Scripts should be self-documenting about where they belong in the filesystem
- Examples:
  - Standalone command-line tool: `# Installation: Copy to ~/bin/scripts`
  - Fish function that needs to be sourced: `# Installation: Copy to ~/.config/fish/functions`
  - Shell configuration addon: `# Installation: Source from ~/.config/fish/config.fish or ~/.bashrc`
- Make it clear if there are any post-installation setup steps required

### For Fish Scripts (Preferred)
- Use `#!/usr/bin/env fish` for portability
- Include usage/help information with `--help` and `--version` flags
- Use Fish's built-in error handling and status checks
- Leverage Fish's modern syntax and features (argparse, functions)
- Make scripts user-friendly with clear error messages
- Avoid hardcoded paths when possible
- **Implement structured logging** as described above

### For Bash Scripts (When Necessary)
- Use `#!/usr/bin/env bash` for portability
- Include usage/help information with `--help` and `--version` flags
- Add error handling with `set -e` or appropriate error checks
- Follow bash best practices
- **Implement structured logging** as described above

### Path Handling
- **Be careful with `cd` commands**: When scripts change directories, subsequent operations with relative paths may break
- Use absolute paths when possible, especially after directory changes
- Store original working directory if you need to return: `set origin_dir (pwd)` (fish) or `origin_dir=$(pwd)` (bash)
- Test path resolution thoroughly, especially in refactored code

### Tool Design Philosophy
- **Make tools general-purpose** rather than solution-specific when possible
- Design for reusability and composability
- Separate concerns: one tool should do one thing well
- Consider how the tool might be used in different contexts

### Configuration Management
- **Separate configuration from code** whenever practical
- Extract prompts, templates, and settings to separate files
- Use environment variables or config files for user-customizable values
- Document configuration options clearly

### Testing Requirements
- **Test thoroughly after major refactoring**, especially:
  - Path resolution and file access
  - Directory changes and relative paths
  - Error handling and edge cases
  - All command-line flags and options
- Verify structured logging outputs correct levels and formats
- Test with both valid and invalid inputs

## Example Script Templates

### Fish Script Template (Preferred)

```fish
#!/usr/bin/env fish

# Script: example-script
# Version: 1.0.0
# Description: What this script does
# Installation: Copy to ~/bin/scripts

set VERSION "1.0.0"
set SCRIPT_NAME (basename (status filename))

function log_info
    logger -t "$SCRIPT_NAME[$fish_pid]" -p user.info $argv
end

function log_error
    logger -t "$SCRIPT_NAME[$fish_pid]" -p user.error $argv
end

function log_debug
    logger -t "$SCRIPT_NAME[$fish_pid]" -p user.debug $argv
end

function show_version
    echo "$SCRIPT_NAME version $VERSION"
    exit 0
end

function run_tests
    log_info "action=test status=starting"

    # Add unit and regression tests here
    echo "Running unit tests..."

    # Example test placeholder
    # Replace with actual test logic
    echo "All tests passed!"

    log_info "action=test status=complete"
    exit 0
end

function install_fish_completions
    set -l completions_file ~/.config/fish/completions/$SCRIPT_NAME.fish

    # Check if file already exists
    if test -f "$completions_file"
        echo "Error: Completions file already exists: $completions_file" >&2
        echo "Remove it first if you want to regenerate completions." >&2
        exit 1
    end

    # Ensure directory exists
    mkdir -p ~/.config/fish/completions

    # Generate and write completions
    echo "# Fish completions for $SCRIPT_NAME
# Generated by $SCRIPT_NAME --fish-completions

# Complete flags
complete -c $SCRIPT_NAME -s h -l help -d 'Show help message'
complete -c $SCRIPT_NAME -s v -l version -d 'Show version information'
complete -c $SCRIPT_NAME -l test -d 'Run unit and regression tests'
complete -c $SCRIPT_NAME -l fish-completions -d 'Install fish shell completions'

# Add script-specific completions here
" > "$completions_file"

    and begin
        echo "Fish completions installed to: $completions_file"
        echo ""
        echo "Completions will be available in new fish shell sessions."
        echo "To use them immediately in this session, run:"
        echo "  source $completions_file"
    end
    or begin
        echo "Error: Failed to write completions file" >&2
        exit 1
    end

    exit 0
end

function usage
    echo "Usage: $SCRIPT_NAME [options]"
    echo ""
    echo "Description: What this script does"
    echo ""
    echo "Options:"
    echo "  -h, --help            Show this help message"
    echo "  -v, --version         Show version information"
    echo "  --test                Run unit and regression tests"
    echo "  --fish-completions    Install fish shell completions"
    exit 0
end

function main
    log_info "action=start status=processing"

    # Your script logic here
    echo "Hello from example Fish script!"

    log_info "action=complete status=success"
end

# Parse arguments
argparse 'h/help' 'v/version' 'test' 'fish-completions' -- $argv
or begin
    usage
end

if set -q _flag_help
    usage
end

if set -q _flag_version
    show_version
end

if set -q _flag_test
    run_tests
end

if set -q _flag_fish_completions
    install_fish_completions
end

log_debug "action=init args=\"$argv\""
main
```

### Bash Script Template (Fallback)

```bash
#!/usr/bin/env bash
set -e

# Script: example-script
# Version: 1.0.0
# Description: What this script does
# Installation: Copy to ~/bin/scripts

VERSION="1.0.0"
SCRIPT_NAME="$(basename "$0")"

log_info() {
    logger -t "${SCRIPT_NAME}[$$]" -p user.info "$@"
}

log_error() {
    logger -t "${SCRIPT_NAME}[$$]" -p user.error "$@"
}

log_debug() {
    logger -t "${SCRIPT_NAME}[$$]" -p user.debug "$@"
}

show_version() {
    echo "$SCRIPT_NAME version $VERSION"
    exit 0
}

run_tests() {
    log_info "action=test status=starting"

    # Add unit and regression tests here
    echo "Running unit tests..."

    # Example test placeholder
    # Replace with actual test logic
    echo "All tests passed!"

    log_info "action=test status=complete"
    exit 0
}

install_fish_completions() {
    local completions_file=~/.config/fish/completions/$SCRIPT_NAME.fish

    # Check if file already exists
    if [[ -f "$completions_file" ]]; then
        echo "Error: Completions file already exists: $completions_file" >&2
        echo "Remove it first if you want to regenerate completions." >&2
        exit 1
    fi

    # Ensure directory exists
    mkdir -p ~/.config/fish/completions

    # Generate and write completions
    cat > "$completions_file" << 'EOF'
# Fish completions for $SCRIPT_NAME
# Generated by $SCRIPT_NAME --fish-completions

# Complete flags
complete -c $SCRIPT_NAME -s h -l help -d 'Show help message'
complete -c $SCRIPT_NAME -s v -l version -d 'Show version information'
complete -c $SCRIPT_NAME -l test -d 'Run unit and regression tests'
complete -c $SCRIPT_NAME -l fish-completions -d 'Install fish shell completions'

# Add script-specific completions here
EOF

    if [[ $? -eq 0 ]]; then
        echo "Fish completions installed to: $completions_file"
        echo ""
        echo "Completions will be available in new fish shell sessions."
        echo "To use them immediately in this session, run:"
        echo "  source $completions_file"
    else
        echo "Error: Failed to write completions file" >&2
        exit 1
    fi

    exit 0
}

usage() {
    echo "Usage: $SCRIPT_NAME [options]"
    echo ""
    echo "Description: What this script does"
    echo ""
    echo "Options:"
    echo "  -h, --help            Show this help message"
    echo "  -v, --version         Show version information"
    echo "  --test                Run unit and regression tests"
    echo "  --fish-completions    Install fish shell completions"
    exit 0
}

main() {
    log_info "action=start status=processing"

    # Your script logic here
    echo "Hello from example bash script!"

    log_info "action=complete status=success"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -v|--version)
            show_version
            ;;
        --test)
            run_tests
            ;;
        --fish-completions)
            install_fish_completions
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
    shift
done

log_debug "action=init args=\"$*\""
main
```

## Troubleshooting

- **Script not found after install:** Check PATH and restart shell or source config
- **Permission denied:** Verify `chmod +x` was applied to the script
- **Command not found:** Ensure `~/bin/scripts` is in PATH
- **Git merge conflicts:** If conflicts occur, resolve manually or abort with `git merge --abort`
- **Dirty git state:** If repository has uncommitted changes, stash them first with `git stash`
- **Branch already exists:** Delete the old branch with `git branch -D add-<script-name>` or use a different name

## Git Workflow Notes

- Always work on a feature branch (never directly on main)
- Each new script gets its own branch: `add-<script-name>`
- **MANDATORY: Always delete feature branches after merging** - this is required, not optional
- Clean branches keep the repository organized and prevent confusion about what's in progress
- If you need to abandon a script, delete the branch without merging: `git checkout main && git branch -D add-<script-name>`

### Git Commit Message Standards

**IMPORTANT:** Use detailed, structured commit messages with the following format:

```
Add <script-name>: <brief one-line description>

Features:
- Feature 1 with details
- Feature 2 with details
- Feature 3 with details

Technical details:
- Implementation detail 1
- Implementation detail 2
- Configuration or dependency notes

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Guidelines:**
- **Subject line**: Start with "Add <script-name>:" followed by brief description
- **Features section**: List all user-facing features and capabilities
- **Technical details section**: Include implementation notes, technologies used, dependencies
- **Co-authorship**: Always include AI assistance attribution
- Use bullet points for clarity
- Be specific about what was implemented
- Include any important configuration or setup notes

**Example:**
```
Add backup-tool: Automated backup script with compression and rotation

Features:
- Automatic backup of specified directories
- Gzip compression with configurable level
- Rotation policy (keeps last N backups)
- Email notifications on completion or failure
- Dry-run mode for testing

Technical details:
- Implemented in Fish shell with structured logging
- Uses rsync for efficient file copying
- Logger integration for syslog monitoring
- Configuration via environment variables
- Requires: rsync, gzip, mail utilities

Co-Authored-By: Claude <noreply@anthropic.com>
```
