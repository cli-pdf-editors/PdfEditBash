#!/usr/bin/env bash
#
# pe_PointPosition.sh - script to calculate the position in points
#                       from named datums on a form. The datums are
#                       L, a line on the left of the form, B, line on
#                       the bottom, R, from the right, T from the top.
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

sub=0 # only want signless numbers from user.
datumid=$(echo "$1" |tr "[:lower:]" "[:upper:]")
distcm="$2"
while :
do
  case $datumid in
    B ) gvar=datumB; svar=scaleY; break ;;
    L ) gvar=datumL; svar=scaleX; break ;;
    T ) gvar=datumT; svar=scaleY; sub=1; break ;;
    R ) gvar=datumR; svar=scaleX; sub=1; break ;;
    * ) echo Invalid parameter $datumid, one of \'BbLlTtRr\' required.
        exit 1 ;;
  esac
done
if [[ -z "$distcm" ]];then echo "No distance provided."; exit 1; fi

datumline=$(grep "$gvar" config.lst)
res=$?
if [[ $res -ne 0 ]];then
  echo "Measurement datums not provided, quitting"
  exit 1
fi
datum=$(echo -n "$datumline" |cut -d: -f2)

scaleline=$(grep "$svar" config.lst)
res=$?
if [[ $res -ne 0 ]];then
  echo "Scale factors not provided, quitting"
  exit 1
fi
scale=$(echo -n "$scaleline" |cut -d: -f2)

if [[ sub -eq 1 ]];then
  res=$( echo "$datum - $distcm * $scale" |bc -l)
else
  res=$( echo "$datum + $distcm * $scale" |bc -l)
fi

# round $res to 2 places
res=$(echo "$res + 0.005" |bc -l)
w=$(echo $res |cut -d. -f1)
f=$(echo $res |cut -d. -f2)
f=$(echo $f |cut -c 1,2)
res=$w.$f
echo $res
