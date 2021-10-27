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

function patch_heroku_nodejs() {
  echo "patching heroku nodejs"
  load=$(cat $1 | yj -t)
  id="heroku/nodejs"
  version="0.3.8"
  image="docker://public.ecr.aws/heroku-buildpacks/heroku-nodejs-buildpack@sha256:30ab86eed55dd816fa45045dd549db97c8cfd5b9c492eae79b3095a3fafaf3a5"
  echo $load | jq '.buildpacks[] |= if .id == $id then .uri=$image else . end' --arg image "$image" --arg id "$id" | jq '.order[].group[] |= if .id == $id then .version=$version else . end' --arg version "$version" --arg id "$id"  | yj -jt -i > $1
}

patch_koyeb_custom $1
patch_heroku_nodejs $1
