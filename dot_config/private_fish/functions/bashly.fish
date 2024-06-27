## Command to simplify wrap a call to docker bashly
function bashly
    set -f USAGE "USAGE: bashly <arguments>"
    set -f CONTAINER_ENG podman
    
    $CONTAINER_ENG run --rm -it \
        --user $(id -u):$(id -g) \
        --volume "$PWD:/app" \
        dannyben/bashly $argv
end
