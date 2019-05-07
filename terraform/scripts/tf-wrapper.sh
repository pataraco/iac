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

# Terminology: AWS resources and Terraform configs
# ------------------------------------------------
#    common: (EC2 security groups and Terraform variables) [file names]
#       used by all resources (EC2 and TF configs)
#
#    shared: (AWS resources) [deploy setting]
#       resources used by few/specific resources (DB's, ES, RabbitMQ, KMS,
#       SG's, Etc.) (only specified/significant when deploying to `pie` and
#       `prod`, and you'll only see that "shared" designation when deployed to
#       `pie` and `prod` in the names of the TF state files and the names of
#       the AWS resources)
#
#    global: (region)        [region setting]
#       refers to whether or not the AWS resource is region specific
#       (IAM|R53|WAF|CloudFront - no, EC2|S3|VPC|etc. - yes)

# Debug/Investigation/Maintenance Mode
# ------------------------------------
#    If a Terraform command (e.g. plan or apply) is not given, this script will
#    initialize the appropiate S3 backend configuration (S3 bucket & key) and
#    then change the working directory to the module desired to maintain, then
#    start a shell to allow the user to perform Terraform debugging,
#    investigation and maintenance commands (e.g. show and import).
#    The user will see a prompt showing the:
#       1. S3 backend configuration state file details (S3 bucket/key)
#       2. current working directory (highlight the fact that they are now
#          in the directory of the module to be worked on
#       3. "TF DEBUG" prompt
#    At this point one can run, e.g.:
#       - terraform show    # read and output the Terraform state file
#       - terraform import  # import existing infrastructure into the state file
#    To exit this mode, simply type 'exit' and hit [return]

# Global Settings/Variables
# set -x   # enable "debug" mode
set -e     # exit immediately if a simple command exits with a non-zero status
exec 3>&1  # create a link to STDOUT for terraform to output to
exec 1>&2  # send STDOUT to STDERR

readonly BACKEND_SSPD="sspd-backend.tfvars"   # backend config for prod
readonly BACKEND_SSNP="ssnp-backend.tfvars"   # backend config for non prod
readonly COMMON_DIR="common"                  # common directory of shared files
readonly DEFAULT_RESOURCE_REGION="us-west-2"  # default region for global deploy
readonly DEV_ENV="dev"                        # Valid development environment
readonly DEPLOY_ENVS="stag prod"              # Envs that require DEPLOY val
readonly NON_PROD_ENVS="qa dev stag ssnp"     # Non "prod" environments
readonly PROD_ENVS="prod sspd"                # "prod" environments
readonly THIS_SCRIPT=$(basename $0)           # name of the script invoked
readonly VALID_DEPLOYS="blue green shared"    # Valid options for DEPLOY value

# Usage
readonly USAGE="\
usage: $THIS_SCRIPT [options]
required options:
  -e | --env ENV                  Environment to deploy
                                  (non-prod: $NON_PROD_ENVS)
                                  (prod: $PROD_ENVS)
  -m | --module MODULE            Module (service) to deploy
                                  (e.g. aws-iam-roles, cryt-tier, etc.)
  -r | --region REGION            AWS region to deploy
                                  (e.g. global, us-west-2, us-east-1, etc.)
conditional options:
  -d | --deploy DEPLOY            Deployment to launch ($VALID_DEPLOYS)
                                  (required for environments: $DEPLOY_ENVS)
  -v | --vars VARS_SETTINGS_FILE  Variable settings file to use
                                  only available for $DEV_ENV environment
                                  (default: MODULE/ENV.tfvars)
optional options:
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
      -*)          echo "error: unknown option: $1"; echo "$USAGE"; exit 1;;
      *)           TF_CMD="$@"    ; break  ;;
   esac
done

# set default variable settings
[[ $PROD_ENVS =~ (^| )$ENV($| ) ]] && BACKEND_CFG="$COMMON_DIR/$BACKEND_SSPD"
[[ $NON_PROD_ENVS =~ (^| )$ENV($| ) ]] && BACKEND_CFG="$COMMON_DIR/$BACKEND_SSNP"

# sanity checks
[ -z "$ENV" ] && {
   echo "error: missing required ENV option"; echo "$USAGE"; exit 1; }
[ -z "$MODULE" ] && {
   echo "error: missing required MODULE option"; echo "$USAGE"; exit 1; }
[ -z "$REGION" ] && {
   echo "error: missing required REGION option"; echo "$USAGE"; exit 1; }
[ ! -d "$MODULE" ] && {
   echo "error: module NOT found: $MODULE"; echo "$USAGE"; exit 1; }
[[ ! $PROD_ENVS =~ (^| )$ENV($| ) && ! $NON_PROD_ENVS =~ (^| )$ENV($| ) ]] && {
   echo "error: invalid environment: $ENV"; echo "$USAGE"; exit 1; }
[[ $DEPLOY_ENVS =~ (^| )$ENV($| ) && -z "$DEPLOY" ]] && {
   echo "error: DEPLOY required for environment: $ENV"; echo "$USAGE"; exit 1; }
[[ ! $DEPLOY_ENVS =~ (^| )$ENV($| ) && -n "$DEPLOY" ]] && {
   echo "error: DEPLOY option not applicable for environment: $ENV"
   echo "$USAGE"; exit 1; }
[[ -n "$DEPLOY" && ! $VALID_DEPLOYS =~ (^| )$DEPLOY($| ) ]] && 
   echo "error: invalid DEPLOY option: $DEPLOY" && echo "$USAGE" && exit 1
if [ -n "$VARS_FILE" -a $ENV != "$DEV_ENV" ]; then
   echo "error: VARS_SETTINGS_FILE option only avail with environment: $DEV_ENV"
   echo "$USAGE"
   exit 1
else
   VARS_FILE="$MODULE/$ENV.tfvars"
fi
[ ! -e "$VARS_FILE" ] && {
   echo "error: tfvars file NOT found: $VARS_FILE"; echo "$USAGE"; exit 1; }
[ -z "$BACKEND_CFG" ] && {
   echo "error: backend config NOT set"; exit 1; }
[ ! -e "$BACKEND_CFG" ] && {
   echo "error: backend config NOT found: $BACKEND_CFG"; echo "$USAGE"; exit 1; }

# get project from VARS_FILE
readonly PROJECT=$(
   grep '^project = ' $VARS_FILE | cut -d'"' -f2 | tr '[A-Z]' '[a-z]')
[ -z "$PROJECT" ] && {
   echo "error: project not defined in: $VARS_FILE"; exit 1; }

# see if this has a statically assigned deployment (not blue or green)
readonly STATIC_DEPLOY=$(
   grep '^deploy = ' $VARS_FILE | cut -d'"' -f2 | tr '[A-Z]' '[a-z]')
[[ -n $STATIC_DEPLOY ]] && [[ ! $DEPLOY == $STATIC_DEPLOY ]] && {
   echo "error: this stack defines a static deployment of \"$STATIC_DEPLOY\"
   which does not match your argument of \"$DEPLOY\""; exit 1; }

readonly STATIC_REGION=$(
   grep '^region = ' $VARS_FILE | cut -d'"' -f2 | tr '[A-Z]' '[a-z]')
[[ -n $STATIC_REGION ]] && [[ ! $REGION == $STATIC_REGION ]] && {
   echo "error: this stack defines a static region of \"$STATIC_REGION\"
   which does not match your argument of \"$REGION\""; exit 1; }

# configure environment variables for use by module
if [ "$REGION" == "global" ]; then
   declare -rx TF_VAR_region=$DEFAULT_RESOURCE_REGION
else
   declare -rx TF_VAR_region=$REGION
fi
declare -rx TF_VAR_app=$PROJECT
declare -rx TF_VAR_deploy=${DEPLOY::1}
declare -rx TF_VAR_colorstack=${DEPLOY}
declare -rx TF_VAR_env=$ENV
declare -rx TF_VAR_environment=$(echo $ENV | tr '[a-z]' '[A-Z]')

# # for debugging purposes:
# # TODO: remove all this
# echo "
# debug:
#    Environment (ENV):         $ENV
#    Deploy (DEPLOY):           $DEPLOY
#    Colorstack (COLORSTACK):   $DEPLOY
#    Region (REGION):           $REGION
#    Module (MODULE):           $MODULE
#    Project (PROJECT):         $PROJECT
#    TFvars file (VARS_FILE):   $VARS_FILE
#    Backend cfg (BACKEND_CFG): $BACKEND_CFG
#    TF Command (TF_CMD):       $TF_CMD
# "

# initiatialize backend
# Backend AWS S3 Bucket Key naming format:
#   <env>/<region>/[<deploy>/]<state_file_name>.tfstate
# where:
#  <state_file_name> = <project>-<env>-<service>-[<color>-][<region>]
#  <region>          = AWS region (e.g. us-east-1, us-west-2, etc. or global)
#  <deploy>          = blue|green|shared
#  <color>           = b|g
# e.g. "sspd/us-west-2/shared/proj-sspd-tf-init-us-west-2.tfstate"
if [ "$REGION" == "global" ]; then
   STATE_FILE_NAME="$PROJECT-$ENV-${MODULE##*/}-$REGION.tfstate"
   S3_KEY="$ENV/$REGION/$STATE_FILE_NAME"
else
   STATE_FILE_NAME="$PROJECT-$ENV-${MODULE##*/}-${DEPLOY::1}${DEPLOY:+-}$REGION.tfstate"
   S3_KEY="$ENV/$REGION/$DEPLOY${DEPLOY:+/}$STATE_FILE_NAME"
fi
echo
echo "running: terraform init -reconfigure
   -backend-config $BACKEND_CFG
   -backend-config key=$S3_KEY
   $MODULE"
terraform init -reconfigure \
   -backend-config $BACKEND_CFG \
   -backend-config key=$S3_KEY \
   $MODULE

# validate terraform configuration
echo
echo "running: terraform validate -var-file $VARS_FILE $MODULE"
terraform validate -var-file $VARS_FILE $MODULE >&3
[ $? -ne 0 ] && { echo "error: terraform validation failed"; exit; }

# run terraform command (if applicable)
if [ -n "$TF_CMD" ]; then
   echo
   echo "running: terraform $TF_CMD -var-file $VARS_FILE $MODULE"
   terraform $TF_CMD -var-file $VARS_FILE $MODULE >&3
else
   s3_bucket=$(grep "bucket *= " $BACKEND_CFG | cut -d'"' -f2)
   echo
   echo "opening new shell for testing (type 'exit' or ^D to quit)"
   echo "(for verbose output; export TF_LOG=TRACE)"
   echo "(for debug output; export TF_LOG=DEBUG)"
   unset PROMPT_COMMAND
   PGRN='\[\e[1;32m\]'  # green (bold)
   PBLU='\[\e[1;34m\]'  # blue (bold)
   PCYN='\[\e[1;36m\]'  # cyan (bold)
   PNRM='\[\e[m\]'      # normal
   EXECED_WD=$(pwd)     # dir where the wrapper was execed from
   cd $MODULE           # cd to the "module" desired to be launched
   [ -e .terraform ] && mv .terraform{,.orig.$$}  # save current .terraform dir
   ln -s $EXECED_WD/.terraform  # set up symlink to backend initialized
   export PS1="\n${PCYN}(state file: s3://$s3_bucket/$S3_KEY)\n${PGRN}[path: \w]\n${PBLU}{TF DEBUG ('exit' to quit)}$ ${PNRM}"
   bash --noprofile --norc
   rm -f .terraform     # remove the symlink
   [ -e .terraform.orig.$$ ] && mv .terraform{.orig.$$,}  # restore original .terraform directory
   cd $EXECED_WD        # cd back to the original working directory
fi
