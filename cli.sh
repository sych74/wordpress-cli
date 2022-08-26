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
  output=$(jq -cn --argjson  result "$result" --arg response "${response}"  '{result: $result, response: $response}')
  echo "${output}"
}

execAction(){
  local action="$1"
  local message="$2"

  stderr=$( { ${action}; } 2>&1 ) && { log "${message}...done"; execResponse "${SUCCESS_CODE}" "$( ${action} )" ; } || {
    error="${message} failed, please check ${RUN_LOG} for details"
    execResponse "${FAIL_CODE}" "${error}"
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
        execAction "getCoreVersion" 'Get core version'
        ;;

    getPlugins)
        execAction "getPluginsList" 'Get plugins list'
        ;;

esac
