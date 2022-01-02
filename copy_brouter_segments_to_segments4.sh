#!/bin/bash
currentdir="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
mkdir -p $currentdir/segments4
#cp -R $currentdir/brouter-master/misc/scripts/mapcreation/segments/. $currentdir/segments4

### Purpose:
# Copy huge amount of files from source to destination directory only if
# destination file is smaller in size than in source directory
###

src=$currentdir/brouter-master/misc/scripts/mapcreation/segments # Source directory
dst=$currentdir/segments4 # Destination directory

icp() {
  f="${1}";
  [ -d "$f" ] && {
    [ ! -d "${dst}${f#$src}" ] && mkdir -p "${dst}${f#$src}";
    return
  }

  [ ! -f "${dst}/${f#$src/}" ] && { cp -a "${f}" "${dst}/${f#$src/}"; return; }
  fsizeSrc=$( stat -c %s "$f" )
  fsizeDst=$( stat -c %s "${dst}/${f#$src/}" )
  [ ${fsizeDst} -lt ${fsizeSrc} ] && cp -a "${f}" "${dst}/${f#$src/}"
}

export -f icp
export src
export dst

find ${src} -exec bash -c 'icp "$0"' {} \;