#!/usr/bin/env bash
#
# pe_initform.sh - script to set up the parameters to edit a pdf form.
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
scriptfrom=$(cd ${BASH_SOURCE[0]%/*}; pwd)
source "$scriptfrom"/pe_functions.sh

nametowhich()
{ # convert the input parameter to the leftmost word in lowercase.
  local wd=$(echo "$1" |cut -d' ' -f1)
  # a single word returns the required result, nothing needs to be done.
  retname=$(echo "$wd" | tr [:upper:] [:lower:])
}
# must be just one pdf in the working directory
pdfcount=$(ls *.pdf | wc -l)
if [[ "$pdfcount" -ne 1 ]];then
  echo There must be 1 pdf file only in this directory.
  exit 1
fi
inputfilename=$(ls *.pdf)
echo "$inputfilename"
echo name:"$inputfilename" > ./config.lst
barefilename=$(basename "$inputfilename" .pdf)
outputfilename="$barefilename"Filled".pdf"
pdftk "$inputfilename" burst output "$barefilename"_%0.3d.pdf

# list burst pages without the input pdf.
# want a list of the burst pages for when the pdf pages are concatented
# onto the output PDF.
ls *.pdf | grep -v "$inputfilename" > burst.lst
# I also want a customised cleanup script so user can redo her choices
# after an input error.
cpfr="$scriptfrom"/pe_cleanup.sh
cp "$cpfr" ./cleanup.sh
while IFS= read -r line
do
  echo burst:"$line" >> config.lst
  echo "if [[ -f $line ]];then rm $line; fi" >> ./cleanup.sh
done < burst.lst
chmod +x cleanup.sh
cpfr="$scriptfrom"/pe_fontfunc.sh
cp "$cpfr" .
echo Edit \'pe_fontfunc.sh\' to change font name and/or size.

# Not every page that was 'burst' off the input PDF is going to be
# edited, sometimes these pages are just instructions to the user.
echo "Now I need to get some more information about this form."
filelc burst.lst
pages="$lc"
echo It has "$pages" pages.
for page in {1..1000} # Only numeric literals allowed, no variables.
do
  read -e -p "Is page $page to be edited? " -i "YN" answer
  if [[ "$answer" = "Y" ]];then
    x=$(printf "_%0.3d.pdf" "$page")
    fn=$(grep "$x" burst.lst)
    echo toedit:"$fn" >> ./config.lst
  fi
  if [[ "$page" -eq "$pages" ]];then break; fi
done
rm burst.lst

# Get the user's preferred editor and PDF viewer.
# The user's entries may need to be massaged, eg the editor I use shows
# as 'Geany' in my GUI program selector and I need 'geany' as the
# search item to which. Likewise, I choose 'Atril Document Viewer' and
# need 'atril' as the parameter for which.

# get data about text editor to be used.
prompt="Please enter the name of your preferred text editor. "
read -e -p "$prompt" ineditor
nametowhich "$ineditor"
editor="$retname"
rp=$(which "$editor")
res=$?
if [[ $res -eq 0 ]];then
  echo editor:"$rp" >> ./config.lst
else
  echo "Could not find $ineditor, please try again."
  ./cleanup.sh
  exit 1
fi

# get data about PDF viewer to be used.
prompt="Please enter the name of your preferred PDF viewer. "
read -e -p "$prompt" inviewer
nametowhich "$inviewer"
viewer="$retname"
rp=$(which "$viewer")
res=$?
if [[ $res -eq 0 ]];then
  echo viewer:"$rp" >> ./config.lst
else
  echo "Could not find $inviewer, please try again."
  ./cleanup.sh
  exit 1
fi
