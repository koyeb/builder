#!/bin/bash

function patch_koyeb_custom() {
  echo "patching koyeb custom"
  out=$(grep -c 'koyeb/custom' $1)

  if [[ "$out" -gt "1" ]]; then
    echo "File '$1' already patched with custom"
    return
  fi

  load=$(cat $1 | yj -t)
  echo $load | jq '.buildpacks |= . + [{"id": "koyeb/custom", "uri": "docker://koyeb/custom-buildpack"}]' | jq '.order[].group |= . + [{"id": "koyeb/custom", "version": "0.1.0", "optional": true}]' | yj -jt -i > $1
}

patch_koyeb_custom $1
