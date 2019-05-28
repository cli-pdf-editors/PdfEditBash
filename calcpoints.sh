#!/bin/bash
#
# calcpoints.sh - script to calculate points distance from other units.
#
# Copyright 2018 Robert L (Bob) Parker rlp1938@gmail.com
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
decinches()
{
  local p=$(echo $1 \* 72 | bc -l)
  # truncate the returned value at the decimal point.
  points=$(echo $p | cut -d'.' -f1)
  optflag=1
}
fracinches()
{
  # user has input something like '5+3/8', I need to have '5 + (3 / 8)'
  # to present to bc.
  local whole=$(echo "$1" | cut -d'+' -f1)
  local fract=$(echo "$1" | cut -d'+' -f2)
  local numer=$(echo "$fract" | cut -d'/' -f1)
  local denom=$(echo "$fract" | cut -d'/' -f2)
  local calc="$whole"" + ""(""$numer"" / ""$denom"")"
  local decin=$(echo "$calc" | bc -l)
  local p=$(echo $decin \* 72 | bc -l)
  # truncate the returned value at the decimal point.
  points=$(echo $p | cut -d'.' -f1)
  optflag=1
}
centimeters()
{
  local p=$(echo $1 / 2.54 \* 72 | bc -l)
  # truncate the returned value at the decimal point.
  points=$(echo $p | cut -d'.' -f1)
  optflag=1
}
millimeters()
{
  local p=$(echo $1 / 25.4 \* 72 | bc -l)
  # truncate the returned value at the decimal point.
  points=$(echo $p | cut -d'.' -f1)
  optflag=1
}
points()
{ #no actual conversion
  local p="$1"
  # truncate the returned value at the decimal point.
  points=$(echo $p | cut -d'.' -f1)
  optflag=1
}

# write actual usage
usage () { echo "Choose the units input to convert to points"
  echo "-h - prints this and exits."
  echo "-i - Input units to be eg 5.375 inches"
  echo "-f - Input units to be eg 5+3/8 inches"
  echo "-c - Input units to be eg 12.4 cm"
  echo "-m - Input units to be eg 124 mm"
  echo "-p - Input units to be eg 432 points"
  }

# options string
options=':ifcmph'
# the leading ':' in options string is required for the errors cases.
optflag=0
while getopts $options option
do
	case $option in
		i  ) shift;decinches "$1";;
		f  ) shift;fracinches "$1";;
		c  ) shift;centimeters "$1";;
		m  ) shift;millimeters "$1";;
		p  ) shift;points "$1";;
		h  ) usage; exit;;
		\? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
		:  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
		*  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
	esac
done
if [[ "$optflag" -ne 1 ]]; then
  centimeters "$1"
fi

echo "$points"
