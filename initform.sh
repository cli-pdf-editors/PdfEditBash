#!/bin/bash
#
# initform.sh - script to set up the parameters to edit a pdf form.
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
# must be just one pdf in the working directory
pdfcount=$(ls *.pdf | wc -l)
if [[ "$pdfcount" -ne 1 ]];then
  echo There must be 1 pdf file only in this directory.
  exit 1
fi
infn=$(ls *.pdf)
echo "$infn"
barefn=$(basename "$infn" .pdf)
outfn="$barefn"Filled".pdf"
pdftk "$infn" burst output "$barefn"_%d.pdf
# list burst pages without the input pdf.
ls *.pdf | grep -v "$infn" > burst.lst
cp burst.lst toedit.lst
# user is required to decide which of the burst pages are NOT to be
# edited, if any. Tell her this!
echo Edit \'toedit.lst\' and remove any names that are NOT to be edited.

# The only survivor of these created files is to be 'toedit.lst'
# Everything else is to be re-created at edit time.

while IFS= read -r line
do
  rm "$line"
done < burst.lst
rm burst.lst
# there is a file 'doc_data.txt' created by the pdftk during the burst
# operation. It will be reborn at edit time so kill it.
if [[ -f doc_data.txt ]];then rm doc_data.txt; fi

# I want a copy of fontfunc.sh from wherever this script is running.
rp=$(realpath "$0")
dn=$(dirname "$rp")
cpfr="$dn"/fontfunc.sh
cp "$cpfr" .
echo Edit \'fontfunc.sh\' to change font name and/or size.

# last job is to record the input pdf file name.
echo "$infn" > pdfname
