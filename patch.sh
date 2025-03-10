#!/bin/bash

function patch_koyeb_images() {
	echo "patching koyeb images"
	out=$(grep -c 'koyeb/pack' $1)

	if [[ "$out" -gt "1" ]]; then
		echo "File '$1' already patched with koyeb images"
		return
	fi

	load=$(cat $1 | yj -t)
	echo $load | jq '.stack["build-image"] |= "koyeb/pack:" + split(":")[1]' | jq '.run.images[0].image |= "koyeb/pack:" + split(":")[1]' | jq '.build["image"] |= "koyeb/pack:" + split(":")[1]' | jq '.stack["run-image"] |= "koyeb/pack:" + split(":")[1]' | jq 'del(.stack["run-image-mirrors"],.run.images[0].mirrors)' | yj -jt -i >$1
}

function patch_lifecycle_version() {
	echo "patching lifecycle version"
	load=$(cat $1 | yj -t)
	echo $load | jq '.lifecycle["version"] = "0.15.3"' | yj -jt -i >$1
}

function patch_koyeb_custom() {
	echo "patching koyeb custom"
	out=$(grep -c 'koyeb/custom' $1)

	if [[ "$out" -gt "1" ]]; then
		echo "File '$1' already patched with custom"
		return
	fi

	load=$(cat $1 | yj -t)
	echo $load | jq '.buildpacks |= . + [{"id": "koyeb/custom", "uri": "docker://koyeb/buildpack-custom"}, {"id": "koyeb/custom-nodejs", "uri": "docker://koyeb/buildpack-custom-nodejs"}]' | jq '.order[].group |= if .[0].id == "heroku/nodejs" then [{"id": "koyeb/custom-nodejs", "version": "0.1.0", "optional": true}] + . else . + [{"id": "koyeb/custom", "version": "0.1.0", "optional": true}] end' | yj -jt -i >$1
}

#patch_lifecycle_version $1
patch_koyeb_images $1
patch_koyeb_custom $1
