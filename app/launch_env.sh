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
terraform workspace new $str
ret=$?
if [ $ret -ne 0 ]; then
        echo "Workspace already exists"
        exit 1
else
        echo ""
fi
terraform plan -var-file=test.tfvars -var app_version=$str
ret=$?
if [ $ret -ne 0 ]; then
        echo "Plan fails, Please check"
        exit 1
else
        echo ""
fi
terraform apply -var-file=test.tfvars -var app_version=$str -auto-approve