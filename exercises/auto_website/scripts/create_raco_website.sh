#!/bin/bash
#
# automates the creation of a website and the AWS infrastructure for it to run in
#
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
KNIFE_CMD=$(which knife)
CREATOR_ID="raco"
CREATOR_NAME="Patrick Raco"
CREATOR_EMAIL="pataraco@gmail.com"
REPOS_DIR="$HOME/repos"
REPO_NAME="infrastructure-automation"
PROJECT="auto_website"
FILES_DIR="/$REPOS_DIR/$REPO_NAME/exercises/$PROJECT/files"
REGION="us-west-1"
AWS_ACCT_USERNAME="PATRICK"
AWS_PUBLIC_DOMAIN_NAME="compute.amazonaws.com"
AWS_KEY_PAIR_NAME="$CREATOR_ID"
AWS_EC2_IAM_ROLE="${CREATOR_ID}-ec2-restricted"
AWS_CF_STACK_NAME="$CREATOR_ID"
AWS_WEBSITE_INFRA_CF_STACK_NAME="${CREATOR_ID}-website-infra"
AWS_WEBSITE_CF_STACK_NAME="${CREATOR_ID}-website"
AWS_PRIVATE_KEY="$HOME/.ssh/${AWS_KEY_PAIR_NAME}.pem"
WEBSITE_INFRA_CF_STACK_JSON_NAME="website_infra_cloudformation.json"
WEBSITE_INFRA_CF_STACK_TEMPLATE="$FILES_DIR/${WEBSITE_INFRA_CF_STACK_JSON_NAME}.template"
WEBSITE_INFRA_CF_STACK_FILE="/tmp/$WEBSITE_INFRA_CF_STACK_JSON_NAME"
WEBSITE_CF_STACK_JSON_NAME="website_cloudformation.json"
WEBSITE_CF_STACK_TEMPLATE="$FILES_DIR/${WEBSITE_CF_STACK_JSON_NAME}.template"
WEBSITE_CF_STACK_FILE="/tmp/$WEBSITE_CF_STACK_JSON_NAME"
KMS_MASTER_KEY_POLICY_JSON_NAME="kms_master_key_policy.json"
KMS_MASTER_KEY_POLICY_TEMPLATE="$FILES_DIR/${KMS_MASTER_KEY_POLICY_JSON_NAME}.template"
KMS_MASTER_KEY_POLICY_FILE="/tmp/$KMS_MASTER_KEY_POLICY_JSON_NAME"
CHEF_REPO="$REPOS_DIR/$REPO_NAME/exercises/$PROJECT/chef"
KNIFERB_NAME="knife.rb"
KNIFERB_TEMPLATE="$FILES_DIR/${KNIFERB_NAME}.template"
KNIFERB_FILE="$CHEF_REPO/.chef/$KNIFERB_NAME"
CHEF_VALIDATOR_PEM_SRC="/tmp/${CREATOR_ID}-validator.pem"
CHEF_USER_PEM_SRC="/tmp/${CREATOR_ID}.chef.pem"
CHEF_VALIDATOR_PEM_DST="$CHEF_REPO/.chef/${CREATOR_ID}-validator.pem"
CHEF_USER_PEM_DST="$CHEF_REPO/.chef/${CREATOR_ID}.chef.pem"
DATA_KEY_JSON_TMP="/tmp/data_key.json"
DATA_KEY_NAME="data_key.enc"
DATA_KEY_ENCRYPTED="/tmp/$DATA_KEY_NAME"

# define functions

create_update_cf_stack() {
# create or update a CloudFormation (CF) stack and wait for it
# uses AWS CLI
# usage:
#    create_update_cf_stack STACK_NAME STACK_TEMPLATE
# 

   local _cf_stack_name="$1"
   local _cf_stack_template="$2"

   # make sure template exists
   [ ! -f "$_cf_stack_template" ] && { echo "CloudFormation template does not exist: $_cf_stack_template"; exit 2; }

   # check if the CF stack already exists, if so update it, otherwise create it
   $AWS_CMD cloudformation describe-stacks --stack-name $_cf_stack_name &> /dev/null
   if [ $? -eq 0 ]; then
      echo "CloudFormation stack exists - checking if update needed: $_cf_stack_name"
      $AWS_CMD cloudformation update-stack --stack-name $_cf_stack_name --capabilities CAPABILITY_NAMED_IAM --template-body file:/$_cf_stack_template &> /dev/null
      if [ $? -eq 0 ]; then
         echo "Update needed: updating CloudFormation stack: $_cf_stack_name"
         # wait for the stack update to complete
         echo "waiting for CloudFormation stack update to complete: $_cf_stack_name"
         $AWS_CMD cloudformation wait stack-update-complete --stack-name $_cf_stack_name
         [ $? -ne 0 ] && { echo "CloudFormation stack update did not complete: $_cf_stack_name"; exit 2; }
      else
         echo "Update NOT needed"
      fi
   else
      echo "CloudFormation stack does not exist - creating: $_cf_stack_name"
      $AWS_CMD cloudformation create-stack --stack-name $_cf_stack_name --capabilities CAPABILITY_NAMED_IAM --template-body file:/$_cf_stack_template --disable-rollback --notification-arns $NOTIFICATION_ARN --tags Key=Name,Value=$_cf_stack_name
      if [ $? -eq 0 ]; then
         # wait for the stack creation to complete
         echo "waiting for CloudFormation stack creation to complete: $_cf_stack_name"
         $AWS_CMD cloudformation wait stack-create-complete --stack-name $_cf_stack_name
         [ $? -ne 0 ] && { echo "CloudFormation stack creation did not complete: $_cf_stack_name"; exit 2; }
      fi
   fi
}

# sanity checks
# makes sure:
#    - required commands are available/installed
#    - AWS environment is set
echo "performing sanity checks"
[ -z "$AWS_CMD" ] && { echo "'aws' required to run this script"; exit 2; }
[ -z "$JQ_CMD" ] && { echo "'jq' required to run this script"; exit 2; }
[ -z "$KNIFE_CMD" ] && { echo "ChefDK (knife) required to run this script"; exit 2; }
if [ -z "$AWS_DEFAULT_PROFILE" ]; then
   [ -z "$AWS_ACCESS_KEY_ID" -a -z "$AWS_SECRET_ACCESS_KEY" -a -z "$AWS_DEFAULT_REGION" ] && { echo "AWS environment not set"; exit 2; }
fi

# create a key pair via CLI (if it doesn't exist) to use for the instances
echo "creating a public AWS key for EC2 instance access"
$AWS_CMD ec2 describe-key-pairs --key-name $AWS_KEY_PAIR_NAME &> /dev/null
if [ $? -ne 0 ]; then
   echo "  public key doesn't exist in AWS, creating key pair: $AWS_KEY_PAIR_NAME"
   $AWS_CMD ec2 create-key-pair --key-name $AWS_KEY_PAIR_NAME | $JQ_CMD -r .KeyMaterial > $AWS_PRIVATE_KEY
   echo "  private key saved to: $AWS_PRIVATE_KEY"
   chmod 600 $AWS_PRIVATE_KEY
elif [ ! -f $AWS_PRIVATE_KEY ]; then
   echo "  the public key exists in AWS: $AWS_KEY_PAIR_NAME"
   echo "  but you don't seem to have access to the private key: $AWS_PRIVATE_KEY"
else
   echo "  the public key already exists in AWS: $AWS_KEY_PAIR_NAME"
   echo "  private key located here: $AWS_PRIVATE_KEY"
   chmod 600 $AWS_PRIVATE_KEY
fi

# create a SNS topic to get notifications
echo "creating an AWS SNS topic for notifications"
NOTIFICATION_ARN=$($AWS_CMD sns create-topic --name "all-${CREATOR_ID}-notifications" | $JQ_CMD -r .TopicArn)

# I. Create the infrastructure in AWS via AWS CLI and CloudFormation (CF)
#   1. create a json file for CF that does the following:
#     - create the Netorking: VPC, Subnet(s), GW'S, SG's
#     - create the ELB with health check (should be possible with CF)
#        - health check, SG's, etc...
#     - create lamda function to update the SG for the ELB (not sure if possible with CF)
#     - (if using ansible): set up codecommit to push ansible code to and pull from
#        - set up policy for the instance to be able to pull the code
#     - create a bastion host to jump to internal web server instances
#     - create a Chef server AWS instance (t2.medium)
#   2. use AWS cloudformation CLI to create the infrastructure using the json file

# create website infrastructure CloudFormation stack template from another template ;-p
echo "configuring the website infrastructure CloudFormation stack template"
sed "s^__CREATOR_ID__^$CREATOR_ID^g;s^__CREATOR_EMAIL__^$CREATOR_EMAIL^g;s^__AWS_EC2_IAM_ROLE__^$AWS_EC2_IAM_ROLE^g" $WEBSITE_INFRA_CF_STACK_TEMPLATE > $WEBSITE_INFRA_CF_STACK_FILE

# create the website infrastructure using CloudFormation
echo "creating website infrastructure via CloudFormation"
create_update_cf_stack $AWS_WEBSITE_INFRA_CF_STACK_NAME $WEBSITE_INFRA_CF_STACK_FILE

# create a KMS master key
echo "creating an AWS KMS master key for data encryption"
# check if the key already exists
master_key_id=$($AWS_CMD kms list-aliases | jq -r '.Aliases[] | select(.AliasName=="'"alias/$CREATOR_ID"'").TargetKeyId')
if [ -n "$master_key_id" ]; then
   echo "  master key exists - checking state"
   # get key state to make sure it's not disabled or scheduled for deletion
   master_key_state=$($AWS_CMD kms describe-key --key-id $master_key_id | jq -r '.KeyMetadata.KeyState')
   case $master_key_state in
       Enabled)
          echo "  key is enabled" ;;
       PendingDeletion)
          echo "  key is pending deletion - canceling and enabling"
          $AWS_CMD kms cancel-key-deletion --key-id $master_key_id
          $AWS_CMD kms enable-key --key-id $master_key_id
          ;;
       Disabled)
          echo "  key is disabled - enabling"
          $AWS_CMD kms enable-key --key-id $master_key_id
          ;;
       *)
          echo "  key in unknown state - exiting"; exit 2 ;;
   esac
else
   echo "  master key does not exist - creating"
   # create the key
   master_key_id=$($AWS_CMD kms create-key --description "${CREATOR_ID}'s key to store secrets" | jq -r .KeyMetadata.KeyId)
   # alias it
   $AWS_CMD kms create-alias --alias-name "alias/$CREATOR_ID" --target-key-id $master_key_id
   # set the policy
   aws_acct_id=$($AWS_CMD kms describe-key --key-id $master_key_id | jq .KeyMetadata.Arn | cut -d':' -f5)
   sed "s^__AWS_ACCT_USERNAME__^$AWS_ACCT_USERNAME^g;s^__AWS_ACCT_ID__^$aws_acct_id^g;s^__CREATOR_ID__^$CREATOR_ID^g;s^__AWS_EC2_IAM_ROLE__^$AWS_EC2_IAM_ROLE^g" $KMS_MASTER_KEY_POLICY_TEMPLATE > $KMS_MASTER_KEY_POLICY_FILE
   $AWS_CMD kms put-key-policy --key-id $master_key_id --policy-name default --policy file://$KMS_MASTER_KEY_POLICY_FILE
fi

# II. Create Web Servers via Clouidformation and Chef
#   - Bash: Configure the Chef server
#      - set up org and admin user - manually for now, but automate later
#   - Set up knife.rb file on local linux box (or on another instance in AWS)
#      - manually for now, but automate later
#   - Create cookbooks/roles and upload to the Chef Server
#   - CloudFormation:
#      - create the launch config (LC) with the UDS and latest/greatest Amazon Linux ami
#         - SG's, inst type (t2.small), instance profile, and key
#         - with a user-data script (UDS) that:
#            - sets hostname and updates instance tags
#            - installs requirements to install chef client
#            - installs chef client
#            - configures the client knife file and validator.pem
#            - runs chef to configure itself
#      - create an auto scaling group with instance numbers 2/6/2 (min/max/desired)
#         - designate the ELB to attach the instances to
#         - health check type of "ELB"
#         - create/specify the scaling policy/scaling event to scale up/down (CPU utilization)
#   - AWS Auto Scaling will create the web server instance(s)
#     and via chef (on the instance when it runs it's UDS): configures the web server
#      - creates/installs the web page dynamically in html with a template
#         - displays
#            message: "Hello World!" 
#            hostname: $HOSTNAME
#            created by: Chef
#      - installs/configures/runs nginx
#   - Test by going to the public ELB DNS records

# get the Chef server public IP address
echo "getting the chef server public ip and forming it's URL"
chef_server_public_ip=$($AWS_CMD ec2 describe-instances --filters Name=tag:Name,Values=${CREATOR_ID}-chef-server Name=instance-state-name,Values=running | jq -r .Reservations[].Instances[].PublicIpAddress)
chef_server_url="https://ec2-${chef_server_public_ip//./-}.$REGION.$AWS_PUBLIC_DOMAIN_NAME/organizations/$CREATOR_ID"

# configure the chef server
echo "configuring the chef server"
ssh -i $AWS_PRIVATE_KEY ec2-user@$chef_server_public_ip "sudo chef-server-ctl user-create $CREATOR_ID $CREATOR_NAME $CREATOR_EMAIL DUMMY_PASSWORD --filename $CHEF_USER_PEM_SRC"
ssh -i $AWS_PRIVATE_KEY ec2-user@$chef_server_public_ip "sudo chef-server-ctl org-create $CREATOR_ID 'test org' --association_user $CREATOR_ID --filename $CHEF_VALIDATOR_PEM_SRC"
ssh -i $AWS_PRIVATE_KEY ec2-user@$chef_server_public_ip "sudo chef-server-ctl org-user-add $CREATOR_ID $CREATOR_ID --admin"

# configure knife file from a template
echo "configuring the knife.rb file"
sed "s^__CREATOR_ID__^$CREATOR_ID^g;s^__CHEF_SERVER_URL__^$chef_server_url^g" $KNIFERB_TEMPLATE > $KNIFERB_FILE

# get & install Chef client and validator pems and remove from Chef server
echo "installing/uploading pem files"
scp -i $AWS_PRIVATE_KEY ec2-user@$chef_server_public_ip:$CHEF_VALIDATOR_PEM_SRC $CHEF_VALIDATOR_PEM_DST
scp -i $AWS_PRIVATE_KEY ec2-user@$chef_server_public_ip:$CHEF_USER_PEM_SRC $CHEF_USER_PEM_DST
# encrypt the validator pem
echo "encrypting the Chef validator pem"
# get a data key from AWS KMS
$AWS_CMD kms generate-data-key --key-id $keyid --key-spec AES_256 > $DATA_KEY_JSON_TMP
data_key=$(jq -r .Plaintext $DATA_KEY_JSON_TMP)
jq -r .CiphertextBlob $DATA_KEY_JSON_TMP | base64 --decode > $DATA_KEY_ENCRYPTED
rm $DATA_KEY_JSON_TMP
openssl enc -e -in $CHEF_VALIDATOR_PEM_DST -out ${CHEF_VALIDATOR_PEM_DST}.enc -pass pass:$data_key -aes-256-cbc
# upload encrypted data key and validator pem to S3 bucket
echo "uploading encrypted files to AWS S3"
$AWS_CMD s3 mb s3://$CREATOR_ID
$AWS_CMD s3 cp $DATA_KEY_ENCRYPTED s3://$CREATOR_ID/chef/$DATA_KEY_NAME
$AWS_CMD s3 cp ${CHEF_VALIDATOR_PEM_DST}.enc s3://$CREATOR_ID/chef/validation.pem.enc
# remove pem files from the chef server
echo "removing pem files from the chef server"
ssh -i $AWS_PRIVATE_KEY ec2-user@$chef_server_public_ip "sudo rm -f $CHEF_USER_PEM_SRC; sudo rm -f $CHEF_VALIDATOR_PEM_SRC"

# install Chef SSL certs
echo "fetching Chef SSL cert"
$KNIFE_CMD ssl fetch -c $KNIFERB_FILE

# upload Chef roles/cookbooks to Chef server
echo "uploading roles and cookbooks"
$KNIFE_CMD role from file $CHEF_REPO/roles/web-server.rb -c $KNIFERB_FILE
$KNIFE_CMD cookbook upload hostname -c $KNIFERB_FILE
$KNIFE_CMD cookbook upload web-server -c $KNIFERB_FILE

# create website CloudFormation stack template from another template ;-p
echo "configuring the website CloudFormation stack template"
sed "s^__CREATOR_ID__^$CREATOR_ID^g;s^__CHEF_SERVER_PUBLIC_IP__^$chef_server_public_ip^g;s^__CHEF_SERVER_URL__^$chef_server_url^g" $WEBSITE_CF_STACK_TEMPLATE > $WEBSITE_CF_STACK_FILE

# create the website infrastructure using CloudFormation
echo "creating website servers via CloudFormation"
create_update_cf_stack $AWS_WEBSITE_CF_STACK_NAME $WEBSITE_CF_STACK_FILE

# TODO later
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

# output the website URL (ELB publice DNS entry)
echo "getting website URL"
website_url=$($AWS_CMD elb describe-load-balancers --load-balancer-name ${CREATOR_ID}-website | jq -r .LoadBalancerDescriptions[].DNSName)
echo "website creation complete: $website_url"
