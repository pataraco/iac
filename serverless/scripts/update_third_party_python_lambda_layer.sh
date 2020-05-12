#!/usr/bin/env bash
#
# CodeBuild project Buildspec to deploy serverless resources via Serverless Framework
#
# Description:
#   deploys/removes a list of serverless configs in a specific order
#
# Required parameters / environment variables
#   these values can either be supplied with command line options or as
#   environment variables (see usage for command line options)
#   (for CodeBuild implementations: define/set with the project config)
#
#  ARTIFACTS_LOCATION         = S3 bucket name/path for the artifacts upload
#  ARTIFACT_NAME              = Artifact to create
#  ENVIRONMENT                = Environment
#  LAMBDA_LAYER               = Lambda layer to update
#  LAMBDA_LAYER_ARN_SSM_PARAM = SSM parameter containing the Lambda layer's ARN
#
# Optional environment variables
#   these values will be provided via CodeBuild and Webhook triggers
#   if these vars are not set, the script will perform in the stated manner
#
#  CODEBUILD_BUILD_ID
#    used to uniquely name/save the artifact into AWS S3 and match with the
#    CodeBuild's project build run.

#    if this variable is set, The artifact location/name will be:
#      ARTIFACTS_LOCATION/CODEBUILD_BUILD_ID/ARTIFACT_NAME
#    otherwise it will be:
#      ARTIFACTS_LOCATION/latest/ARTIFACT_NAME

#  CODEBUILD_WEBHOOK_PREV_COMMIT
#    this environment is set if/when the CodeBuild project was triggered from
#    a repo webhook. It is used to determine the files that changed from the
#    last webhook trigger in order to verify the the required file changed.

#    if this variable is not, the script will not be able to determine if the
#    required file has changed and will not build the Lambda layer unless the
#    'force' options are used.

# globacl shellcheck disables
# shellcheck disable=SC2153,SC1117

# set the usage
THIS_SCRIPT=$(basename "$0")
SCRIPT_OPTS=$*
USAGE="\
$THIS_SCRIPT [OPTIONS]

required options:
   Artifact to create
      -an | --artifact-name ARTIFACT_NAME
   S3 bucket name/path for the artifacts upload
      -al | --artifact-location ARTIFACTS_LOCATION
   Environment to deploy in
      -e  | --environment ENVIRONMENT
   Lambda layer to update
      -ll | --lambda-layer LAMBDA_LAYER
   SSM parameter containing the Lambda layer's ARN
      -lp | --lambda-layer-arn-ssm-param LAMBDA_LAYER_ARN_SSM_PARAM

optional:
   dry-run - show, but do NOT run commands
      -d  | --dry-run
   force - force the update of the Lambda layer
      -f  | --force
   Show help/usage (this message)
      -h  | --help"

# this file has to change in order to create a new build (unless -f|--force)
REQUIRED_FILE_UPDATE="Pipfile.lock"
# get the original working directory
ORIG_WD=$(pwd)

# Slack deploy message variables
SLACK_COLOR_FAIL="danger"
SLACK_COLOR_PASS="good"
SLACK_PASS_EMOJIS=(
   :grinning: :grin: :joy: :smiley: :smile: :laughing: :yum: :sunglasses:
   :slightly_smiling_face: :stuck_out_tongue:)
SLACK_FAIL_EMOJIS=(
   :persevere: :open_mouth: :unamused: :white_frowning_face: :confounded:
   :disappointed: :triumph: :cry: :sob: :rage: :angry:
   :face_with_symbols_on_mouth:)
SLACK_EMOJI_FAIL=${SLACK_FAIL_EMOJIS[$((RANDOM % ${#SLACK_FAIL_EMOJIS[*]}))]}
SLACK_EMOJI_PASS=${SLACK_PASS_EMOJIS[$((RANDOM % ${#SLACK_PASS_EMOJIS[*]}))]}
SLACK_STATUS_FAIL="failed"
SLACK_STATUS_PASS="success"
SLACK_SSM_PARAM_WEBHOOK="/application/slack/webhooks/sls-deploys"
SLACK_WEBHOOK=$(aws ssm get-parameter --name $SLACK_SSM_PARAM_WEBHOOK --with-decryption --query Parameter.Value --output text)

# set variables to environment variables that might be set
# will be overwritten by command line options if given
# and finally verified to be set, otherwise exit
artifact_name=$ARTIFACT_NAME
artifacts_location=$ARTIFACTS_LOCATION
environment=$ENVIRONMENT
lambda_layer=$LAMBDA_LAYER
lambda_layer_arn_ssm_param=$LAMBDA_LAYER_ARN_SSM_PARAM

# set some defaults
build_dir=".build_lambda_layer_python_third_party"
reqs_file="requirements.txt"
force="false"

# make sure dry_run is not set
unset dry_run

# declare some functions
function print_usage {
   # show usage and exit
   echo
   echo "Usage: $USAGE"
   exit 2
}

function cleanup {
   # cleanup
   _msg="change working directory to original directory: $ORIG_WD"
   _cmd="cd $ORIG_WD"
   do_it "$_msg" "$_cmd"
   echo "current working directory: $(pwd)"
   _msg="remove build dir: $build_dir"
   _cmd="rm -rf $build_dir"
   do_it "$_msg" "$_cmd"
}

function fatal {
   # cleanup and exit with status 1
   _msg=$1
   echo "${dry_run}FAILED to $_msg"
   cleanup
   slack_it "${dry_run}FAILED to $_msg" fail
   exit 1
}

function show_force_options_and_exit {
   # check if user wants to force the build or not
   echo "use the '-f | --force' options to force the Lambda layer update"
   echo "Python third-party Lambda layer update - exiting"
   exit 0
}

function do_it {
   # display the messages and run the command (if not a dry-run)
   _msg=$1
   _cmd=$2
   echo "${dry_run}attempting to $_msg"
   if [ -n "$dry_run" ]; then
      echo "${dry_run}$_cmd"
   else
      if eval "$_cmd"; then
         echo "${dry_run}succeeded to $_msg"
      else
         fatal "$_msg"
      fi
   fi
}

function slack_it {
   # send Slack notification message
   _text=$1
   _status=$2
   _msg="send Slack notification"
   aws_acct="$(aws iam list-account-aliases --query AccountAliases --output text)"
   aws_region=${AWS_REGION:-${AWS_DEFAULT_REGION:-$(aws configure get region)}}
   aws_region=${aws_region:=unknown}
   aws_reg_host="https://${aws_region}.console.aws.amazon.com"
   aws_sss_host="https://s3.console.aws.amazon.com"
   aws_s3_object_path="$aws_sss_host/s3/object"
   s3_artifact_url="$aws_s3_object_path/${artifact_destination}?region=${aws_region}"
   s3_artifact_link="${dry_run}<$s3_artifact_url|$artifact_name>"
   lambda_layer_version=$(tr -d '"' <<< "${layer_version_arn##*:}")
   aws_lambda_layers_path="$aws_reg_host/lambda/home?region=${aws_region}#/layers"
   lambda_layer_url="$aws_lambda_layers_path/${lambda_layer}/versions/$lambda_layer_version"
   lambda_layer_link="${dry_run}<$lambda_layer_url|$lambda_layer ($lambda_layer_version)>"
   aws_ssm_path="$aws_reg_host/systems-manager/parameters"
   ssm_param_url="$aws_ssm_path/${lambda_layer_arn_ssm_param////%252F}/description?region=${aws_region}"
   ssm_param_link="${dry_run}<$ssm_param_url|$lambda_layer_arn_ssm_param>"
   echo "${dry_run}attempting to $_msg"
   if [ -n "$CODEBUILD_BUILD_URL" ]; then
      deploy_method="<$CODEBUILD_BUILD_URL|AWS CodeBuild>"
   else
      deploy_method="${dry_run}manual"
   fi
   if [ "$_status" == "pass" ]; then
      slack_color=$SLACK_COLOR_PASS
      slack_emoji=$SLACK_EMOJI_PASS
      slack_status=$SLACK_STATUS_PASS
      fields='
         {"title": "Script/Options:", "value": "'"$THIS_SCRIPT $SCRIPT_OPTS"'", "short": false},
         {"title": "AWS Account (Region):", "value": "'"$aws_acct ($aws_region)"'", "short": true},
         {"title": "Environment:", "value": "'"$environment"'", "short": true},
         {"title": "AWS S3 Artifact:", "value": "'"$s3_artifact_link"'", "short": false},
         {"title": "AWS Lambda Layer (Version):", "value": "'"$lambda_layer_link"'", "short": false},
         {"title": "AWS SSM Parameter:", "value": "'"$ssm_param_link"'", "short": false},
         {"title": "Method:", "value": "'"$deploy_method"'", "short": true},
         {"title": "Action (Status):", "value": "'"${dry_run}update ($slack_status) $slack_emoji"'", "short": true}'
   else
      slack_color=$SLACK_COLOR_FAIL
      slack_emoji=$SLACK_EMOJI_FAIL
      slack_status=$SLACK_STATUS_FAIL
      fields='
         {"title": "Script/Options:", "value": "'"$THIS_SCRIPT $SCRIPT_OPTS"'", "short": false},
         {"title": "AWS Account (Region):", "value": "'"$aws_acct ($aws_region)"'", "short": true},
         {"title": "Environment:", "value": "'"$environment"'", "short": true},
         {"title": "AWS Lambda Layer:", "value": "'"$lambda_layer"'", "short": false},
         {"title": "Method:", "value": "'"$deploy_method"'", "short": true},
         {"title": "Action (Status):", "value": "'"update ($slack_status) $slack_emoji"'", "short": true}'
   fi
   slack_body='{
       "text": "Backend Serverless Lambda Layer Python Third-Party Update",
       "attachments": [
           {
               "color": "'"$slack_color"'",
               "fallback": "'"_Lambda layer_: *${lambda_layer}* - $_text; $slack_status $slack_emoji"'",
               "text": "'"$_text"'",
               "fields": [ '"$fields"' ]
           }
       ]
   }'
   if
      curl -s \
         -X POST --data-urlencode "payload=$slack_body" \
         "$SLACK_WEBHOOK" > /dev/null
   then
      echo "${dry_run}succeeded to $_msg"
   else
      fatal "$_msg"
   fi
}

# parse the command line arguments
while [ $# -gt 0 ]; do
   case $1 in
      -al|--artifact-location) artifacts_location=$2; shift 2;;
      -an|--artifact-name) artifact_name=$2; shift 2;;
      -d|--dry-run) dry_run="dry-run: "; shift;;
      -e|--environment) environment=$2; shift 2;;
      -f|--force) force="true"; shift;;
      -ll|--lambda-layer) lambda_layer=$2; shift 2;;
      -lp|--lambda-layer-arn-ssm-param) lambda_layer_arn_ssm_param=$2; shift 2;;
      -h|--help|*) print_usage;;
   esac
done

echo "Python third-party Lambda layer update - beginning"

# if not forcing, check for the update of the required file
if [ "$force" == "false" ]; then
   echo "checking 'git' logs to make sure this file was updated: $REQUIRED_FILE_UPDATE"
   # if this is not a CobeBuild project build and not forced, exit
   if [ -n "$CODEBUILD_WEBHOOK_PREV_COMMIT" ]; then
      echo "this appears to be a CodeBuild project build triggered by a webhook"
      if [[ "$CODEBUILD_WEBHOOK_PREV_COMMIT" =~ "00000000000000000000" ]]; then
         changed_files=$(git show --pretty="" --name-only "$CODEBUILD_SOURCE_VERSION")
      else
         changed_files=$(git diff --name-only HEAD "$CODEBUILD_WEBHOOK_PREV_COMMIT")
      fi
   else
      # echo "this does not appear to be a CodeBuild project build"
      echo "this does not appear to be a CodeBuild project build triggered by a webhook"
      echo "can't determine changed files via 'git' logs"
      show_force_options_and_exit
   fi

   # if can't determine changed files and not forced, exit
   if [ -n "$changed_files" ]; then
      echo "these are the files that changed:"
      echo "$changed_files" | awk '{print "   - "$0}'
   else
      # echo "no files were changed in this last commit: $last_git_commit"
      echo "changed files unknown or no files were changed"
      show_force_options_and_exit
   fi

   # if the required wasn't updated and not forced, exit
   if [[ "$changed_files" =~ $REQUIRED_FILE_UPDATE ]]; then
      echo "this required file was updated: $REQUIRED_FILE_UPDATE"
   else
      echo "this required file was NOT updated: $REQUIRED_FILE_UPDATE"
      show_force_options_and_exit
   fi
else
   echo "forcing Lambda layer update"
fi

# sanity checks (check for required variable)
[ -z "$artifact_name" ] \
   && { echo "error: missing required variable: ARTIFACT_NAME"; print_usage; }
[ -z "$artifacts_location" ] \
   && { echo "error: missing required variable: ARTIFACTS_LOCATION"; print_usage; }
[ -z "$environment" ] \
   && { echo "error: missing required variable: ENVIRONMENT"; print_usage; }
[ -z "$lambda_layer" ] \
   && { echo "error: missing required variable: LAMBDA_LAYER"; print_usage; }
[ -z "$lambda_layer_arn_ssm_param" ] \
   && { echo "error: missing required variable: LAMBDA_LAYER_ARN_SSM_PARAM"; print_usage; }

# build the new layer in build directory
rm -rf $build_dir  # remove any pre-existing first
mkdir -p $build_dir/python
echo -e "created build directories:\n   $build_dir\n   $build_dir/python"

msg="create virtual Python environment"
cmd="pipenv sync --bare"
do_it "$msg" "$cmd"

msg="create current Python requirements file: $build_dir/$reqs_file"
cmd="pipenv run pip freeze > $build_dir/$reqs_file 2> /dev/null"
do_it "$msg" "$cmd"

msg="change working directory to build directory: $build_dir"
cmd="cd $build_dir"
do_it "$msg" "$cmd"
echo "current working directory: $(pwd)"

msg="build new Lambda layer (install third-party Python packages)"
cmd="pip install -q -r $reqs_file --target python"
do_it "$msg" "$cmd"

msg="create new artifact from installed packages: $artifact_name"
cmd="zip -q -r $artifact_name ."
do_it "$msg" "$cmd"

[ -n "$CODEBUILD_BUILD_ID" ] && build_id=${CODEBUILD_BUILD_ID#*:} || build_id="latest"
artifact_destination=$artifacts_location/$build_id/$artifact_name
msg="upload new artifact to AWS S3: $artifact_destination"
cmd="aws s3 cp --quiet $artifact_name s3://$artifact_destination"
do_it "$msg" "$cmd"

msg="update the Lambda layer: $lambda_layer"
cmd="aws lambda publish-layer-version --layer-name $lambda_layer\
 --description \"Third-party Python libraries for $environment\"\
 --content S3Bucket=${artifacts_location%%/*},S3Key=${artifacts_location#*/}/$build_id/$artifact_name\
 --query LayerVersionArn"
echo "${dry_run}attempting to $msg"
if [ -n "$dry_run" ]; then
   echo "${dry_run}$cmd"
   layer_version_arn="${dry_run}N/A"
else
   layer_version_arn=$(eval "$cmd")
fi
# shellcheck disable=SC2181
if [ $? -eq 0 ]; then
   echo "${dry_run}succeeded to $msg"
else
   fatal "$msg"
fi
echo "${dry_run}new Lambda layer ARN/Version: $layer_version_arn"

msg="update Lambda layer ARN SSM Parameter: $lambda_layer_arn_ssm_param to: $layer_version_arn"
cmd="aws ssm put-parameter --name $lambda_layer_arn_ssm_param\
 --value $layer_version_arn\
 --description \"$environment - Third-party Python Lambda layer ARN\"\
 --type String --overwrite"
do_it "$msg" "$cmd"

cleanup
echo "changed working directory back to original"
echo "current working directory: $(pwd)"

slack_it "${dry_run}Python third-party Lambda layer update - complete" pass

echo "Python third-party Lambda layer update - complete"
exit 0
