# pe_functions.sh - not a full script. To be sourced as required for
#                   pe_*.sh scripts

# filelc returns the line count of a file as a number
filelc()
{
  local llc=$(wc -l "$1")
  if [[ $? -ne 0 ]];then
    lc=-1
    return
  fi
  lc=$(echo "$llc" | cut -d' ' -f1)
}

# config.lst is in the directory where pdf edits are done.
# the data is of the form <a name>:<filename>
# given the <name>, the script returns the <filename>
# the second parameter if it exists restricts the <filename>
# returned. If <filename> is multiple, a space separated list will be
# returned.
getconfig()
{
  if [[ ! -f ./config.lst ]];then
    Echo "configuration file config.lst does not exist."
    exit 1
  fi
  if [[ -z "$1" ]];then
    echo "No parameter supplied to funtion getconfig, quitting."
    exit 1
  fi
  local ret=
  if [[ -n "$2" ]];then
    ret=$(grep "$1" ./config.lst |grep "$2")
  else
    ret=$(grep "$1" ./config.lst)
  fi
  if [[ $? -ne 0 ]];then
    echo "$1" is not in ./config/lst.
    return
  fi
  prm=$(echo "$ret" |cut -d: -f2)
}

getpageno()
{ # extract the page number from the lists of PDF 1 page files.
  local inf=$(basename "$1" dat)pdf
  echo "$inf"
  # list of burst pages
  local gpnburst="gpnburst"$(date +"%Y-%m-%d-%H-%M-%S")
  grep 'burst' config.lst > "$gpnburst"
  local gpnlist="gpnlist"$(date +"%Y-%m-%d-%H-%M-%S")
  grep -n . "$gpnburst" > "$gpnlist"
  rm "$gpnburst"
  local line=$(grep "$inf" "$gpnlist")
  retpno=$(echo "$line" |cut -d: -f1)
  rm "$gpnlist"
}
