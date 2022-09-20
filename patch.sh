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
  version="0.5.8"
  image="docker://koyeb/nodejs-buildpack@sha256:96ef65ea1e7260c19f392c3b6da2f00cf917937f0f7e8087ee4d5c5a982cc2e9"
  echo $load | jq '.buildpacks[] |= if .id == $id then .uri=$image else . end' --arg image "$image" --arg id "$id" | jq '.buildpacks[] |= if .id == $id then .id=$new else . end' --arg id "$id" --arg new $new | jq '.order[].group |= if .[0].id == $id then .[0]={"id":$new,"version":$version} else . end' --arg id "$id" --arg new $new --arg version "$version"| yj -jt -i > $1
}

function patch_heroku_ruby() {
  echo "patching heroku ruby"
  load=$(cat $1 | yj -t)
  id="heroku/ruby"
  new="heroku/ruby"
  version="0.0.0"
  image="https://cnb-shim.herokuapp.com/v1/heroku/ruby?version=0.0.0&name=Ruby"
  echo $load | jq '.buildpacks[] |= if .id == $id then .uri=$image else . end' --arg image "$image" --arg id "$id" | jq '.buildpacks[] |= if .id == $id then .id=$new else . end' --arg id "$id" --arg new $new | jq '.order[].group |= if .[0].id == $id then .[0]={"id":$new,"version":$version} else . end' --arg id "$id" --arg new $new --arg version "$version"| yj -jt -i > $1
}

function patch_heroku_clojure() {
  echo "patching add clojure"
  out=$(grep -c 'heroku/clojure' $1)

  if [[ "$out" -gt "1" ]]; then
    echo "File '$1' already patched with clojure"
    return
  fi

  load=$(cat $1 | yj -t)
  echo $load | jq '.buildpacks |= . + [{"id": "heroku/clojure", "uri": "https://cnb-shim.herokuapp.com/v1/heroku/clojure?version=0.0.0&name=Clojure"}]' | jq '.order |= . + [{"group": [{"id": "heroku/clojure", "version": "0.0.0"}, {"id": "heroku/procfile", "version": "1.0.2", "optional": true}]}]' | yj -jt -i > $1
}


patch_koyeb_images $1
patch_heroku_nodejs $1
patch_heroku_clojure $1
patch_heroku_ruby $1
patch_koyeb_custom $1
