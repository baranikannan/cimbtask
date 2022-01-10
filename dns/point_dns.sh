#!/bin/bash
str=$1
if [[ $str =~ ['!@#$%^&*()_+'] ]];
then
    echo "Env has special characters"
    exit 1
elif [[ -z $str  ]];
then
  echo "Env cannot be Null"
  exit 1  
elif [[ $str =~ "default" ]];
then
  echo "Env name cannot be default"
  exit 1    
else
    echo "Workspace is $str"
fi

terraform init
terraform apply -var app_version=$str -auto-approve