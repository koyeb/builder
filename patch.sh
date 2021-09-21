#!/bin/bash

out=$(grep -c 'koyeb/build-command' $1)

if [[ "$out" -gt "1" ]]; then
  echo "File '$1' already patched"
  exit 0
fi

load=$(cat $1 | yj -t)
echo $load | jq '.buildpacks |= . + [{"id": "koyeb/build-command", "uri": "docker://koyeb/build-command-buildpack"}]' | jq '.order[].group |= . + [{"id": "koyeb/build-command", "version": "0.0.1", "optional": true}]' | yj -jt -i > $1
