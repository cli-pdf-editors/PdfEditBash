#!/bin/bash
#
# userinput.sh - input script to get user input
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

# where do my executeables live?
exp=$(realpath "$0")
exp=$(dirname "$exp")
opfn="$1"
# reads user data for 4 variables and emits a comma separated list.
while :
do
  read -e -p "Field name on form (comment entry): " comment
  if [[ "$comment" == "end" ]];then exit 0; fi
  read -e -p "Location from left: " X
  read -e -p "Location from bottom: " Y
  read -e -p "Default text: " text
  read -e -p "Selector: " -i "stable variable" selector
  X=$("$exp"/calcpoints.sh "$X") # input units to points
  Y=$("$exp"/calcpoints.sh "$Y") # input units to points
  line="$comment","$X","$Y","$text","$selector"
  echo "$line"
  echo "$line" >> "$opfn"
done
