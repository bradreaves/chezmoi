
function myip
    set -l address (curl --silent ifconfig.me)
    echo $address
end
