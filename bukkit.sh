#!/usr/bin/env bash
#
# Bukkit
#
# Roberto Hidalgo, 2017
# http://bukkit.rob.mx
#
# Syncs a folder of images to a remote server, creating a fancy index and fake previews

# This is a folder with .jpg and .gif images and a template dir
LOCAL_BUKKIT=$1
# This is the rsync target
REMOTE_BUKKIT=$2

echo "Beginning sync of $LOCAL_BUKKIT"
date -j

images="${LOCAL_BUKKIT}/.buffer"

mkdir -vp "$LOCAL_BUKKIT/_preview"

rm -f "$images"
touch -m 600 "$images"
echo '' > "$images" & # prevent hung named pipe?

tpl () { echo "$LOCAL_BUKKIT/template/$1.html"; }

render () {
  local tpl
  local replacements
  local IFS=";";
  tpl=$1
  shift;

  replacements=()
  for substitution in "$@"; do
    key="${substitution%%\=*}"
    value="${substitution#*=}"
    replacements+=("gsub(\"%${key}%\", \"${value}\")")
  done

  awk "{ ${replacements[*]} }1" "$tpl"
}

# Main loop
find "$LOCAL_BUKKIT" -name '*.gif' -o -name '*.jpg' -maxdepth 1 |
  sort |
  while IFS= read -r -d $'\n' image; do
    filename=$(basename "$image")
    name="${filename%.*}"
    preview="$LOCAL_BUKKIT/_preview/$name.jpg"

    if [ ! -f "${preview}" ]; then
      echo "Generating preview for ${image} > ${preview}"
      /usr/local/bin/convert "${image}[0,-1]" \
        -thumbnail '200x200>' \
        -quality 40 \
        -coalesce \
        +append \
        "${preview}"
    fi

    render "$(tpl image)" "url=$filename" "name=$name" >> "$images"
  done

echo "Creating bukkit index"

sed -e '/%images%/ {' -e "r $images" -e 'd' -e '}' "$(tpl index)" > "$LOCAL_BUKKIT/index.html"
rm "$images"

echo "Filling up $REMOTE_BUKKIT"

/usr/local/bin/rsync "$LOCAL_BUKKIT/" \
  -avz \
  --include='*.gif' \
  --include='*.jpg' \
  --include='index.html' \
  --include='_preview' \
  --exclude='*' "$REMOTE_BUKKIT"

hash /usr/bin/osascript 2>/dev/null && /usr/bin/osascript -e 'display notification "Much gifs. Wow." with title "Bukkit very sync"'

echo 'done!'