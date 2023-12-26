# Use dig to return the domain for a given IP address

function rdns
    set -l addr $argv[1]
    dig -x $addr +short
end 
