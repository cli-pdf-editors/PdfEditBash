#!/usr/bin/env bash
#
# checkstatus.sh - script to check status of installed scripts
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

# make a temporary file and put the md5sum data into it.
tf=status$(date +"%Y-%m-%d-%H-%M-%S")
echo "$tf"
for f in pe_*.sh
# if any script has never been copied to /usr/local/bin, then the file
# pairing logic further down will generate nonsense so just quit on
# that error and get it fixed first.
do
  md5sum /usr/local/bin/"$f" "$f" >> "$tf"
  if [[ $? -ne 0 ]];then
    rm "$tf"
    exit 1;
  fi
done

# Examine the sums of the top 2 lines and report any that differ.
# Discard the line pairs and repeat until the file is empty.
while :
do
  l1=$(head -1 "$tf")
  if [[ -z "$l1" ]]; then break; fi
  s1=$(echo "$l1" |cut -d' ' -f1)
  l2=$(head -2 "$tf" | tail -1)
  if [[ -z "$l2" ]]; then break; fi
  s2=$(echo "$l2" |cut -d' ' -f1)
  if [[ "$s1" != "$s2" ]]; then
    echo "$l1"
    echo "$l2"
  fi
  sed -i '1,2d' "$tf"
done
rm "$tf"
