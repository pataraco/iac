#!/bin/bash

# automates the creation of a webserver and the AWS infrastructure for it to run in

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

AWS_CMD=$(which aws)
JQ_CMD=$(which jq)
CREATOR_NAME="raco"
REPOS_DIR="$HOME/repos"
REPO_NAME="infrastructure-automation"
PROJECT="auto_webserver"
AWS_KEY_PAIR_NAME="$CREATOR_NAME"
AWS_CF_STACK_NAME="$CREATOR_NAME"
AWS_PRIVATE_KEY="$HOME/.ssh/${AWS_KEY_PAIR_NAME}.pem"
CF_STACK_TEMPLATE="file://$REPOS_DIR/$REPO_NAME/exercises/$PROJECT/files/${CREATOR_NAME}_cf_template.json"
CHEF_REPO="$REPOS_DIR/$REPO_NAME/exercises/$PROJECT/chef"
KNIFERB="$CHEF_REPO/.chef/knife.rb"

# sanity checks
[ -z "$AWS_CMD" ] && { echo "aws required to run this script"; exit 2; }
[ -z "$JQ_CMD" ] && { echo "jq required to run this script"; exit 2; }

# create a key pair via CLI (if it doesn't exist) to use for the instances
$AWS_CMD ec2 describe-key-pairs --key-name $AWS_KEY_PAIR_NAME &> /dev/null
if [ $? -ne 0 ]; then
   echo "public key doesn't exist in AWS, creating key pair: $AWS_KEY_PAIR_NAME"
   $AWS_CMD ec2 create-key-pair --key-name $AWS_KEY_PAIR_NAME | $JQ_CMD -r .KeyMaterial > $AWS_PRIVATE_KEY
elif [ ! -f $AWS_PRIVATE_KEY ]; then
   echo "the public key exists in AWS: $AWS_KEY_PAIR_NAME"
   echo "but you don't seem to have access to the private key: $AWS_PRIVATE_KEY"
else
   echo "the public key already exists in AWS: $AWS_KEY_PAIR_NAME"
fi

# create a SNS topic to get notifications
NOTIFICATION_ARN=$($AWS_CMD sns create-topic --name "all-${CREATOR_NAME}-notifications" | $JQ_CMD -r .TopicArn)

# I. create the infrastructure in AWS via AWS CLI and CloudFormation (CF)
#   1. create a json file for CF that does the following:
#     - create the Netorking: VPC, Subnet(s), GW'S, SG's
#     - create the ELB with health check (should be possible with CF)
#        - health check, SG's, etc...
#     - create lamda function to update the SG for the ELB (not sure if possible with CF)
#     - (if using ansible): set up codecommit to push ansible code to and pull from
#        - set up policy for the instance to be able to pull the code
#     - create a bastion host to jump to internal web server instances
#   2. use AWS cloudformation CLI to create the infrastructure using the json file

# check if the CF stack already exists, if so update it, otherwise create it
$AWS_CMD cloudformation describe-stacks --stack-name $AWS_CF_STACK_NAME &> /dev/null
if [ $? -eq 0 ]; then
   echo "CloudFormation stack exists, updating: $AWS_CF_STACK_NAME"
   #$AWS_CMD cloudformation update-stack --stack-name $AWS_CF_STACK_NAME --template-body $CF_STACK_TEMPLATE --notification-arns $NOTIFICATION_ARN
   $AWS_CMD cloudformation update-stack --stack-name $AWS_CF_STACK_NAME --capabilities CAPABILITY_NAMED_IAM --template-body $CF_STACK_TEMPLATE
else
   echo "CloudFormation stack does not exist, creating: $AWS_CF_STACK_NAME"
   $AWS_CMD cloudformation create-stack --stack-name $AWS_CF_STACK_NAME --capabilities CAPABILITY_NAMED_IAM --template-body $CF_STACK_TEMPLATE --disable-rollback --notification-arns $NOTIFICATION_ARN --tags Key=Name,Value=$AWS_CF_STACK_NAME 
fi

# II. Create Web Servers via Chef
#   - CloudFormation: Create a Chef server AWS instance (t2.medium)
#      - set up org and admin user - manually for now, but automate later
#   - Set up knife.rb file on local linux box (or on another instance in AWS)
#      - manually for now, but automate later
#   - Create cookbooks/roles and upload to the Chef Server
#   - CloudFormation:
#      - create a user-data script (UDS)
#      - installs requirements to install chef client
#      - installs chef client
#      - configures the client knife file and validator.pem
#      - runs chef to configure itself
#      - create the launch config (LC) with the UDS and latest/greatest Amazon Linux ami
#         - SG's, inst type (t2.small), instance profile, and key
#      - create an auto scaling group with instance numbers 2/6/2 (min/max/desired)
#         - designate the ELB to attach the instances to
#         - health check type of "ELB"
#         - create/specify the scaling policy/scaling event to scale up/down (CPU utilization)
#   - AWS Auto Scaling will create the instance(s)
#     and via chef (on the instance when it runs it's UDS): configures the web server
#      - creates/installs the web page dynamically in html with a template
#         - displays
#            "hello world" 
#            hostname: $HOSTNAME
#            created by: Chef
#      - installs/configures/runs nginx
#   - Test by going to the public ELB DNS records

# III. create a Web Server via Ansible
#   - manually: create a user-data script (UDS)
#      - installs requirements to install Ansible
#      - installs ansible
#      - performs ansible pull from AWS CodeCommit to configure itself
#   - via ansible: create the launch config (LC) specifying the:
#      - UDS, and latest/greatest centos ami, SG's, inst type (t2.micro), profile, and key
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
