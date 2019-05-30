#!/bin/bash

function jetLatestVersion() {
    local v=$(echo "$(curl -s 'https://s3.amazonaws.com/codeship-jet-releases' | xmllint --format -)" | sed -ne '/<Key>/s#\s*<[^>]*>\s*##gp' | cut -f1 -d/ | sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n | tail -n1)
    echo ${v// }
}

echo $(jetLatestVersion)