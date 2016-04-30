#!/bin/bash -ex

EC2_USER=ec2-user
LOG=~${EC2_USER}/user-data.log
GIT_BRANCH=praco_tutorial
REALM=raco

function main() {
  export ANSIBLE_ROOT=~${EC2_USER}/cloud_automation/ansible

  # Get the instance data needed to setup this host
  ID=$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)
  REGION=$(wget -q -O - http://169.254.169.254/latest/meta-data/placement/availability-zone | sed -e "s/.$//")

  INSTANCE_TAGFILE=~${EC2_USER}/.instance_tags
  aws ec2 describe-tags --filters "Name=resource-id,Values=$ID" --region $REGION --output=text > $INSTANCE_TAGFILE
  NAME=$(grep -e "\WName\W" $INSTANCE_TAGFILE | cut -f5)
  ROLE=$(grep MachineRole $INSTANCE_TAGFILE | cut -f5)
  CLUSTER=$(grep Cluster $INSTANCE_TAGFILE | cut -f5)
  ENVIRONMENT=$(grep Env $INSTANCE_TAGFILE | cut -f5)
  GIT_BRANCH=$(grep BranchTag $INSTANCE_TAGFILE | cut -f5)
 

  # pull the automation from git on stor2
  git clone git://172.18.2.105/cloud_automation.git ~${EC2_USER}/cloud_automation
  export ANSIBLE_HOSTS=$ANSIBLE_ROOT/ansible_hosts
  echo "localhost" > $ANSIBLE_HOSTS
  pushd $ANSIBLE_ROOT

  #git checkout master
  git checkout $GIT_BRANCH

  # Call the appropriate playbook based on the tags given in the launch config
  # NOTE: not sure if I need the "--limit" option
  ansible-playbook playbooks/$REALM/setup_${ROLE}.yml -i ${NAME} --limit ${ENVIRONMENT}-${CLUSTER} -e host=${NAME},cluster=${CLUSTER},environ=${ENVIRONMENT}
}

main 2>&1 | tee $LOG

