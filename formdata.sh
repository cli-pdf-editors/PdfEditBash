
#!/bin/bash
#
# formdata.sh - interactive script to write the data file(s) for
#               the pdf form editor.
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

# I expect that the control file ./toedit.lst exists
if [[ ! -f ./toedit.lst ]];then
  echo Run \'initform.sh\' to create required data files.
  exit 1
fi

# where do my executeables live?
exp=$(realpath "$0")
exp=$(dirname "$exp")

while IFS= read -r edpdf
do
  # file contains 1 or more names of the form 'something.pdf`, for each
  # of these, we'll make a 'something.dat' specifying the edits to apply
  # (via postscript) to the pdf file(s).
  datfn=$(basename "$edpdf" .pdf)
  datfn="$datfn".dat
  # allow us to do this in several bites
  if [[ ! -f "$datfn" ]];then touch "$datfn"; fi
  echo When done editing \'"$datfn"\', just enter \'end\' in the \
  comment field.
  "$exp"/userinput.sh "$datfn"
done < toedit.lst
