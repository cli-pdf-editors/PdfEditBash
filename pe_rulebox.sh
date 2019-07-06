#!/usr/bin/env bash
#
# pe_rulebox.sh - script to rule a box overlayed onto a PDF form and to
#             record that position data to calculate the x and y
#             postions of objects on that form.
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
# functions
splitps()
{ # split a postscript file in 2 at location of "showpage"
  local psfn="$1"
  local lines=$(wc -l "$psfn")
  lines=$(echo "$lines" | cut -d' ' -f1)
  local split=$(grep -n showpage "$psfn")
  split=$(echo "$split" | cut -d':' -f1)
  let split-=1 # want the line containing 'showpage' in the bottom.
  local lower=$(expr "$lines" - "$split")
  head -n"$split" "$psfn" > top
  tail -n"$lower" "$psfn" > btm
}

# bailout if config.lst ain't there.
if [[ ! -f "config.lst" ]];then
  echo "No config file, please run pe_initform.sh first."
  exit 1
fi
# set defaults
datumL=10
datumB=10
datumT=835
datumR=586

scriptfrom=$(cd ${BASH_SOURCE[0]%/*}; pwd)
source pe_functions.sh

# write actual usage
usage () {
  cat << ENDhelp
  pe_rulebox.sh - overlays a rectangular box onto a PDF form.

  SYNOPSIS
    pe_rulebox.sh
    pe_rulebox.sh [option]

  DESCRIPTION
    When run without options for the first time, draws the box using a
    set of default parameters, and records those parameters in the user
    working directory for later editing if needed. Subsequent runs use
    the parameters from that file, .rulebox.cfg.

    The ruled box is intended to provide datums for measuring distances
    in centimeters to objects on the PDF form to calculate distances in
    points. Consequently, the form must be printed for this purpose.
    The box exists only on this print. It will not appear on any other
    edits.

  OPTIONS
    -h - outputs this help.
    -e - opens .rulebox.cfg in the users editor.
    -r - registers the data in .rulebox.cfg in config.lst for access by
          pe_PointPosition.sh
    -c - cleanup workfiles. Destroys .rulebox.cfg.

  SEE ALSO
    pe_havebox.sh may be used when the original PDF has an existing box
    suitable for use as datums to measure form objects from.

ENDhelp
}

# options string
options=':herc'
# the leading ':' in options string is required for the errors cases.

while getopts $options option
do
	case $option in
		e  ) ep=$(grep editor config.lst |cut -d: -f2)
          "$ep" .rulebox.cfg
        ;;
		r  )
        # if .rulebox.cfg looks sensible, replace anything previously
        # registered in config.lst with the contents.
        lc=$(cat .rulebox.cfg |wc -l)
        if [[ $lc -ne 4 ]];then echo bad .rulebox.cfg, bye; exit 1; fi
        sed  -i '/datum.:/d' config.lst
        cat .rulebox.cfg >> config.lst
        exit 0
        ;;
		c  ) rm .rulebox.cfg; exit 0 ;;
		h  ) usage; exit;;
		\? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
		:  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
		*  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
	esac
done

if [[ -f .rulebox.cfg ]];then
  while IFS= read -r line
  do
    line=$(echo "$line" |tr : =)
    eval "$line"
  done < .rulebox.cfg
else
  echo datumL:"$datumL" > .rulebox.cfg
  echo datumB:"$datumB" >> .rulebox.cfg
  echo datumT:"$datumT" >> .rulebox.cfg
  echo datumR:"$datumR" >> .rulebox.cfg
fi

# Follows similar logic to pe_editps.sh
# Allow user to choose a page, or default to page 1.
# This will allow for a situation where different editable pages have
# been created using different margins.
if [[ -z "$1" ]];then
  page=1
else
  page="$1"
fi
inputfile=$(grep "name:" config.lst |cut -d: -f2)
barefilename=$(basename "$inputfile" .pdf)
pdftk "$inputfile" burst output "$barefilename"_%0.3d.pdf
page=$(printf "_%0.3d" $page)
targetfile="$barefilename""$page".pdf

# Sanity checks, 1. the target file must exist,
# and 2. it must be in the 'toedit' group.
if [[ ! -f "$targetfile" ]];then
  echo No such file "$targetfile"; exit 1
fi
checkfile=$(grep "$targetfile" config.lst |grep "toedit")
if [[ -z "$checkfile" ]];then
  echo "$targetfile" not in edit list; exit 1
fi

# The option '-paper match' MUST be used or the printed result is not
# useable for the intended purpose.
pdftops -paper match "$targetfile" psfile
# split the postscript file at the line 'showpage'
splitps psfile
# Build up the postscript statements in a file called mid
if [[ -f mid ]];then rm mid; fi
touch mid
# Draw the box in mid
cat << ENDmid >> mid
newpath
$datumL $datumB moveto
$datumL $datumT lineto
$datumR $datumT lineto
$datumR $datumB lineto
closepath
stroke
ENDmid
# put the postscript file together again
cat top > psfile
cat mid >> psfile
cat btm >> psfile
ps2pdf psfile "$targetfile"

# To display or not?
fp=$(grep 'viewer:' config.lst |cut -d: -f2)
vp=$(basename "$fp")  # needed for pgrep
pgrep -f -a "$vp"
if [[ $? -ne 0 ]];then
  "$fp" "$targetfile" &
else
  lsof "$targetfile" 2> /dev/null
  if [[ $? -ne 0 ]];then
    "$fp" "$targetfile" &
  fi
fi
