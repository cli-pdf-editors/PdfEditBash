#!/usr/bin/env bash
#
# pe_updatetext.sh - script to update data files used to
#                   describe edits to a postscript file.
#
# Copyright 2019 Robert L (Bob) Parker rlp1938@gmail.com
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.# See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
# MA 02110-1301, USA.
#

# user has the choice of naming just 1 file by page number, or just
# running the script without it. In that case all editable data files
# are accessed in order of page number.
scriptfrom=$(cd ${BASH_SOURCE[0]%/*}; pwd)
source "$scriptfrom"/pe_functions.sh
updscript="$scriptfrom"/pe_userupdate.sh

# options handling
# set defaults
seltext=

# write actual usage
usage () { echo "How to use";
  echo pe_updatetext.sh interactively allows the user edit the text
  echo field in a formatted data file.
  echo pe_updatetext.sh [option] datafile
  echo Options
  echo h prints this and quits.
  echo v sets seltext to \'variable\' so presents for editing, only
  echo lines containing that value.
  echo s presents only lines containing \'stable\' for editing.
  echo S='$OPTARG' presents only those lines containing the value of
  echo '$OPTARG'
}

# options string
options=':hvS:s'
# the leading ':' in options string is required for the errors cases.

while getopts $options option
do
  case $option in
    v  ) seltext="variable";shift;;
    S  ) seltext=$OPTARG;shift;shift;;
    s  ) seltext="stable";shift;;
    h  ) usage; exit;;
    \? ) echo "Unknown option: $OPTARG" >&2; exit 1;;
    :  ) echo "Missing option argument for $OPTARG" >&2; exit 1;;
    *  ) echo "Unimplemented option: $OPTARG" >&2; exit 1;;
  esac
done

temp="edfd"$(date  +"%Y-%m-%d-%H-%M-%S")
getconfig toedit
echo "$prm" > "$temp"
filelc "$temp"
numpages="$lc"
rm $temp
# the logic of setting up the list relies on the pdf form having
# editable pages in a contiguous block beginning at page 1, with any
# instruction pages following those.

tflist="list"$(date +"%Y-%m-%d-%H-%M-%S")
if [[ -z "$1" ]];then
  # set up a list of the editable files.
  grep toedit config.lst > "$tflist"
  sed -i "s/toedit://" "$tflist"
  sed -i "s/pdf/dat/" "$tflist"
else
  page="$1"
  echo "page" "$page"
  if [[ "$page" -lt 1 ]] || [[ "$page" -gt "$numpages" ]];then
    echo "Page number out of range: $page"
    exit 1
  fi
  # make a list comprising just the one named file.
  getconfig toedit "$page"
  echo "prm" "$prm"
  fn=$(basename "$prm" pdf)dat
  echo fn "$fn"
  echo "tflist" "$tflist"
  echo "$fn" > "$tflist"
fi

# Data files names loop
while IFS= read -u4 -r infile
do
  datafile="data"$(date +"%Y-%m-%d-%H-%M-%S")
  if [[ ! -z "$seltext" ]]; then
    # get only lines containing '$selext' at field 5, ie before '\n'
    grep -n "$seltext"'$' "$infile" > "$datafile"
  else
    # get all lines but with identical output formatting as above.
    grep -n . "$infile" > "$datafile"
  fi
  # read through the collection in $datafile
  clear
  getpageno "$infile"
  pageno="$retpno"
  echo "Editing page ""$pageno"
  echo "Just hit <Enter> to leave the text field unchanged."
  echo "Edit the content of the text field to a new value as desired,"
  echo "then <Enter> to accept the change."
  echo
  while IFS=:, read -u3 -r lno prompt X Y text seltext
  do
    read -e -p "$prompt"" " -i "$text" intext
    if [[ "$intext" != "$text" ]];then
      # sometimes "$prompt" and "$text" can have the same string value
      # I only want to change "$text".
      srch="$X","$Y","$text"
      repl="$X","$Y","$intext"
      sed -i "s/$srch/$repl/" "$infile"
    fi
  done 3< "$datafile"
  rm "$datafile"
done 4< "$tflist"
rm "$tflist"


