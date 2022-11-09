#!/bin/bash

function patch_run_image() {
  echo "patching koyeb run images"
  out=$(grep -c "$2/pack" $1)

  if [[ "$out" -gt "1" ]]; then
    echo "File '$1' already patched with koyeb images"
    return
  fi

  load=$(cat $1 | yj -t)
  echo $load | jq '.stack["build-image"] |= $reg + "/pack:" + split(":")[1]' --arg reg "$2" | jq '.stack["run-image"] |= $reg + "/pack:" + split(":")[1]' --arg reg "$2" |  yj -jt -i > $1
}


patch_run_image $1 $2
