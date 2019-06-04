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

echo $1 $2
echo $seltext
