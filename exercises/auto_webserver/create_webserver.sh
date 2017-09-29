#!/bin/bash

# automates the creation of a webserver and the AWS infrastructure for it to run in

# I. create the infrastructure in AWS via AWS CLI and CloudFormation (CF)
#   1. create a json file for CF that does the following:
#     - create the Netorking: VPC, Subnet(s), GW'S, SG's
#     - create the ELB with health check (not sure if possible with CF)
#     - create lamda function to update the SG for the ELB (not sure if possible with CF)
#     - ansible: set up codecommit to push ansible code to and pull from
#        - set up policy for the instance to be able to pull the code
#     - create the route53 entry to point to the ELB
#   2. use AWS cloudformation CLI to create the infrastructure using the json file

# II. create a Web Server via Ansible
#   - use a pre-made user-data script (UDS) from a file
#      - installs requirements to install Ansible
#      - installs ansible
#      - performs ansible pull to configure itself
#   - create the launch config (LC) with the UDS and latest/greatest centos ami
#   - create a auto scaling group with instance numbers 1/5/1 (min/max/desired)
#   - designate the ELB to attach the instances to
#   - create auto scaling event to scale up/down
#   - 

# III. create the Web Server via Chef
#   - Create a Chef server
#   - Set up knife file
#   - Create cookbooks/recipes and push up to the chef server
#   - use a pre-made user-data script (UDS) from a file
#   - create the launch config (LC) with the UDS and latest/greatest centos ami
#   - create a auto scaling group with instance numbers 1/5/1 (min/max/desired)
#   - create auto scaling event to scale up/down
#   - Run chef
