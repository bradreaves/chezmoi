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

    # Prepare whisper arguments
    set whisper_args $audio_file

    # If only one argument (the audio file), use defaults
    if test (count $argv) -eq 1
        logger -p user.debug "transcribe: Using default arguments: --output_format txt"
        set whisper_args $whisper_args --output_format txt
    else
        # Pass additional arguments to whisper
        set additional_args $argv[2..-1]
        logger -p user.debug "transcribe: Using custom arguments: $additional_args"
        set whisper_args $whisper_args $additional_args
    end

    # Run whisper and capture output/errors
    logger -p user.info "transcribe: Starting whisper transcription"

    whisper $whisper_args 2>&1 | while read -l line
        logger -p user.debug "whisper: $line"
    end

    set exit_code $pipestatus[1]

    if test $exit_code -eq 0
        logger -p user.info "transcribe: Transcription completed successfully"
    else
        echo "Error: whisper failed with exit code $exit_code" >&2
        logger -p user.error "transcribe: whisper failed with exit code $exit_code"
    end

    return $exit_code
end
