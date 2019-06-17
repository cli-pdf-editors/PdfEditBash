#!/usr/bin/env bash
#
# pe_datanames.sh - script to name required data files.
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
if [[ ! -f toedit.lst ]];then echo run pe_initform.sh; fi
while read -r line
do
  dfn=$(basename "$line" pdf)
  dfn="$dfn"dat
  echo "$dfn"
  touch "$dfn"
done < toedit.lst
