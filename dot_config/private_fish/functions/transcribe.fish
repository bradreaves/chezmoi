function transcribe --description "Transcribe audio files using OpenAI Whisper"
    # Check if whisper is installed
    if not command -v whisper &>/dev/null
        echo "Error: whisper is not installed" >&2
        logger -p user.error "transcribe: whisper command not found"
        echo ""
        echo "Installation options:"
        echo "  1. pip:        pip install -U openai-whisper"
        echo "  2. Homebrew:   brew install openai-whisper"
        echo "  3. pipx:       pipx install openai-whisper"
        echo ""
        echo "Note: You may also need to install ffmpeg:"
        echo "  - Homebrew:    brew install ffmpeg"
        echo "  - apt:         sudo apt install ffmpeg"
        echo "  - yum:         sudo yum install ffmpeg"
        return 1
    end

    # Check if audio file argument is provided
    if test (count $argv) -eq 0
        echo "Error: No audio file specified" >&2
        logger -p user.error "transcribe: No audio file argument provided"
        echo "Usage: transcribe <audio_file> [whisper_options...]"
        echo "  --save    Save to file in current directory (default: output to stdout)"
        return 1
    end

    set audio_file $argv[1]

    # Check if file exists
    if not test -f $audio_file
        echo "Error: File not found: $audio_file" >&2
        logger -p user.error "transcribe: File not found: $audio_file"
        return 1
    end

    # Check if file is an audio file
    set file_type (file -b --mime-type $audio_file)
    if not string match -q "audio/*" $file_type; and not string match -q "video/*" $file_type
        echo "Error: File does not appear to be an audio/video file: $audio_file (type: $file_type)" >&2
        logger -p user.error "transcribe: Invalid file type for $audio_file: $file_type"
        return 1
    end

    logger -p user.info "transcribe: Processing audio file: $audio_file (type: $file_type)"

    # Parse arguments to determine output behavior
    set use_stdout true
    set whisper_args
    set temp_dir
    set has_output_format false

    # Check for --save flag or --output_dir in arguments
    set additional_args $argv[2..-1]
    for arg in $additional_args
        if test "$arg" = "--save"
            set use_stdout false
            continue
        else if string match -q -- "--output_dir*" $arg
            set use_stdout false
        else if string match -q -- "--output_format*" $arg
            set has_output_format true
        end
        set whisper_args $whisper_args $arg
    end

    # Set up output directory
    if test "$use_stdout" = true
        set temp_dir (mktemp -d)
        set whisper_args $whisper_args --output_dir $temp_dir
        logger -p user.debug "transcribe: Using temp directory for stdout: $temp_dir"
    else
        logger -p user.debug "transcribe: Saving output to file"
    end

    # Add default output format if not specified
    if not test "$has_output_format" = true
        set whisper_args $whisper_args --output_format txt
        logger -p user.debug "transcribe: Using default output format: txt"
    end

    # Add audio file as first argument to whisper
    set whisper_args $audio_file $whisper_args

    logger -p user.debug "transcribe: whisper arguments: $whisper_args"

    # Run whisper and capture output/errors
    logger -p user.info "transcribe: Starting whisper transcription"

    whisper $whisper_args 2>&1 | while read -l line
        logger -p user.debug "whisper: $line"
    end

    set exit_code $pipestatus[1]

    if test $exit_code -eq 0
        logger -p user.info "transcribe: Transcription completed successfully"

        # If using stdout, output the transcription and cleanup
        if test "$use_stdout" = true
            set basename (basename $audio_file | sed 's/\.[^.]*$//')
            set output_file "$temp_dir/$basename.txt"

            if test -f $output_file
                cat $output_file
                rm -rf $temp_dir
                logger -p user.debug "transcribe: Cleaned up temp directory"
            else
                echo "Error: Expected output file not found: $output_file" >&2
                logger -p user.error "transcribe: Output file not found: $output_file"
                rm -rf $temp_dir
                return 1
            end
        end
    else
        echo "Error: whisper failed with exit code $exit_code" >&2
        logger -p user.error "transcribe: whisper failed with exit code $exit_code"

        # Cleanup temp directory if it was created
        if test -n "$temp_dir" -a -d "$temp_dir"
            rm -rf $temp_dir
        end
    end

    return $exit_code
end
