# Shell Script Skill Analysis & Recommendations

**NOTE:** For Fish-specific errors and best practices, see `~/fish-shell-rules.md` which documents recurring Fish shell bugs from this project's commit history.

## Common Errors Claude Makes When Building Shell Scripts

### 1. **I/O Stream Confusion**
**Error:** Mixing data output with user messages (both going to stdout)
```fish
# WRONG - breaks pipes
echo "Processing file..."
echo "result-data"
```

```fish
# CORRECT - separate streams
echo "Processing file..." >&2  # Progress to stderr
echo "result-data"              # Data to stdout
```

**Why it matters:** When piping scripts together, stdout is captured by the next command. Progress messages should go to stderr so they don't pollute the data stream.

### 2. **Input Handling Issues**

#### Not Supporting Both File and Stdin
**Error:** Only accepting file arguments, not stdin
```fish
# WRONG - rigid input
function main
    set file $argv[1]
    cat $file
end
```

```fish
# CORRECT - flexible input
function main
    set input_file "-"
    if test (count $argv) -gt 0
        set input_file $argv[1]
    end

    if test "$input_file" = "-"
        cat  # Read from stdin
    else
        cat $input_file
    end
end
```

#### Not Following "-" Convention
**Error:** Not treating "-" as stdin/stdout placeholder
- By Unix convention, "-" should mean stdin for input and stdout for output

### 3. **Output Handling Issues**

#### No Output File Option
**Error:** Only writing to stdout or only to files, not supporting both
```fish
# WRONG - inflexible
echo $result  # Always stdout only
```

```fish
# CORRECT - user choice
set output_file "-"
if set -q _flag_output
    set output_file $_flag_output
end

if test "$output_file" = "-"
    echo $result  # stdout
else
    echo $result > "$output_file"  # file
end
```

#### Not Supporting Append Mode
**Error:** Always overwriting files instead of offering append option
- Should provide `-a/--append` flag when dealing with output files

### 4. **Pipe Compatibility Issues**

#### Interactive Prompts in Pipeable Scripts
**Error:** Including interactive prompts in scripts designed for piping
```fish
# WRONG - breaks pipes
read -P "Continue? (y/n): " answer
```

**Solution:** Use flags for all options, avoid interactive prompts in data-processing scripts

#### Not Handling Broken Pipes
**Error:** Scripts crash when downstream command exits early
```fish
# WRONG - may error on broken pipe
for item in $big_list
    echo $item
end
```

**Solution:** Fish handles this gracefully, but be aware of the pattern

### 5. **Path Resolution Problems**

#### Relative Paths After `cd`
**Error:** Using relative paths after changing directories
```fish
# WRONG
cd /some/directory
cat config.txt  # Where is this file now?
```

```fish
# CORRECT - store original directory
set origin_dir (pwd)
cd /some/directory
# ... do work ...
cd $origin_dir
cat config.txt  # Now we know where we are
```

#### Better: Use Absolute Paths
```fish
# BEST - avoid cd when possible
set config_file /some/directory/config.txt
cat $config_file
```

### 6. **Error Handling Gaps**

#### Not Checking Exit Codes
**Error:** Assuming commands succeed
```fish
# WRONG
curl $url > data.json
process_file data.json
```

```fish
# CORRECT
curl $url > data.json
if test $status -ne 0
    log_error "action=download status=failed url=\"$url\""
    exit 1
end
```

#### Not Using Appropriate Exit Codes
**Error:** Always exiting with `exit 1` or no exit code
```fish
# CORRECT - semantic exit codes
exit 0  # Success
exit 1  # General error
exit 2  # Usage error (bad arguments)
exit 3  # Dependency missing
```

#### Silent Failures
**Error:** Not logging errors or providing user feedback
```fish
# WRONG
if not command -v tool
    exit 1  # User has no idea what happened
end
```

```fish
# CORRECT
if not command -v tool
    echo "Error: 'tool' is not installed" >&2
    echo "Install with: brew install tool" >&2
    log_error "action=dependency_check status=missing tool=tool"
    exit 3
end
```

### 7. **Argument Parsing Issues**

#### Inconsistent Flag Names
**Error:** Not following Unix conventions
- Use `-h/--help`, `-v/--version`, `-o/--output`, `-a/--append`
- Be consistent across all scripts

#### Not Validating Flag Combinations
**Error:** Allowing invalid flag combinations
```fish
# Should validate
if test $append_mode -eq 1 -a "$output_file" = "-"
    echo "Error: --append requires --output to specify a file" >&2
    exit 2
end
```

### 8. **Testing Oversights**

#### Not Testing Edge Cases
- Empty input
- Missing files
- Invalid arguments
- Pipe input/output
- Append mode behavior
- Duplicate handling

#### Not Testing Actual Behavior
**Error:** Test stubs that don't validate real functionality
```fish
# WRONG
function run_tests
    echo "Tests pass!"
    exit 0
end
```

```fish
# CORRECT - actual tests (see yt-meta for examples)
function run_tests
    echo -n "Test 1: URL extraction... "
    set test_input "Check out https://example.com"
    set result (echo $test_input | string match -ra 'https?://\S+')
    if test (count $result) -eq 1
        echo "✓ PASS"
    else
        echo "✗ FAIL"
        exit 1
    end
end
```

### 9. **Documentation Gaps**

#### Unclear Usage Examples
**Error:** Not showing pipe usage in help text
```fish
# Add to usage():
echo "Examples:"
echo "  $SCRIPT_NAME input.txt -o output.txt"
echo "  cat input.txt | $SCRIPT_NAME"
echo "  $SCRIPT_NAME -o out.txt < input.txt"
```

#### Missing Output Format Documentation
**Error:** Not explaining what the output looks like
- Document output format in --help
- Explain TSV/CSV column structure
- Show example output

### 10. **Variable Naming Issues**

#### Unclear Variable Names
```fish
# WRONG
set f "-"  # What does this mean?
```

```fish
# CORRECT
set input_file "-"
set output_file "-"
```

## Standard Input/Output Specification

Based on **yt-meta** pattern, all data-processing scripts should follow:

### Input Standards

1. **Default to stdin** if no file argument provided
2. **Accept file argument** as positional parameter
3. **Support "-" explicitly** as stdin placeholder
4. **Validate file exists** before processing (if not stdin)

```fish
# Standard input pattern
set input_file "-"
if test (count $argv) -gt 0
    set input_file $argv[1]

    if test "$input_file" != "-" -a ! -f "$input_file"
        echo "Error: Input file not found: $input_file" >&2
        log_error "action=read_input status=not_found file=\"$input_file\""
        exit 2
    end
end
```

### Output Standards

1. **Default to stdout** (output_file = "-")
2. **Provide `-o/--output FILE`** flag for file output
3. **Provide `-a/--append`** flag for append mode
4. **Validate append+output combination**

```fish
# Standard output pattern
set output_file "-"
set append_mode 0

argparse 'o/output=' 'a/append' -- $argv
if set -q _flag_output
    set output_file $_flag_output
end
if set -q _flag_append
    set append_mode 1
end

# Validate
if test $append_mode -eq 1 -a "$output_file" = "-"
    echo "Error: --append requires --output to specify a file" >&2
    exit 2
end

# Write output
if test "$output_file" = "-"
    echo $result  # stdout
else
    if test $append_mode -eq 1
        echo $result >> "$output_file"
    else
        echo $result > "$output_file"
    end
end
```

### Stream Separation

**Critical Rule:** stdout = data, stderr = messages

```fish
# Progress messages
echo "Processing 100 items..." >&2

# Warnings
echo "Warning: Skipped invalid entry" >&2

# Errors
echo "Error: Failed to process item" >&2

# Data output (no >&2)
echo -e "$url\t$title\t$format"
```

## Pipe Support Standards

### Design Principles

1. **Silent by default** when reading from pipe
2. **Provide verbose flag** for progress output
3. **Never prompt for user input** in pipe mode
4. **Handle broken pipes gracefully**
5. **Design for composability** (output should be valid input for similar scripts)

### Pipe Detection

```fish
# Check if stdin is a pipe/redirect
if not isatty stdin
    # Reading from pipe - be quiet
    set verbose 0
else
    # Interactive - can show progress
    set verbose 1
end
```

### Progress Output Pattern (REQUIRED for Multi-Item Processing)

**For scripts that iterate over multiple items or perform long-running operations, use non-scrolling in-place progress updates:**

```fish
# Auto-detect interactive vs batch mode
set progress_mode 0
if isatty stderr
    set progress_mode 1  # Interactive - show progress by default
end

# Parse flags (in argparse)
argparse 'progress' 'no-progress' -- $argv

# Explicit flags override auto-detection
if set -q _flag_progress
    set progress_mode 1
end
if set -q _flag_no_progress
    set progress_mode 0
end

# In processing loop:
set current 0
set total (count $items)

for item in $items
    set current (math $current + 1)

    if test $progress_mode -eq 1
        # Non-scrolling in-place update (\r returns to start of line)
        printf "\r[%d/%d] %s" $current $total "$item" >&2
    end

    # ... do work ...
end

# Final newline to complete the progress line
if test $progress_mode -eq 1
    printf "\n" >&2
end

# Summary stats to stderr (always show, even in no-progress mode)
echo "Results: $valid valid, $invalid invalid" >&2
```

**Flags:**
- `--progress`: Force in-place progress updates (even in batch mode)
- `--no-progress`: Suppress progress updates (even in interactive mode)
- Default: Auto-detect based on `isatty stderr` (interactive = progress on, batch = progress off)

### Chain-Friendly Output Format

Use consistent, parseable formats:
- **TSV/CSV** for structured data
- **One-per-line** for lists
- **JSON** for complex data (if jq available)

```fish
# Example: URL list output
echo $url  # One URL per line, easy to pipe to next tool

# Example: Structured output
echo -e "$url\t$title\t$format"  # TSV, can be cut/awk'd
```

## Recommended Script Template Updates

### Enhanced Input Handling Function

```fish
function get_input_stream
    # Returns input content from file or stdin
    # Usage: set data (get_input_stream $input_file)

    set input_file $argv[1]

    if test "$input_file" = "-"
        cat  # Read from stdin
    else
        if not test -f "$input_file"
            echo "Error: Input file not found: $input_file" >&2
            log_error "action=read_input status=not_found file=\"$input_file\""
            return 1
        end
        cat $input_file
    end
end
```

### Enhanced Output Handling Function

```fish
function write_output
    # Writes data to file or stdout
    # Usage: echo $data | write_output $output_file $append_mode

    set output_file $argv[1]
    set append_mode $argv[2]

    if test "$output_file" = "-"
        cat  # Write to stdout
    else
        if test $append_mode -eq 1
            cat >> "$output_file"
        else
            cat > "$output_file"
        end
    end
end
```

## TSV Output Format Standard

For scripts that output structured data, use TSV with:

1. **Tab-separated values** (not CSV, easier to parse with cut/awk)
2. **No header row** (easier to pipe and append)
3. **Consistent column order** across related scripts
4. **Empty string for missing values** (not "null" or "N/A")

```fish
# Example TSV output
echo -e "$url\t$title\t$format\t$notes"
```

### Sorting and Deduplication

For list-based output:
- **Sort by relevant field** for grouping
- **Support --unique** flag to deduplicate
- **Preserve user order** when sorting doesn't make sense

## Required Flags for Data-Processing Scripts

All data-processing scripts (scripts that transform input to output) MUST include:

1. `-h/--help` - Usage information with examples
2. `-v/--version` - Version display
3. `-o/--output FILE` - Output file (default: stdout)
4. `-a/--append` - Append to file (requires -o)
5. `--test` - Run unit tests
6. `--fish-completions` - Install tab completions

**For scripts that process multiple items or run long operations, also include:**
7. `--progress` - Force in-place progress updates (even in batch mode)
8. `--no-progress` - Suppress progress updates (even in interactive mode)

Optional but recommended:
- `-i/--input FILE` - Explicit input file flag (if not using positional arg)
- `--format FORMAT` - Alternative output formats (json, tsv, csv, etc.)

## Testing Requirements for I/O

Every script must test:

1. **Stdin input**: `echo "data" | script`
2. **File input**: `script input.txt`
3. **Stdout output**: `script input.txt` (check stdout)
4. **File output**: `script input.txt -o output.txt` (check file)
5. **Append mode**: `script -a -o existing.txt new.txt`
6. **Pipe chain**: `script1 | script2 | script3`
7. **Error handling**: Missing files, invalid input, etc.

Example test:
```fish
function run_tests
    log_info "action=test status=starting"

    # Test 1: Pipe input/output
    echo -n "Test 1: Pipe I/O... "
    set result (echo "test data" | my_process)
    if test "$result" = "expected output"
        echo "✓ PASS"
    else
        echo "✗ FAIL (got: $result)"
        exit 1
    end

    # Test 2: File I/O
    echo -n "Test 2: File I/O... "
    set temp_in (mktemp)
    set temp_out (mktemp)
    echo "test data" > $temp_in
    my_process $temp_in -o $temp_out
    set result (cat $temp_out)
    rm $temp_in $temp_out
    if test "$result" = "expected output"
        echo "✓ PASS"
    else
        echo "✗ FAIL"
        exit 1
    end

    log_info "action=test status=complete"
    exit 0
end
```

## Summary of Key Changes Needed

1. **Add I/O Standards section** with stdin/stdout/file patterns
2. **Add Pipe Support section** with composability guidelines
3. **Add Common Errors section** as reference material
4. **Update template scripts** with enhanced I/O handling
5. **Update required flags** to include -o/--output and -a/--append
6. **Update testing section** with I/O test requirements
7. **Add TSV format standard** for structured data
8. **Add stream separation** emphasis (stdout vs stderr)
9. **Add progress output pattern** for multi-item processing with --progress/--no-progress flags
