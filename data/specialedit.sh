#!/bin/bash
#
# specialedit.sh - script to apply special edits, on a per form basis
#                  to a postscript file.
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
ofn="$1"
echo "% paint a white box over the top of a pink water mark." >> "$ofn"
echo newpath >> "$ofn"
echo 45 830 moveto >> "$ofn"
echo 245 830 lineto >> "$ofn"
echo 245 790 lineto >> "$ofn"
echo 45 790 lineto >> "$ofn"
echo 45 830 lineto >> "$ofn"
echo 1 setgray >> "$ofn"
echo fill >> "$ofn"
#echo stroke >> "$ofn"
