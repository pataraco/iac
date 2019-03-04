#!/usr/bin/env bash

# Description
# -----------
#    Wrapper to use terraform to deploy infrastructure into any environment
#    (after initializing/reconfiguring the terraform S3 backend)

# Workflow/Step Overhead
# ----------------------
#    1. set $TF_VAR_deploy to blue|green (if applicable)
#    2. initialize terraform backend
#       a. dynamically generate the AWS S3 bucket key value from command line
#          options given and project setting in *.tfvars file
#       b. determine which backend config file to use depending on whether or
#          not the environment to deploy is prod or non-prod
#       c. invoke `terraform init` with '-backend-config' options to specify
#          both the appropiate backend conig file and S3 key setting
#    3. run terraform COMMAND (if applicable - i.e. a user specified command) 

# Global Settings/Variables
# set -x   # enable "debug" mode
set -e     # exit immediately if a simple command exits with a non-zero status
exec 3>&1  # create a link to STDOUT for terraform to output to
exec 1>&2  # send STDOUT to STDERR

readonly BACKEND_SSP="ssp-backend.tfvars"    # backend config for prod
readonly BACKEND_SSNP="ssnp-backend.tfvars"  # backend config for non prod
readonly DEFAULT_REGION="global"             # default to global resources
readonly DEV_ENV="dev"                       # Valid development environment
readonly NON_PROD_ENVS="bar qa dev"          # Envs that don't allow DEPLOY val
readonly PROD_ENVS="foo pie prod"            # Envs that require DEPLOY value
readonly THIS_SCRIPT=$(basename $0)          # name of the script invoked
readonly VALID_DEPLOYS="blue green shared"   # Valid options for DEPLOY value

# Usage
readonly USAGE="\
usage: $THIS_SCRIPT [options]
required options:
  -e | --env ENV                  Environment to deploy
                                  (non-prod: $PROD_ENVS)
                                  (prod: $NON_PROD_ENVS)
  -m | --module MODULE            Module (service) to deploy
                                  (e.g. aws-iam-roles, cryt-tier, etc.)
conditional options:
  -d | --deploy DEPLOY            Deployment to launch ($VALID_DEPLOYS)
                                  (required for environments: $PROD_ENVS)
  -v | --vars VARS_SETTINGS_FILE  Variable settings file to use
                                  only available for $DEV_ENV environment
                                  (default: MODULE/ENV.tfvars)
optional options:
  -r | --region REGION            AWS region to deploy (default: $DEFAULT_REGION)
                                  (e.g. us-west-2, us-east-1, etc.)
  -h | --help                     Show usage/help (this message)"

# parse command line arguments
while [ $# -gt 0 ]; do
   case $1 in
      -d|--deploy) DEPLOY="$2"    ; shift 2;;
      -e|--env)    ENV="$2"       ; shift 2;;
      -h|--help)   echo "$USAGE"  ; exit   ;;
      -m|--module) MODULE="$2"    ; shift 2;;
      -r|--region) REGION="$2"    ; shift 2;;
      -v|--vars)   VARS_FILE="$2" ; shift 2;;
      *)           TF_CMD="$@"    ; break  ;;
   esac
done

# set default variable settings
REGION=${REGION:=$DEFAULT_REGION}
[[ $PROD_ENVS =~ (^| )$ENV($| ) ]] && BACKEND_CFG="$MODULE/$BACKEND_SSP"
[[ $NON_PROD_ENVS =~ (^| )$ENV($| ) ]] && BACKEND_CFG="$MODULE/$BACKEND_SSNP"

# get project from VARS_FILE
readonly PROJECT=$(
   grep '^project = ' $VARS_FILE | cut -d'"' -f2 | tr '[A-Z]' '[a-z]')
[ -z "$PROJECT" ] && {
   echo "error: project not defined in: $VARS_FILE"; exit; }

# sanity checks
[ -z "$ENV" ] && {
   echo "error: missing required ENV option"; echo "$USAGE"; exit; }
[ -z "$MODULE" ] && {
   echo "error: missing required MODULE option"; echo "$USAGE"; exit; }
[ ! -d "$MODULE" ] && {
   echo "error: module NOT found: $MODULE"; echo "$USAGE"; exit; }
[[ ! $PROD_ENVS =~ (^| )$ENV($| ) && ! $NON_PROD_ENVS =~ (^| )$ENV($| ) ]] && {
   echo "error: invalid environment: $ENV"; echo "$USAGE"; exit; }
[[ $PROD_ENVS =~ (^| )$ENV($| ) && -z "$DEPLOY" ]] && {
   echo "error: DEPLOY required for environment: $ENV"; echo "$USAGE"; exit; }
[[ ! $PROD_ENVS =~ (^| )$ENV($| ) && -n "$DEPLOY" ]] && {
   echo "error: deploy option not applicable for environment: $ENV"
   echo "$USAGE"; exit; }
[[ -n "$DEPLOY" && ! $VALID_DEPLOYS =~ (^| )$DEPLOY($| ) ]] && {
   echo "error: invalid deploy option: $DEPLOY"; echo "$USAGE"; exit; }
if [ -n "$VARS_FILE" -a $ENV != "$DEV_ENV" ]; then
   echo "error: VARS_SETTINGS_FILE option only avail with environment: $DEV_ENV"
   echo "$USAGE"
   exit
else
   VARS_FILE="$MODULE/$ENV.tfvars"
fi
[ ! -e "$VARS_FILE" ] && {
   echo "error: tfvars file NOT found: $VARS_FILE"; echo "$USAGE"; exit; }
[ -z "$BACKEND_CFG" ] && {
   echo "error: backend config NOT set"; exit; }
[ ! -e "$BACKEND_CFG" ] && {
   echo "error: backend config NOT found: $BACKEND_CFG"; echo "$USAGE"; exit; }

# configure environment variables for use by module
declare -rx TF_VAR_region=$REGION
declare -rx TF_VAR_deploy=${DEPLOY::1}

# for debugging purposes:
# TODO: remove all this
echo "
debug:
   Environment (ENV):         $ENV
   Deploy (DEPLOY):           $DEPLOY
   Region (REGION):           $REGION
   Module (MMODULE):          $MODULE
   Project (TF_VAR_project):  $TF_VAR_project
   Project (PROJECT):         $PROJECT
   TFvars file (VARS_FILE):   $VARS_FILE
   Backend cfg (BACKEND)CFG): $BACKEND_CFG
   TF Command (TF_CMD):       $TF_CMD
"

# initiatialize backend

# Backend AWS S3 Bucket Key naming format:
#   <env>/<region>/[<deploy>/]<state_file_name>.tfstate
# where:
#  <state_file_name> = <project>-<env>-<service>-[<color>-][<region>]
#  <region>          = AWS region (e.g. us-east-1, us-west-2, etc. or global)
#  <deploy>          = blue|green|shared
#  <color>           = b|g
# e.g. "ssp/us-west-2/shared/bos-ssp-tf-init-us-west-2.tfstate"

STATE_FILE_NAME="$PROJECT-$ENV-$MODULE-${DEPLOY::1}${DEPLOY:+-}$REGION.tfstate"
S3_KEY="$ENV/$REGION/$DEPLOY${DEPLOY:+/}$STATE_FILE_NAME"
echo "running: terraform init -reconfigure 
   -backend-config $BACKEND_CFG
   -backend-config key=$S3_KEY
   $MODULE"
terraform init -reconfigure \
   -backend-config $BACKEND_CFG \
   -backend-config key=$S3_KEY \
   $MODULE

# run terraform command (if applicaable)
if [ -n "$TF_CMD" ]; then
   echo "running: terraform $TF_CMD -var-file $VARS_FILE $MODULE"
   terraform $TF_CMD -var-file $VARS_FILE $MODULE >&3
fi
