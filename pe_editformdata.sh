#!/usr/bin/env bash
#
# pe_editformdata.sh - script to run a user's chosen editor on a form
#                       data file.
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
mk_tfn addfd
temp="$tfn"
getconfig toedit
echo "$prm" > "$temp"
filelc "$temp"
numpages="$lc"
rm $temp
if [[ -z "$1" ]];then
  read -p "Which page do you want to edit" -e page
else
  page="$1"
fi
if [[ "$page" -lt 1 ]] || [[ "$page" -gt "$numpages" ]];then
  echo "Page number out of range: $page"
  exit 1
fi
