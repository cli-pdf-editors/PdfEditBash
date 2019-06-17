#!/usr/bin/env bash
#
# pe_addformdata.sh - input script to get user input
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

# Because the original PDF is burst into individual pages with names
# made by mangling the input file name, I have taken steps to allow the
# user to access these files using only page numbers, not the mangled
# file names.

scriptfrom=$(cd ${BASH_SOURCE[0]%/*}; pwd)
source "$scriptfrom"/pe_functions.sh
mk_tfn addfd
temp="$tfn"
getconfig toedit
echo "$prm" > "$temp"
filelc "$temp"
numpages="$lc"
rm $temp
echo "You have $numpages pages to be edited. This procedure adds the"
echo "data that controls the edits to the page(s) in turn."
echo "Once you have a line or two in place you might consider using a"
echo "normal text editor invoked by pe_editformdata.sh instead."
echo "Quit adding data lines by entering the word 'end' to the"
echo "comment entry."
for page in {1..1000}
do
  echo "Adding to page: $page"
  # get my data file name for the page
  getconfig toedit "$page"
  outputfile=$(basename "$prm" pdf)dat
  if [[ ! -f "$outputfile" ]];then touch "$outputfile"; fi
  while :
  do
    # reads user data for 5 variables and emits a comma separated list.
    read -e -p "Field name on form (comment entry): " comment
    if [[ "$comment" == "end" ]];then break; fi
    read -e -p "Location from left: " X
    read -e -p "Location from bottom: " Y
    read -e -p "Default text: " text
    read -e -p "Selector: " -i "stable variable" selector
    line="$comment","$X","$Y","$text","$selector"
    echo "$line"
    echo "$line" >> "$outputfile"
  done
  if [[ "$page" -eq "$numpages" ]];then exit 0; fi
done
