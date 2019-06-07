#!/bin/bash
#
# untiled.sh - script to interactively update data files used to
#               decribe edits to a postscript file.
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
#   What does work is a purpose built script which actually is
#   similar to unrolling a loop anyway.
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

# put the data lines in a temporary file
rm ./shit.dat
for i in "$lines"
do
echo "$i" >> ./shit.dat
done
# wrap the data lines
sed -i "s/.*/split \"&\"/" ./shit.dat
# put a 'junk' line after every existing line - pattern is 'aaa'
sed -i "s/$/\\naa\\nbb\\ncc\\nddd/" ./shit.dat

# replace the junk patterns aa..ddd with commands
sed -i "s/aa/read -e -p \"\$comment\"\" \" -i \"\$text\" textin/" ./shit.dat
sed -i "s/bb/echo textin is: \"\$textin\"/" ./shit.dat
sed -i "s/cc/echo \$y/" ./shit.dat
sed -i "s/ddd/echo \$text/" ./shit.dat


# append the temp file to the script
cat ./shit.dat >> ./"$sfn"
