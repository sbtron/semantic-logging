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

log()
{
	echo $1
	logger "elk-simple-on-ubuntu:" $1
}

#Loop through options passed
while getopts :n:v:d:e:a:k:sh optname; do
    log "Option $optname set with value ${OPTARG}"
  case $optname in
	n)
	  ES_CLUSTER_NAME=${OPTARG}
	  ;;
	v)
	  ES_VERSION=${OPTARG}
	  ;;
	d)
	  ES_DISCOVERY_HOSTS=${OPTARG}
	  ;;
	e)
	  ENCODED_LOGSTASH_CONFIG=${OPTARG}
	  ;;
	a)
	  STORAGE_ACCOUNT=${OPTARG}
	  ;;
	k)
	  STORAGE_KEY=${OPTARG}
	  ;;
	s)  #skip common install steps
	  SKIP_COMMON_INSTALL="YES"
	  ;;
    h)  #show help
      help
      exit 2
      ;;
    \?) #unrecognized option - show help
      echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
      help
      exit 2
      ;;
  esac
done

#ELK (Simple) Install Script
mkdir /opt/elk-simple/
sudo \cp -f elasticsearch-ubuntu-install.sh /opt/elk-simple/elasticsearch-ubuntu-install.sh
sudo \cp -f logstash-install-ubuntu.sh /opt/elk-simple/elasticsearch-ubuntu-install.sh
sudo \cp -f kibana4-install-ubuntu.sh /opt/elk-simple/kibana4-install-ubuntu.sh
sudo \cp -f azurewadtable.rb /opt/elk-simple/azurewadtable.rb

cd /opt/elk-simple/
#wget https://raw.githubusercontent.com/juliusl/azure-quickstart-templates/master/elasticsearch/elasticsearch-ubuntu-install.sh
#wget https://raw.githubusercontent.com/sbtron/semantic-logging/elk/ELK/AzureRM/logstash-on-ubuntu/logstash-install-ubuntu.sh
#wget https://raw.githubusercontent.com/sbtron/semantic-logging/elk/ELK/AzureRM/elk-simple-on-ubuntu/kibana4-install-ubuntu.sh

#Install ELK
log "Installing Elasticsearch" 
bash ./elasticsearch-ubuntu-install.sh -n $ES_CLUSTER_NAME -v $ES_VERSION -d $ES_DISCOVERY_HOSTS
log "Installing Elasticsearch Completed"

#Install Logstash
log "Installing Logstash"
bash ./logstash-install-ubuntu.sh -a $STORAGE_ACCOUNT -k $STORAGE_KEY
log "Installing Logstash Completed"

log "Installing Kibana 4"
bash ./kibana4-install-ubuntu.sh
log "Installing Kiibana 4 Completed"
