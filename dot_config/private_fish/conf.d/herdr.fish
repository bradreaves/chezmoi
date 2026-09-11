# Herdr Shortcuts

abbr --add hrd "herdr session list"
abbr --add workr "herdr --remote workbox"

function killhrd --description "Stops and deletes a session"
    set session_name $argv[1]
    herdr session stop $session_name
    herdr session delete $session_name
end

