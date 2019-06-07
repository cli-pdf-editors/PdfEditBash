#!/bin/bash
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
split()
{ # truncated split(), only want the line number.
  lno=$(echo "$1" |cut -d':' -f1)
}

# set defaults
seltext=

# write actual usage
usage () { echo "How to use";
  echo pe_updatetext.sh interactively allows the user edit the text
  echo field in a formatted data file.
  echo pe_updatetext.sh [option] datafile
  echo Options
  echo -h prints this and quits.
  echo -v sets seltext to \'variable\' so presents for editing, only
  echo lines containing that value.
  echo -S presents only lines containing \'stable\' for editing.
  echo -s='$OPTARG' presents only those lines containing the value of
  echo '$OPTARG'
}

# options string
options=':hvs:S'
# the leading ':' in options string is required for the errors cases.

while getopts $options option
do
	case $option in
		v  ) seltext="variable";shift;;
		s  ) seltext=$OPTARG;shift;shift;;
		S  ) seltext="stable";shift;;
		h  ) usage; exit;;
		\? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
		:  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
		*  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
	esac
done

inf="$1"
if [[ ! -z "$seltext" ]]; then
  # get only lines containing '$selext' at field 5, ie before '\n'
  lines=$(grep -n "$seltext"'$' "$inf")
else
  # get all lines but with identical output formatting as above.
  lines=$(grep -n . "$inf")
fi

########################################################################
#     Stuff that can not be done in Bash
#   Loop (any kind while, for etc)
#   do
#     init some variables
#
#     run some interactive script for user input
#
#   done < data_file
#
#   What does work is a purpose built interactive script.
#
#   So what follows is an attempt to do just that.
########################################################################

# set up the script header
sfn=runupdate.sh
cat << ENDheader > ./"$sfn"
#!/bin/bash
split() # splits a line into variables
{
  local lline="\$1"
  lno=\$(echo "\$lline" | cut -d':' -f1) # grep -n gave us \$lline
  local dline=\$(echo "\$lline" | cut -d':' -f2) # all of the rest
  comment=\$(echo "\$dline" |cut -d"," -f1)
  x=\$(echo "\$dline" |cut -d"," -f2) # x, points from left of form.
  y=\$(echo "\$dline" |cut -d"," -f3) # y, points from bottom of form.
  text=\$(echo "\$dline" |cut -d"," -f4) # text to print on form.
  selector=\$(echo "\$dline" |cut -d"," -f5) # word to choose line.
}

ENDheader

# Now, generate the main part of the script

# provide some instructions for the user.
cat << ENDinst >> ./"$sfn"
dfn="\$1"
echo This program will output a prompt, text followed by ':', then the \
text that exists. You may change, delete and replace this text any way \
you like.
echo To retain any existing text, just hit 'Enter' without altering \ anything.
echo If there is any field that you want to be empty just replace the \
field content with an underscore \('_'\).
read -e -p 'Enter to continue:' nothing
echo
ENDinst

# put the data lines in a temporary file
tfn=tfn$$
rm ./tfn*
cat << END1 > ./"$tfn"
$lines
END1
# these data lines may have embedded spaces so wrap them with '"'.
sed -i "s/.*/\"&\"/" ./"$tfn"
# had difficulty removing an eol escape from last line so:
lc=$(wc -l ./"$tfn")
lc=$(echo "$lc" |cut -d' ' -f1)
let lc--
lastline=$(tail -n1 ./"$tfn")
lines=$(head -n"$lc" ./"$tfn")
# process data lines in a for loop.
echo "for line in" > ./"$tfn"  # file truncated and rewritten
cat << END2 >> ./"$tfn"
$lines
END2
# need to escape the newlines in the data line block.
sed -i 's!$! \\!' ./"$tfn"
# the last line eol is not escaped
echo "$lastline" >> ./"$tfn"
# actual processing for the loop
cat << END3 >> ./"$tfn"
do
  split "\$line"
  read -e -p "\$comment"": " -i "\$text" textin
  if [[ "\$text" != "\$textin" ]];then
    sed -i "\$lno s!\$text!\$textin!" "\$dfn"
  fi
done
END3

# append the temp file to the script
cat ./"$tfn" >> ./"$sfn"

# so now run it
./"$sfn"
