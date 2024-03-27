## Command to simplify running Pandoc to generate a given fie
function md2
    set -f USAGE "USAGE: md2 <tex|pdf> <filename> [arguments to pandoc]"

    set -f PDF_DEFAULT_FILE latex
    set -f LATEX_DEFAULT_FILE latex

    switch $argv[1]
        case 'pdf'
            set -f DEFAULT_FILE $PDF_DEFAULT_FILE
            set -f EXT 'pdf'
        case 'tex' 'latex' 
            set -f DEFAULT_FILE $LATEX_DEFAULT_FILE
            set -f EXT 'tex'
        case  '*'
            echo $USAGE >&2
            return -1
    end

    set -f INPUT_FILE (path normalize $argv[2])
    set -f OUTPUT_FILE (path change-extension $EXT $INPUT_FILE)


    pandoc --defaults $DEFAULT_FILE $INPUT_FILE --output $OUTPUT_FILE $argv[3..]

end
