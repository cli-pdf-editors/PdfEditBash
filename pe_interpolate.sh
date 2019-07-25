#!/usr/bin/env bash
#
# pe_interpolate.sh - script to interpolate values between 2 points.
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

# set defaults


# write actual usage
usage () {
  cat << ENDhelp
  
  pe_interpolate.sh interpolates values between 2 given points

  SYNOPSIS
    pe_interpolate.sh Direction Startline Endline numDataPoints
  DESCRIPTION
    Direction is to be X or Y, case insensitive.
    Startline and Endline are the lines from the form data file
    describing the starting and ending data points.
    numDatapoints must be a whole number, no decimal point.
    The program outputs all of the data lines including the start and
    finish lines.
    For direction Y, the point value of X is repeated and Y values are
    interpolated, similarly for direction X. The comment field, field 1,
    will be appended with an increasing number beginning with 1.
    Normally, for direction Y, the comment field will be meaningless
    and will need to be edited afterward but for X the comment value
    should describe the location on the form.
    The calculated output values are rounded to 2 places of decimals.
    
  OPTIONS
  -h
    Prints this help message

  EXAMPLES
  pe_interpolate.sh Y line,100,220,X,stable wtf,100,160,X,whatever 4
      line1,100,220,X,stable
      line2,100,205,X,stable
      line3,100,190,X,stable
      line4,100,180,X,stable
  Obviously, when interpolating in the Y direction field 1 will need
  to be edited afterward.

  pe_interpolate.sh x 'Family name,31.76,592.5,X,stable' 'Family name,279.5,592.5,X,stable' 23
      Family name1,31.76,592.5,X,stable
      Family name2,43.02,592.5,X,stable
      ...
      Family name22,268.24,592.5,X,stable
      Family name23,279.50,592.5,X,stable
ENDhelp
}

# options string
options=':h'
# the leading ':' in options string is required for the errors cases.
numonly=0;
while getopts $options option
do
	case $option in
		h  ) usage; exit;;
		\? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
		:  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
		*  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
	esac
done

if [[ $# -ne 4 ]];then
  echo "Requires 4 input args, not $#, quiting."
  usage
fi
direction=$(echo "$1" |tr 'a-z' 'A-Z')
if [[ "$direction" != "X" ]] && [[ "$direction" != "Y" ]];then
  echo Direction must be either X or Y, not "$direction", case insensitve.
  usage
fi

start="$2"
end="$3"
num="$4"
# split the starting line into it's fields.
startCmnt=$(echo "$start" |cut -d, -f1)
startX=$(echo "$start" |cut -d, -f2)
startY=$(echo "$start" |cut -d, -f3)
startText=$(echo "$start" |cut -d, -f4)
startSelText=$(echo "$start" |cut -d, -f5)
# split the ending line into X and Y fields
endX=$(echo "$end" |cut -d, -f2)
endY=$(echo "$end" |cut -d, -f3)
let num-- # if we have 4 lines we have 3 spaces and so on.
tfn=values$(date +"%Y-%m-%d-%H-%M-%S")
if [[ $direction = "X" ]];then
  dist=$(echo "$endX - $startX" |bc -l)
  delta=$(echo "$dist / $num" |bc -l)
  baseval="$startX"
else
  dist=$(echo "$endY - $startY" |bc -l)
  delta=$(echo "$dist / $num" |bc -l)
  baseval="$startY"
fi
for i in {0..1000}
do
  if [[ $i -gt "$num" ]]; then break; fi
  val=$(echo "$baseval + $delta * $i" |bc -l)
  # rounding
  val=$(echo $val + 0.005| bc -l)
  w=$(echo $val |cut -d. -f1)
  f=$(echo $val |cut -d. -f2 |cut -c -2)
  val=$w.$f
  echo $val >> "$tfn"
  let i++
done

# assemble the output lines
let i=0
while IFR= read -u3 val
do
  let i++
  if [[ $direction = "X" ]];then
    Y=$startY
    X=$val
  else
    X=$startX
    Y=$val
  fi
  cmt="$startCmnt""$i"
  text=$startText
  selText="$startSelText"
  echo "$cmt","$X","$Y","$text","$selText"
done 3< "$tfn"
rm "$tfn"
