#!/usr/bin/env bash

# Description
# -----------
#    Wrapper to use terraform to deploy infrastructure into any environment
#    (after initializing/reconfiguring the terraform S3 backend)

# Workflow/Step Overhead
# ----------------------
#    1. set $TF_VAR_deploy to blue|green (if applicable)
#    2. initialize terraform backend
#      Option A. set/use ENV variable for key value based on CLI options and/or ENV variable settings
#        # set $TF_VAR_tf_sf_s3_bk (terraform state files s3 bucket key)
#        # export TF_VAR_tf_sf_s3_bk=<env>/[<region>/]‌‌[<deploy>/]<state_file_name>.tfstate
#        export TF_VAR_tf_sf_s3_bk=$TF_VAR_env/[$TF_VAR_region/]‌‌[$TF_VAR_deploy/]‌‌$TF_VAR_app-$TF_VAR_region[-$TF_VAR_deploy]‌‌-$TF_VAR_service[-$TF_VAR_region].tfstate
#        terraform init -backend-config "key=$TF_VAR_tf_sf_s3_bk" -reconfigure
#      Option B. use a backend.tfvars file with "key" value assigned
#        (DOES require a separate backend-config tfvars file for each deploy with specific "key" settings)
#        terraform init -backend-config backend-<env>[-<color>]-<region>.tfvars -reconfigure
#      Option C. specify key value on CLI
#        (does NOT require a separate backend-config tfvars file for each deploy. "key" settings will be specified on CLI)
#        terraform init -backend-config "key=<env>/[<region>/]‌‌[<deploy>/]<state_file_name>.tfstate" -reconfigure
#    3. run terraform apply -var-file=<env>-<region>.tfvars

# Global Settings/Variables
# set -x   # enable "debug" mode
set -e     # exit immediately if a simplet command exits with a non-zero status
exec 3>&1  # create a link to STDOUT for terraform to output to
exec 1>&2  # send STDOUT to STDERR


readonly THIS_SCRIPT=$(basename $0)
readonly DEFAULT_REGION="global"
readonly PROD_ENVS="foo pie prod"   # Environments that require DEPLOY value

# Usage
readonly USAGE="\
usage: $THIS_SCRIPT [options]
options:
  -e|--env ENV                   Environment to deploy [required]
                                 (e.g. qa, pie, prod)
  -d|--deploy DEPLOY             Deployment to launch [conditional]
                                 (e.g. b|blue, g|green; required for specific environments)
  -r|--region REGION             AWS region to deploy to [optional]
                                 (e.g. us-west-2, us-east-1, etc.; default: $DEFAULT_REGION)
  -m|--module MODULE             Module to deploy to [required]
                                 (e.g. aws-iam-roles, cryt-tier, etc.)
  -v|--vars VARS_SETTINGS_FILE   File containing variable settings [optional]
                                 (e.g. qa-us-east-1.tfvars; default: ENV-REGION.tfvars)
  -b|--backend BACKEND_CFG_FILE  File containing backend configuration settings [optional]
                                 (e.g. backend-qa-us-east-1.tfvars; default: backend-ENV-REGION.tfvars)
  -h|--help                      Show usage/help (this message)"

# parse command line arguments
while [ $# -gt 0 ]; do
   case $1 in
      -e|--env)     ENV="$2"         ; shift 2;;
      -d|--deploy)  DEPLOY="$2"      ; shift 2;;
      -m|--module)  MODULE="$2"      ; shift 2;;
      -r|--region)  REGION="$2"      ; shift 2;;
      -v|--vars)    VARS_FILE="$2"   ; shift 2;;
      -b|--backend) BACKEND_CFG="$2" ; shift 2;;
      -h|--help)    echo "$USAGE"    ; return;;
      *)            TF_CMD="$@" ; break;;
   esac
done

# sanity checks
REGION=${REGION:=$DEFAULT_REGION}
[ -z "$ENV" ] && { echo "error: missing required environment option"; echo "$USAGE"; exit; }
[ -z "$MODULE" ] && { echo "error: missing required module option"; echo "$USAGE"; exit; }
[ ! -d "$MODULE" ] && { echo "error: module NOT found: $MODULE"; echo "$USAGE"; exit; }
[[ $PROD_ENVS =~ (^| )$ENV($| ) && -z "$DEPLOY" ]] && { echo "error: deploy option required for environment: $ENV"; echo "$USAGE"; exit; }
# [ -z "$VARS_FILE" ] && VARS_FILE="$ENV-$REGION.tfvars"
[ -z "$VARS_FILE" ] && VARS_FILE="$ENV.tfvars"
VARS_FILE="$MODULE/$VARS_FILE"
[ ! -e "$VARS_FILE" ] && { echo "error: tfvars file NOT found: $VARS_FILE"; echo "$USAGE"; exit; }
# [ -z "$BACKEND_CFG" ] && BACKEND_CFG="$ENV-$REGION.tfvars"
[ -z "$BACKEND_CFG" ] && BACKEND_CFG="$ENV-backend.tfvars"
BACKEND_CFG="$MODULE/$BACKEND_CFG"
[ ! -e "$BACKEND_CFG" ] && { echo "error: backend tfvars file NOT found: $BACKEND_CFG"; echo "$USAGE"; exit; }

# configure environment variables
declare -rx TF_VAR_region=$REGION
declare -rx TF_VAR_deploy=${DEPLOY::1}
readonly PROJECT_SETTING=$(sed -n 's/^project = /TF_VAR_project=/;/^TF_VAR_/s/"//pg' $VARS_FILE)
[ -z "$PROJECT_SETTING" ] && { echo "error: project value not in: $VARS_FILE"; exit; } || declare -x $PROJECT_SETTING
TF_VAR_project=$(echo "$TF_VAR_project" | tr '[A-Z]' '[a-z]')

echo "debug"
echo "
   Environment: $ENV
   Deploy:      $DEPLOY
   Region:      $REGION
   Module:      $MODULE
   Project:     $TF_VAR_project
   TFvars file: $VARS_FILE
   Backend cfg: $BACKEND_CFG
   TF Command:  $TF_CMD
"

# grab variable settings and set environment variables for use by subsequent commands
# declare -rx $(sed -n 's/^\([a-zA-Z]*\) = /TF_VAR_\1=/;/^#/! s/"//pg' $VARS_FILE)

# initiatialize backend
# Backend AWS S3 Bucket Key naming format:
#   <env>/<region>/[<deploy>/]<state_file_name>.tfstate
# where:
#  <state_file_name> = <project>-<env>-<service>-[<color>-][<region>]
#  <region>          = AWS region (e.g. us-east-1, us-west-2, etc. or global)
#  <deploy>          = blue|green|shared
#  <color>           = b|g
# e.g. "ssp/us-west-2/shared/bos-ssp-tf-init-us-west-2.tfstate"

STATE_FILE_NAME="$TF_VAR_project-$ENV-$MODULE-${DEPLOY::1}${DEPLOY:+-}$REGION.tfstate"
S3_KEY="$ENV/$REGION/$DEPLOY${DEPLOY:+/}$STATE_FILE_NAME"
echo "running: terraform init -reconfigure 
   -backend-config $BACKEND_CFG
   -backend-config key=$S3_KEY
   $MODULE"
terraform init -reconfigure \
   -backend-config $BACKEND_CFG \
   -backend-config key=$S3_KEY \
   $MODULE

# run terraform command
if [ -n "$TF_CMD" ]; then
   echo "running: terraform $TF_CMD -var-file $VARS_FILE $MODULE"
   terraform $TF_CMD -var-file $VARS_FILE $MODULE >&3
fi
