#!/bin/bash

WP_PATH="/var/www/webroot/ROOT"
WP=`which wp`
RUN_LOG="/tmp/japp.log"
SUCCESS_CODE=0
FAIL_CODE=99

wpCommandExec(){
  command="$1"
  $WP --path=$WP_PATH $command
}

log(){
  local message="$1"
  local timestamp
  timestamp=`date "+%Y-%m-%d %H:%M:%S"`
  echo -e "[${timestamp}]: ${message}" >> ${RUN_LOG}
}

execResponse(){
  local result=$1
  local response=$2
  local isJSON="$3"

  if ${isJSON}; then
    output=$(jq -cn --raw-output --argjson result "$result" --argjson response "${response}" '{result: $result, response: $response}')
  else
    output=$(jq -cn --raw-output --argjson result "$result" --arg response "${response}" '{result: $result, response: $response}')
  fi
  echo ${output}
}

execAction(){
  local action="$1"
  local message="$2"
  local isJSON="$3"

  stderr=$( { ${action}; } 2>&1 ) && { log "${message}...done"; execResponse "${SUCCESS_CODE}" "$( ${action} )" "${isJSON}" ; } || {
    error="${message} failed, please check ${RUN_LOG} for details"
    execResponse "${FAIL_CODE}" "${error}" "false"
    log "${message}...failed\n==============ERROR==================\n${stderr}\n============END ERROR================";
    exit 0
  }
}

getCoreVersion(){
  wpCommandExec 'core version'
}

getPluginsList(){
  wpCommandExec 'plugin list --format=json'
}

case ${1} in
    getVersion)
        execAction "getCoreVersion" 'Get core version' 'false'
        ;;

    getPlugins)
        execAction "getPluginsList" 'Get plugins list' 'true'
        ;;

esac
