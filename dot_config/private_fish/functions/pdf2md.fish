function pdf2md --description "Convert PDF to markdown using pdftohtml and pandoc"
    # Check if pdftohtml is available
    if not type -q pdftohtml
        echo "Error: pdftohtml is not installed. Please install poppler:" >&2
        echo "  macOS: brew install poppler" >&2
        echo "  Ubuntu/Debian: sudo apt-get install poppler-utils" >&2
        echo "  CentOS/RHEL: sudo yum install poppler-utils" >&2
        return 127
    end

    # Check if pandoc is available
    if not type -q pandoc
        echo "Error: pandoc is not installed. Please install pandoc:" >&2
        echo "  macOS: brew install pandoc" >&2
        echo "  Ubuntu/Debian: sudo apt-get install pandoc" >&2
        echo "  CentOS/RHEL: sudo yum install pandoc" >&2
        return 127
    end

    # Check for arguments
    if test (count $argv) -eq 0
        echo "Usage: pdf2md <filename|->" >&2
        echo "  filename: PDF file to convert" >&2
        echo "  -: read PDF from stdin" >&2
        return 1
    end

    set filename $argv[1]

    # Convert PDF to markdown with cleanup (output to stdout)
    if test "$filename" = "-"
        # Read from stdin - pdftohtml doesn't support stdin, so use temp file
        set tempfile (mktemp -t pdf2md.XXXXXX.pdf)
        cat > "$tempfile"
        pdftohtml -stdout -s -i "$tempfile" | \
            pandoc -f html -t markdown | \
            sed -e '/^::: {#page.*-div/d' \
                -e '/^:::$/d' \
                -e 's/\[]{#[0-9]*}//g' \
                -e 's/\\\\$//' | \
            cat -s
        set exit_code $status
        rm -f "$tempfile"
        return $exit_code
    else
        # Read from file, output to stdout
        if not test -f "$filename"
            echo "Error: File not found: $filename" >&2
            return 2
        end
        pdftohtml -stdout -s -i "$filename" | \
            pandoc -f html -t markdown | \
            sed -e '/^::: {#page.*-div/d' \
                -e '/^:::$/d' \
                -e 's/\[]{#[0-9]*}//g' \
                -e 's/\\\\$//' | \
            cat -s
    end

    # Return pipeline exit code
    return $status
end
