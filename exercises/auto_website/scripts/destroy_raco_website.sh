#!/bin/bash

# automates the creation of a website and the AWS infrastructure for it to run in

# requirements
#   - aws cli installed
#   - aws environment set up,
#     i.e. the following environment variables set/exported
#      AWS_DEFAULT_PROFILE
#        OR
#      AWS_ACCESS_KEY_ID
#      AWS_SECRET_ACCESS_KEY
#      AWS_DEFAULT_REGION
#   - jq installed
#   - ChefDK installed

AWS_CMD=$(which aws)
JQ_CMD=$(which jq)
CREATOR_ID="raco"
CREATOR_NAME="Patrick Raco"
CREATOR_EMAIL="pataraco@gmail.com"
AWS_KEY_PAIR_NAME="$CREATOR_ID"
AWS_WEBSITE_INFRA_CF_STACK_NAME="${CREATOR_ID}-website-infra"
AWS_WEBSITE_CF_STACK_NAME="${CREATOR_ID}-website"

# define functions

disable_instance_termination_protection() {
# disable an instance's termination protection

   local _instance_name="$1"

   # get the instance ID
   echo "disabling termination protection for instance: $_instance_name"
   local _instance_id=$($AWS_CMD ec2 describe-instances --filters Name=tag:Name,Values=$_instance_name Name=instance-state-name,Values=running | jq -r .Reservations[].Instances[].InstanceId)
   $AWS_CMD ec2 modify-instance-attribute --instance-id $_instance_id --no-disable-api-termination
}

delete_cf_stack() {
# delete CloudFormation (CF) stack and wait for it
# uses AWS CLI
# usage:
#    delete_cf_stack STACK_NAME
# 

   local _cf_stack_name="$1"

   # check if the CF stack exists, if so delete it, otherwise state it
   $AWS_CMD cloudformation describe-stacks --stack-name $_cf_stack_name &> /dev/null
   if [ $? -eq 0 ]; then
      echo "deleting CloudFormation stack: $_cf_stack_name"
      $AWS_CMD cloudformation delete-stack --stack-name $_cf_stack_name
      if [ $? -eq 0 ]; then
         # wait for the stack delete to complete
         echo "waiting for CloudFormation stack delete to complete: $_cf_stack_name"
         $AWS_CMD cloudformation wait stack-delete-complete --stack-name $_cf_stack_name
         [ $? -ne 0 ] && { echo "CloudFormation stack delete did not complete: $_cf_stack_name"; exit 2; }
      fi
   else
      echo "CloudFormation stack does not exist - can't delete: $_cf_stack_name"
   fi
}

# sanity checks
# makes sure:
#    - required commands are available/installed
#    - AWS environment is set
echo "performing sanity checks"
[ -z "$AWS_CMD" ] && { echo "aws required to run this script"; exit 2; }
[ -z "$JQ_CMD" ] && { echo "jq required to run this script"; exit 2; }
if [ -z "$AWS_DEFAULT_PROFILE" ]; then
   [ -z "$AWS_ACCESS_KEY_ID" -a -z "$AWS_SECRET_ACCESS_KEY" -a -z "$AWS_DEFAULT_REGION" ] && { echo "AWS environment not set"; exit 2; }
fi

# get the website URL about to destroy
website_url=$($AWS_CMD elb describe-load-balancers --load-balancer-name ${CREATOR_ID}-website | jq -r .LoadBalancerDescriptions[].DNSName)
echo "URL of website you are about to delete: $website_url"
read -p "Are you sure you want to delete this website ['yes' to confirm]? " ans
[ "$ans" != "yes" ] && { echo "ok, not deleting the website"; exit; }

# disable termination protection on bastion and chef-server hosts
disable_instance_termination_protection ${CREATOR_ID}-bastion
disable_instance_termination_protection ${CREATOR_ID}-chef-server

# destroy the website using CloudFormation
echo "deleting website via CloudFormation"
delete_cf_stack $AWS_WEBSITE_CF_STACK_NAME

# destroy the website infrastructure using CloudFormation
echo "deleting website infrastructure via CloudFormation"
delete_cf_stack $AWS_WEBSITE_INFRA_CF_STACK_NAME

# delete s3 files and bucket
echo "deleting s3 bucket and files"
$AWS_CMD s3 rb s3://$CREATOR_ID --force

# delete SNS topic to get notifications
echo "deleting the SNS topic"
NOTIFICATION_ARN=$($AWS_CMD sns list-topics | grep "all-${CREATOR_ID}-notifications" | cut -d '"' -f4)
$AWS_CMD sns delete-topic --topic-arn $NOTIFICATION_ARN

# delete key pair
echo "deleting the key pair"
$AWS_CMD ec2 delete-key-pair --key-name $AWS_KEY_PAIR_NAME

echo "website destruction complete: $website_url"
