#!/usr/bin/env bash
#
# apploader
# Version v0.1.0
#
# Copyright (c) 2014 nico lindemann
# Licensed under MIT: https://raw.githubusercontent.com/nicolindemann/apploader/master/LICENSE
#
# Usage:
#  ./apploader.sh -u http://ITUNESURL
#
#
# Based on BASH3 Boilerplate v0.1.0 (https://github.com/kvz/bash3boilerplate)
# Licensed under MIT: http://kvz.io/licenses/LICENSE-MIT
# Copyright (c) 2013 Kevin van Zonneveld
# http://twitter.com/kvz
#


### Configuration
#####################################################################

# Environment variables
[ -z "${LOG_LEVEL}" ] && LOG_LEVEL="6" # 7 = debug, 0 = emergency

# Commandline options. This defines the usage page, and is used to parse cli opts & defaults from.
# Parsing is unforgiving so be precise in your syntax:
read -r -d '' usage <<-'EOF'
  -u     [arg] URL to process. Required.
  -posX        X Position of button in iTunes. Default: 170, Assuming Resolution of 1680x1050
  -poxY        Y Position of button in iTunes. Default: 390, Assuming Resolution of 1680x1050
  -d           Enables debug mode
  -c           Decolorize the output
  -h           This page
EOF

# Set magic variables for current FILE & DIR
__DIR__="$(cd "$(dirname "${0}")"; echo $(pwd))"
__FILE__="${__DIR__}/$(basename "${0}")"


### Functions
#####################################################################


### Defaults
arg_c=0
arg_posX=170
arg_posY=390

function _fmt ()      {
  local color_ok="\033[1;32m"
  local color_bad="\033[1;31m"

  local color="${color_bad}"
  if [ "${1}" = "debug" ] || [ "${1}" = "info" ] || [ "${1}" = "notice" ]; then
    color="${color_ok}"
  fi

  local color_reset="\033[1;0m"
  if [ "${arg_c}" = "1" ] || [ -t 1 ]; then
    # Don't use colors on pipes or non-recognized terminals
    color=""; color_reset=""
  fi
  echo -e "$(date -u +"%Y-%m-%d %H:%M:%S UTC") ${color}$(printf "[%9s]" ${1})${color_reset}";
}
function emergency () {                             echo "$(_fmt emergency) ${@}" 1>&2 || true; exit 1; }
function alert ()     { [ "${LOG_LEVEL}" -ge 1 ] && echo "$(_fmt alert) ${@}" 1>&2 || true; }
function critical ()  { [ "${LOG_LEVEL}" -ge 2 ] && echo "$(_fmt critical) ${@}" 1>&2 || true; }
function error ()     { [ "${LOG_LEVEL}" -ge 3 ] && echo "$(_fmt error) ${@}" 1>&2 || true; }
function warning ()   { [ "${LOG_LEVEL}" -ge 4 ] && echo "$(_fmt warning) ${@}" 1>&2 || true; }
function notice ()    { [ "${LOG_LEVEL}" -ge 5 ] && echo "$(_fmt notice) ${@}" 1>&2 || true; }
function info ()      { [ "${LOG_LEVEL}" -ge 6 ] && echo "$(_fmt info) ${@}" 1>&2 || true; }
function debug ()     { [ "${LOG_LEVEL}" -ge 7 ] && echo "$(_fmt debug) ${@}" 1>&2 || true; }

function help () {
  echo "" 1>&2 
  echo " ${@}" 1>&2 
  echo "" 1>&2 
  echo "  ${usage}" 1>&2 
  echo "" 1>&2 
  exit 1
}

function cleanup_before_exit () {
  info "Cleaning up. Done"
}
trap cleanup_before_exit EXIT


### Parse commandline options
#####################################################################

# Translate usage string -> getopts arguments, and set $arg_<flag> defaults
while read line; do
  opt="$(echo "${line}" |awk '{print $1}' |sed -e 's#^-##')"
  if ! echo "${line}" |egrep '\[.*\]' >/dev/null 2>&1; then
    init="0" # it's a flag. init with 0
  else
    opt="${opt}:" # add : if opt has arg
    init=""  # it has an arg. init with ""
  fi
  opts="${opts}${opt}"

  varname="arg_${opt:0:1}"
  if ! echo "${line}" |egrep '\. Default=' >/dev/null 2>&1; then
    eval "${varname}=\"${init}\""
  else
    match="$(echo "${line}" |sed 's#^.*Default=\(\)#\1#g')"
    eval "${varname}=\"${match}\""
  fi
done <<< "${usage}"

# Reset in case getopts has been used previously in the shell.
OPTIND=1

# Overwrite $arg_<flag> defaults with the actual CLI options
while getopts "${opts}" opt; do
  line="$(echo "${usage}" |grep "\-${opt}")"


  [ "${opt}" = "?" ] && help "Invalid use of script: ${@} "
  varname="arg_${opt:0:1}"
  default="${!varname}"

  value="${OPTARG}"
  if [ -z "${OPTARG}" ] && [ "${default}" = "0" ]; then
    value="1"
  fi

  eval "${varname}=\"${value}\""
  debug "cli arg ${varname} = ($default) -> ${!varname}"
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift


### Switches (like -d for debugmdoe, -h for showing helppage)
#####################################################################

# debug mode
if [ "${arg_d}" = "1" ]; then
  # turn on tracing
  set -x
  # output debug messages
  LOG_LEVEL="7"
fi

# help mode
if [ "${arg_h}" = "1" ]; then
  # Help exists with code 1
  help "Help using ${0}"
fi


### Validation (decide what's required for running your script and error out)
#####################################################################

[ -z "${arg_u}" ]     && help      "Setting a URL with -u is required"
[ -z "${LOG_LEVEL}" ] && emergency "Cannot continue without LOG_LEVEL. "


### Runtime
#####################################################################

# Exit on error. Append ||true if you expect an error.
# set -e is safer than #!/bin/bash -e because that is neutralised if
# someone runs your script like `bash yourscript.sh`
set -eu

# Bash will remember & return the highest exitcode in a chain of pipes.
# This way you can catch the error in case mysqldump fails in `mysqldump |gzip`
set -o pipefail

pgrep iTunes >/dev/null
if [ $? -eq 1 ]
then
  info "iTunes not already stared. Starting..."
  open -a itunes
  debug "Wait 5 Seconds to iTunes come up..."
  sleep 5
  pgrep iTunes >/dev/null
  if [ $? -eq 1 ]
  then
    error "Could not start iTunes."
  fi
fi
pgrep Safari  >/dev/null
if [ $? -eq 1 ]
then
  info "Safari not already stared. Starting..."
  open -a safari
  debug "Wait 5 Seconds to Safari come up..."
  sleep 5
  pgrep Safari >/dev/null
  if [ $? -eq 1 ]
  then
    error "Could not start Safari."
  fi
fi
debug "Open URL in Safari..."
open -a safari "${arg_u/http/itms}"
debug "iTunes should handle the URL, bringing it back in foreground..."
open -a itunes
debug "Maximize the iTunes-Window..."
osascript maximizer.scpt iTunes
debug "Wait 5 Seconds to iTunes open the AppStore-Page..."
sleep 5
debug "Click ones on ${arg_posX},${arg_posY}..."
./MouseTools -x ${arg_posX} -y ${arg_posY} -leftClick
debug "Jiggle the mouse..."
./MouseTools -x 1 -y ${arg_posY} -mouseSteps 100
debug "Click on ${arg_posX},${arg_posY} without releasing it..."
./MouseTools -x ${arg_posX} -y ${arg_posY} -leftClickNoRelease
debug "Release the click"
./MouseTools -releaseMouse
