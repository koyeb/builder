#!/bin/bash

function patch_koyeb_images() {
  echo "patching koyeb images"
  out=$(grep -c 'koyeb/pack' $1)

  if [[ "$out" -gt "1" ]]; then
    echo "File '$1' already patched with koyeb images"
    return
  fi

  load=$(cat $1 | yj -t)
  echo $load | jq '.stack["build-image"] |= "koyeb/pack:" + split(":")[1]' | jq '.stack["run-image"] |= "koyeb/pack:" + split(":")[1]' |  yj -jt -i > $1
}

function patch_koyeb_custom() {
  echo "patching koyeb custom"
  out=$(grep -c 'koyeb/custom' $1)

  if [[ "$out" -gt "1" ]]; then
    echo "File '$1' already patched with custom"
    return
  fi

  load=$(cat $1 | yj -t)
  echo $load | jq '.buildpacks |= . + [{"id": "koyeb/custom", "uri": "docker://koyeb/buildpack-custom"}, {"id": "koyeb/custom-nodejs", "uri": "docker://koyeb/buildpack-custom-nodejs"}]' | jq '.order[].group |= if .[0].id == "heroku/nodejs" then [{"id": "koyeb/custom-nodejs", "version": "0.1.0", "optional": true}] + . else . + [{"id": "koyeb/custom", "version": "0.1.0", "optional": true}] end' | yj -jt -i > $1
}

function patch_heroku_nodejs() {
  echo "patching heroku nodejs"
  load=$(cat $1 | yj -t)
  id="heroku/nodejs"
  new="koyeb/nodejs"
  version="0.3.9"
  image="docker://koyeb/nodejs-buildpack@sha256:be965c2187c9b17a9ae76b7631d186af20bfbf910868b24cac36d8ac66e4e782"
  echo $load | jq '.buildpacks[] |= if .id == $id then .uri=$image else . end' --arg image "$image" --arg id "$id" | jq '.buildpacks[] |= if .id == $id then .id=$new else . end' --arg id "$id" --arg new $new | jq '.order[].group |= if .[1].id == $id then .[1]={"id":$new,"version":$version} else . end' --arg id "$id" --arg new $new --arg version "$version"| yj -jt -i > $1
}

patch_koyeb_images $1
patch_koyeb_custom $1
patch_heroku_nodejs $1
