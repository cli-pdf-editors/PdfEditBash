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
usage () {
  cat << ENDhelp
  pe_updatetext.sh [option] [pageno]

  pe_updatetext.sh interactively allows the user to edit the text field
  in a formatted data file. If pageno is not entered all editable pages
  will be presented. If no options are selected, all text fields are
  presented for editing.
  echo Options
  -h prints this and quits.
  -v sets seltext to \'variable\' so presents for editing, only lines
  ending with that value.
  -s presents only lines ending with \'stable\' for editing.
  -S='$OPTARG' presents only those lines ending with the value of
  '$OPTARG'
ENDhelp
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
    # empty lines permitted in the data.
    if [[ -z "$prompt" ]];then continue; fi
    # comment out with '#' permitted in the data.
    echo "$prompt" |grep '#' > /dev/null
    if [[ $? -eq 0 ]]; then continue; fi
    # sometimes seltext has the value 'immutable', do not edit.
    if [[ "$selext" = "immutable" ]];then continue; fi
    read -e -p "$prompt"" " -i "$text" intext
    # protect against an embedded comma.
    text=$(echo "$text" | tr ',' ' ')
    if [[ "$intext" != "$text" ]];then
      # sometimes "$prompt" and "$text" can have the same string value
      # I only want to change "$text".
      srch="$X","$Y","$text"
      repl="$X","$Y","$intext"
      # text fields may have '/' or '!' inside but not both.
      echo "$intext" |grep '/' > dev/null
      if [[ $? -eq 0 ]]; then
        sed -i "s!$srch!$repl!" "$infile"
      else
        echo "$intext" |grep '!' > dev/null
        if [[ $? -eq 0 ]]; then
          echo "You may not have both '!' and '/' in your text field."
          echo "Edit with pe_editformdata.sh if you must include these."
        else
          sed -i "s/$srch/$repl/" "$infile"
        fi
      fi
    fi
  done 3< "$datafile"
  rm "$datafile"
done 4< "$tflist"
rm "$tflist"


