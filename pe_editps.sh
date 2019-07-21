#!/usr/bin/env bash
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

# handle options
# set defaults
runspecial=1
runviewer=0

# write actual usage
usage () {
  cat << ENDhelp
  pe_editps.sh [option]
  OPTIONS
  -h shows this help then quits.
  -n stops any existing existing specialedit script in the forms \
data directory
     from running. Has no effect if there is no such script.
  -s Shows the completed form in the user's configured PDF viewer.
     Usually used only for the first edit run of a form because the PDF
     viewer is aware of any further changes.
ENDhelp
}
# options string
options=':snh'
# the leading ':' in options string is required for the errors cases.

while getopts $options option
do
	case $option in
		s  ) runviewer=1;;
		n  ) runspecial=0;;
		h  ) usage; exit;;
		\? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
		:  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
		*  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
	esac
done



scriptfrom=$(cd ${BASH_SOURCE[0]%/*}; pwd)
source "$scriptfrom"/pe_sanitisedata.sh

# the path pe_fontfunc.sh forces this to load the script from where
# the script is invoked from, not from where running script resides.

# If I don't make this ./pe_fontfunc.sh not pe_fontfunc.sh bash
# guarantees to mess it up.
source ./pe_fontfunc.sh  # writes the font spec to a postscript file.
source "$scriptfrom"/pe_functions.sh

if [[ ! -f config.lst ]];then
  echo Run pe_initform.sh with a copy of your pdf form in this directory.
  exit 1
fi
getconfig "name"
inputfile="$prm"
echo "$inputfile"
barefilename=$(basename "$inputfile" .pdf)
pdftk "$inputfile" burst output "$barefilename"_%0.3d.pdf
outputfile="$barefilename"Filled.pdf
if [[ -f "$outputfile" ]];then rm "$outputfile"; fi
# generate the file toedit.lst from config.lst.
grep '^toedit' config.lst > toedit.lst
sed -i 's/toedit://' toedit.lst
while IFS= read -r pdftoedit
do
  postscripttoedit=$(basename "$pdftoedit" .pdf)
  postscripttoedit="$postscripttoedit".ps
  pdftops "$pdftoedit" "$postscripttoedit"
  # split the postscript file at the line 'showpage'
  splitps "$postscripttoedit"
  # Build up the postscript statements in a file called mid
  if [[ -f mid ]];then rm mid; fi
  touch mid
  setfont mid
  # here will be the loop reading the data file describing the edits.
  editdata=$(basename "$pdftoedit" .pdf)
  editdata="$editdata".dat
  echo editdata is "$editdata"
  # sanatise data - the procedure replaces any text field that is empty,
  # ie ',,' or comprising a single space ', ,', with ',_,'. That char is
  # converted always to a single space on output. I test for a need to
  # use the procedure because using it makes my editor demand a reload
  # after use which is annoying.
  grep ',,' "$editdata" > /dev/null
  if [[ $? -eq 0 ]]; then sanitise "$editdata"; fi
  grep ', ,' "$editdata" > /dev/null
  if [[ $? -eq 0 ]]; then sanitise "$editdata"; fi
  while IFS= read -u3 -r line
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
  done 3< "$editdata"

  # there may be some special editing needed.
  if [[ runspecial -eq 1 ]]; then
    if [[ -f specialedit.sh ]];then bash specialedit.sh mid; fi
  fi

  # put the postscript file together again
  cat top > "$postscripttoedit"
  cat mid >> "$postscripttoedit"
  cat btm >> "$postscripttoedit"
  ps2pdf "$postscripttoedit"
done < toedit.lst

# Use shell glob to assemble the output.
backfile=$(basename "$inputfile" pdf)bak
mv "$inputfile" "$backfile"   # kludge in, stops my input file catted.
pages=$(head -1 toedit.lst |cut -d_ -f1)
pages=$pages_*.pdf
pdftk $pages cat output "$outputfile"
mv "$backfile" "$inputfile"   # kludge out
rm toedit.lst

if [[ runviewer -eq 1 ]]; then
  viewer=$(grep 'viewer:' config.lst |cut -d: -f2)
  "$viewer" "$outputfile" &
fi
