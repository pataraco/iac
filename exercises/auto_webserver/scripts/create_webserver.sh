#!/bin/bash

AWS_KEY_PAIR_NAME="raco"
AWS_PRIVATE_KEY_LOC="$HOME/.ssh/${AWS_KEY_PAIR_NAME}.pem"

# automates the creation of a webserver and the AWS infrastructure for it to run in

# create a key pair via CLI (if it doesn't exist)
aws ec2 describe-key-pairs --key-name $AWS_KEY_PAIR_NAME &> /dev/null
if [ $? -ne 0 ]; then
   echo "public key doesn't exist in AWS, creating key pair: $AWS_KEY_PAIR_NAME"
   aws ec2 create-key-pair --key-name $AWS_KEY_PAIR_NAME | jq -r .KeyMaterial > $AWS_PRIVATE_KEY_LOC
elif [ ! -f $AWS_PRIVATE_KEY_LOC ]; then
   echo "the public key exists in AWS: $AWS_KEY_PAIR_NAME"
   echo "but you don't seem to have access to the private key: $AWS_PRIVATE_KEY_LOC"
else
   echo "the public key already exists in AWS: $AWS_KEY_PAIR_NAME"
fi

# I. create the infrastructure in AWS via AWS CLI and CloudFormation (CF)
#   1. create a json file for CF that does the following:
#     - create the Netorking: VPC, Subnet(s), GW'S, SG's
#     - create the ELB with health check (should be possible with CF)
#        - health check, SG's, etc...
#     - create lamda function to update the SG for the ELB (not sure if possible with CF)
#     - (if using ansible): set up codecommit to push ansible code to and pull from
#        - set up policy for the instance to be able to pull the code
#     - create the route53 entry to point to the ELB
#     - create key
#   2. use AWS cloudformation CLI to create the infrastructure using the json file

# II. create a Web Server via Ansible
#   - manually: create a user-data script (UDS)
#      - installs requirements to install Ansible
#      - installs ansible
#      - performs ansible pull from AWS CodeCommit to configure itself
#   - via ansible: create the launch config (LC) specifying the:
#      - UDS, and latest/greatest centos ami, Sg's, inst type, profile, and key
#   - via ansible: create a auto scaling group with instance numbers 1/5/1 (min/max/desired)
#      - designate the ELB to attach the instances to
#      - health check type of "ELB"
#      - create/specify the scaling policy/scaling event to scale up/down
#   - auto scaling creates instance(s)
#     and via ansible-pull (on the instance when it runs it's UDS): configure the web server
#      - creates/installs the web page dynamically in html with a template
#         - displays
#            "hello world" 
#            hostname: $HOSTNAME
#            created by: Ansible
#      - installs/configures/runs nginx

# III. create another Web Server via Chef
#   - Create a Chef server in AWS
#      - manually for now, but think of how to automate
#   - Set up knife file on local linux box (or on another instance in AWS)
#   - Create cookbooks/recipes and push up to the chef server
#   - manually: create a user-data script (UDS)
#      - installs requirements to install chef client
#      - installs chef client
#      - configures the knife file
#      - runs chef to configure itself
#   - manually via python: create the launch config (LC) with the UDS and latest/greatest centos ami
#   - manually via python: create a auto scaling group with instance numbers 1/5/1 (min/max/desired)
#      - designate the ELB to attach the instances to
#      - health check type of "ELB"
#      - create/specify the scaling policy/scaling event to scale up/down
#   - auto scaling creates instance(s)
#     and via chef (on the instance when it runs it's UDS): configures the web server
#      - creates/installs the web page dynamically in html with a template
#         - displays
#            "hello world" 
#            hostname: $HOSTNAME
#            created by: Chef
#      - installs/configures/runs nginx
