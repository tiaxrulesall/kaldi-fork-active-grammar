#!/bin/bash

# Copyright   2014  Johns Hopkins University (author: Daniel Povey)
#             2017  Luminar Technologies, Inc. (author: Daniel Galvez)
#             2017  Ewald Enzinger
#             2019  David Zurow
# Apache 2.0

# commit 6025e5b9c62bc84b918c8533c6895f75dd62ab62

# Adapted from egs/mini_librispeech/s5/local/download_and_untar.sh (commit 1cd6d2ac3a935009fdc4184cb8a72ddad98fe7d9)

remove_archive=false

if [ "$1" == --remove-archive ]; then
  remove_archive=true
  shift
fi

if [ $# -ne 2 ]; then
  echo "Usage: $0 [--remove-archive] <data-base> <url>"
  echo "With --remove-archive it will remove the archive after successfully un-tarring it."
fi

data=$1
url=$2

if [ ! -d "$data" ]; then
  echo "$0: no such directory $data"
  exit 1;
fi

if [ -z "$url" ]; then
  echo "$0: empty URL."
  exit 1;
fi

if [ -f $data/.complete ]; then
  echo "$0: data was already successfully extracted, nothing to do."
  exit 0;
fi

filepath="$data/speech_commands_v0.02.tar.gz"
filesize="2428923189"

if [ -f $filepath ]; then
  size=$(/bin/ls -l $filepath | awk '{print $5}')
  size_ok=false
  if [ "$filesize" -eq "$size" ]; then size_ok=true; fi;
  if ! $size_ok; then
    echo "$0: removing existing file $filepath because its size in bytes ($size)"
    echo "does not equal the size of the archives ($filesize)."
    rm $filepath
  else
    echo "$filepath exists and appears to be complete."
  fi
fi

if [ ! -f $filepath ]; then
  if ! which wget >/dev/null; then
    echo "$0: wget is not installed."
    exit 1;
  fi
  echo "$0: downloading data from $url.  This may take some time, please be patient."

  cd $data
  if ! wget --no-check-certificate $url; then
    echo "$0: error executing wget $url"
    exit 1;
  fi
fi

cd $data

mkdir -p speech_commands_v0.02

if ! tar -xzf $(basename $filepath) -C speech_commands_v0.02; then
  echo "$0: error un-tarring archive $filepath"
  exit 1;
fi

touch .complete

echo "$0: Successfully downloaded and un-tarred $filepath"

if $remove_archive; then
  echo "$0: removing $filepath file since --remove-archive option was supplied."
  rm $filepath
fi
