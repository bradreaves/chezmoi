## Command to simplify connecting through Mullvad on tailscale
function vpn
    set -l ROOTERR "ERROR: This command requires sudo. Run: \n\t sudo vpn $argv"
    set -l VPNERR "ERROR: Command \"$argv[1] failed."
    switch $argv[1]
        case 'up' 'on'
            echo "VPN is going up"
            sudo tailscale set --exit-node="us-rag-wg-103.mullvad.ts.net" 
        case 'down' 'off'
            echo "VPN is going down"
            sudo tailscale set --exit-node="" 
        case 'status' '*'
    end
    echo -n "Current outside DNS is: " 
    set_color red
    echo (rdns (myip))
    set_color normal
end
