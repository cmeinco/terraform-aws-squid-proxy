#!/usr/bin/env bash

# if terraform does not exist
if [ ! -f ./terraform ]; then
    echo "Terraform not found!, going to get the latest and greatest..."
    latest_version=$(curl --silent https://releases.hashicorp.com/terraform/ | grep href | grep terraform | head -1 | awk -F"/" '{print $3}')
    echo "downloading ${latest_version}"
    wget https://releases.hashicorp.com/terraform/${latest_version}/terraform_${latest_version}_linux_amd64.zip
    unzip terraform_${latest_version}_linux_amd64.zip
fi



# region needed if default in creds profile is different 
#set_region="--region us-east-1 "
