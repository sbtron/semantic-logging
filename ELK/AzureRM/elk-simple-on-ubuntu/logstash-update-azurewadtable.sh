#!/bin/bash
#
# ========================================================================================
# Microsoft patterns & practices (http://microsoft.com/practices)
# SEMANTIC LOGGING APPLICATION BLOCK
# ========================================================================================
#
# Copyright (c) Microsoft.  All rights reserved.
# Microsoft would like to thank its contributors, a list
# of whom are at http://aka.ms/entlib-contributors
#
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License. You may
# obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied. See the License for the specific language governing permissions
# and limitations under the License.
#

help()
{
    echo ""
    echo ""
	echo "This script configures azurewadtables plugin for logstash"
	echo "Parameters:"
	echo "a - The diagnostics storage account name"
	echo "k - The diagnostics storage account key"
	echo "t - The table names containing diagnostics data separate by ;"
	echo "e - The encoded configuration string."
	echo ""
	echo ""
	echo ""
}

log()
{
	echo "$1"
}

#Loop through options passed
while getopts :a:k:t:e:h optname; do
    log "Option $optname set with value ${OPTARG}"
  case $optname in
    h)  #show help
      help
      exit 2
      ;;
    a)  #set storage account name
	  log "Setting the storage account name"
      STORAGE_ACCOUNT_NAME="${OPTARG}"
      ;;
    k)  #set storage account key
	  log "Setting the storage account key"
      STORAGE_ACCOUNT_KEY="${OPTARG}"
      GEN_CONF_FILE="true"
      ;;
    t)  #set table names
	  log "Setting the diagnostics log table names"
      TABLE_NAMES="${OPTARG}"
      USE_TABLE_NAMES="true"
      ;;
    e)  #set the encoded configuration string
	  log "Setting the encoded configuration string"
      CONF_FILE_ENCODED_STRING="${OPTARG}"
      USE_CONF_FILE_FROM_ENCODED_STRING="true"
      exit 2
      ;;
    \?) #unrecognized option - show help
      echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
      help
      exit 2
      ;;
  esac
done


# Install User Configuration from encoded string
if [ ! -z $USE_CONF_FILE_FROM_ENCODED_STRING ] 
then
  log "Decoding configuration string"
  log "$CONF_FILE_ENCODED_STRING"
  echo $CONF_FILE_ENCODED_STRING > logstash.conf.encoded
  DECODED_STRING=$(base64 -d logstash.conf.encoded)
  log "$DECODED_STRING"
  echo $DECODED_STRING > ~/logstash.conf
fi

if [ ! -z $GEN_CONF_FILE ] 
then
  log "Generating Logstash Config"
  echo "input { " > ~/logstash.conf
  if [ ! -z $USE_TABLE_NAMES ] 
  then
  log "Using specified table names"
  TABLE_ARRAY=$(echo $TABLE_NAMES | tr ";" "\n")
  for TABLE in $TABLE_ARRAY
     do
       echo "azurewadtable {account_name => '$STORAGE_ACCOUNT_NAME' access_key => '$STORAGE_ACCOUNT_KEY' table_name => '$TABLE'}" >> ~/logstash.conf      
  done
  else
  log "Using Default table names"
  echo "azurewadtable {account_name => '$STORAGE_ACCOUNT_NAME' access_key => '$STORAGE_ACCOUNT_KEY' table_name => 'WADLogsTable'}" >> ~/logstash.conf
  echo "azurewadtable {account_name => '$STORAGE_ACCOUNT_NAME' access_key => '$STORAGE_ACCOUNT_KEY' table_name => 'WADPerformanceCountersTable'}" >> ~/logstash.conf
  echo "azurewadtable {account_name => '$STORAGE_ACCOUNT_NAME' access_key => '$STORAGE_ACCOUNT_KEY' table_name => 'WADWindowsEventLogsTable'}" >> ~/logstash.conf
  echo "azurewadtable {account_name => '$STORAGE_ACCOUNT_NAME' access_key => '$STORAGE_ACCOUNT_KEY' table_name => 'WADDiagnosticInfrastructureLogsTable'}" >> ~/logstash.conf
  fi
  echo " }" >> ~/logstash.conf
  echo "output {elasticsearch {host => 'localhost' protocol => 'http' port => 9200 }}" >> ~/logstash.conf
  cat ~/logstash.conf
fi

#log "Installing user configuration file"
log "Installing user configuration file"
sudo \cp -f ~/logstash.conf /etc/logstash/conf.d/

# Configure Start
log "Restart logstash service"
sudo service logstash stop
sudo service logstash start

