#!/usr/bin/env sh

_hexcolor2rgb() {
  hexinput=$( echo $1 | sed -e 's/#//g' | tr '[:lower:]' '[:upper:]' )
  a=$( echo $hexinput | cut -c-2 )
  b=$( echo $hexinput | cut -c3-4 )
  c=$( echo $hexinput | cut -c5-6 )

  r=$( echo "ibase=16; $a" | bc )
  g=$( echo "ibase=16; $b" | bc )
  b=$( echo "ibase=16; $c" | bc )

  echo $r $g $b
}

_getcolors() {
  ymlfile="$1"
  # clear param array
  set --

  jsonfile=$(basename "${ymlfile%.*}.json")
  for color_group in normal bright; do
    picklist='["black", "red", "green", "yellow", "blue", "magenta", "cyan", "white"]'
    query=".colors.${color_group} |= pick(${picklist}) | .colors.${color_group}[]"
    set -- $(yq "$query" $ymlfile | awk 'ORS=" "{print}') $@
  done
  REPLY="$@"
}

_main() {
  if ! type yq &>/dev/null; then
    echo >&2 "yq command not found"
    echo >&2 "install with your OS package manager (eg: brew install yq)"
    return 1
  fi

  prjdir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
  repo="mbadolato/iTerm2-Color-Schemes"
  workdir="${XDG_CACHE_HOME:-$HOME/.cache}"/shellscripts/colors
  itermcs=$workdir/itermcs
  if [ ! -d $itermcs ]; then
    mkdir -p $workdir
    git clone --depth 1 --quiet https://github.com/$repo $itermcs
  else
    git -C $itermcs pull --quiet
  fi

  for ymlfile in $itermcs/alacritty/*tokyonight.yml; do
    REPLY=
    _getcolors $ymlfile
    set -- $REPLY
    for color in $@; do
      _hexcolor2rgb $color
    done
  done
}
_main $@
