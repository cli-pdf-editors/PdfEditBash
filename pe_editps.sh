#!/bin/bash
#
# pe_editps.sh - script to edit a postscript file.
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
# functions
splitps()
{ # split a postscript file in 2 at location of "showpage"
  local psfn="$1"
  local lines=$(wc -l "$psfn")
  lines=$(echo "$lines" | cut -d' ' -f1)
  local split=$(grep -n showpage "$psfn")
  split=$(echo "$split" | cut -d':' -f1)
  let split-=1 # want the line containing 'showpage' in the bottom.
  local lower=$(expr "$lines" - "$split")
  head -n"$split" "$psfn" > top
  tail -n"$lower" "$psfn" > btm
}
# the path ./pe_fontfunc.sh forces this to load the script from where the
# script is invoked from, not from where running script resides.
source ./pe_fontfunc.sh  # writes the font spec to a postscript file.

if [[ ! -f pdfname ]];then
  echo Run pe_initform.sh with a copy of your pdf form in this directory.
  exit 1
fi

inputfile=$(cat pdfname)
basename=$(basename "$inputfile" .pdf)
outputfile="$basename"Filled.pdf
if [[ -f "$outputfile" ]];then rm "$outputfile"; fi
# burst the input pdf into single pages.
pdftk "$inputfile" burst output "$basename"_%d.pdf 
ls *.pdf | grep -v "$inputfile" | sort > burst.lst
# burst.lst is for when we rebuild the output pdf
# toedit.lst lists what pdf pages get edited
while IFS= read -r edpdf
do
  edps=$(basename "$edpdf" .pdf)
  edps="$edps".ps
  pdftops "$edpdf" "$edps"
  # split the postscript file at the line 'showpage'
  splitps "$edps"
  # Build up the postscript statements in a file called mid
  if [[ -f mid ]];then rm mid; fi
  touch mid
  setfont mid
  # here will be the loop reading the data file describing the edits.
  edata=$(basename "$edpdf" .pdf)
  edata="$edata".dat
  while IFS= read -r line
  do
    echo "$line"
    comment=$(echo "$line" | cut -d',' -f1)
    comment="%""$comment"  # postscript comment
    echo "$comment" >> mid
    echo "newpath" >> mid
    X=$(echo "$line" | cut -d',' -f2)
    Y=$(echo "$line" | cut -d',' -f3)
    moveline=$(printf "%s %s moveto" "$X" "$Y")
    echo "$moveline" >> mid
    text=$(echo "$line" | cut -d',' -f4)
    text=$(echo "$text" | tr '_' ' ')
    showline=$(printf "(%s) show" "$text")
    echo "$showline" >> mid
    # the 5th field 'selector', has no role here.
  done < "$edata"

  # there may be some special editing needed.
  if [[ -f specialedit.sh ]];then bash specialedit.sh mid; fi
  
  # put the postscript file together again
  cat top > "$edps"
  cat mid >> "$edps"
  cat btm >> "$edps"
  ps2pdf "$edps"
done < toedit.lst

# assemble the output pdf
inlist=$(cat burst.lst |tr '\n' ' ')
command=$(printf "pdftk %s cat output %s" "$inlist" "$outputfile")
echo "$command"
eval "$command"
exit 0
# clean up work files
while IFS= read -r line
do
  rm "$line"
done < burst.lst
rm burst.lst

exit 0
