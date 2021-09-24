#!/bin/bash

out=$(grep -c 'koyeb/custom' $1)

if [[ "$out" -gt "1" ]]; then
  echo "File '$1' already patched"
  exit 0
fi

load=$(cat $1 | yj -t)
echo $load | jq '.buildpacks |= . + [{"id": "koyeb/custom", "uri": "docker://koyeb/custom-buildpack"}]' | jq '.order[].group |= . + [{"id": "koyeb/custom", "version": "0.1.0", "optional": true}]' | yj -jt -i > $1