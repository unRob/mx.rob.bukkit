#!/usr/bin/env bash
#
# Bukkit test
#
# Roberto Hidalgo, 2017
# http://bukkit.rob.mx

SRC=$(mktemp -d)
DST=$(mktemp -d)
cleanup () {
  echo "Cleaning up..."
  rm my.bukkit.plist
  rm -rf "$SRC"
  rm -rf "$DST"
}
trap 'cleanup' INT TERM HUP EXIT

src () { echo -n "${SRC}/$1"; }
dst () { echo -n "${DST}/$1"; }
die () { >&2 printf "\n\n%s" "$1" && exit 2; }

sed -e "s|/Users/USER/Pictures/bukkit|${SRC}|" < mx.rob.bukkit.plist > my.bukkit.plist
cp -rv ./fixtures/* "$SRC"

make setup-bukkit
test -f "$(src template/index.html)" || die "Index not installed"
test -x "$(src .sync)" || die "Executable not installed"

$(src .sync) "$SRC" "$DST" || die "Bukkit exploded :("
test -f "$(dst index.html)" || die "Did not create index"
grep "dancin" "$(dst index.html)" >/dev/null || die "Index does not include reference to image"
test -f "$(dst dancin.gif)" || die "Did not create original"
test -f "$(dst _preview/dancin.jpg)" || die "Did not create preview"