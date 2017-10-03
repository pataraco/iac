# Exercise Description
Create a web server in AWS via automation

# Objective
Create infrastructure automation code that installs a web page onto a group of auto scaled servers that serve it up via a load balancer

# Requirements
I. Use an ELB to register the web server instances
 - Should include health check(s) to monitor the web servers and terminate them if they are unhealthy

II. Use Auto Scaling Group/Launch Configuration to launch the EC2 instances and connect them to the ELB
 - **Bonus**: Configure instance counts to enable scale up/down capability based on a metric of your choice

III. Does not allow direct access to the web servers (instances)
 - Use one Security Group allowing HTTP traffic to the ELB
 - And another Security Group allowing HTTP traffic from the ELB to the instance(s)

IV. Infrastructure Automation (Chef, Ansible) that achieves the following:
 - Installs a web server (e.g. Apache or Nginx)
 - Installs a simple “hello world” web page to be served up
 1. Written in any language (your choice: HTML, PHP, etc)
 2. Sourced from any location (your choice: S3, cookbook file/template, etc)
 3. **Bonus**: Include the server’s hostname on the web page presented
 - **Bonus**: Chef - Establish basic cookbook testing using Test Kitchen

V. Some method of running Chef on the instance
 - This could be Chef Server, Chef Solo, Chef Zero
  (May or may not be baked into the AMI - as long as Chef is performing all of the configuration)

# Success Criteria
A website displaying “hello world” served up by a Auto Scaled EC2 instances behind an ELB configured using Chef.

**Bonus**: Use automation (CloudFormation, Terraform, Stacker, etc) to create the AWS infrastructure

# Steps Performed to Create
1. Generate AWS keys and set up AWS environment
2. Create CloudFormation web server infrastructure template (files/raco_web_srvr_infra_cf_template.json) which:
   a. Creates all the infrastructure to run the web servers in
3. Create CloudFormation web servers template (files/raco_web_srvrs_cf_template.json) which:
   a. Creates the AWS Lauch Configuration and AutoScaling Group to create the web-servers
4. Create/run script (scripts/create_webserver_infra.sh) which:
   a. Creates AWS key pair and saves the private key
   b. Creates/Updates CloudFormation web server infra stack from the template
5. Set up Chef Workstation (install ChefDK, configure knife.rb, and 'install' pem files and SSL
6. Set up the Chef Server (org, admin user) and grab pem files
7. Upload Chef cookbooks and roles
8. Create/run script (scripts/create_webservers.sh) which:
   a. Creates/Updates CloudFormation web server stack from the template

# Testing Performed
- Ran all the scripts and verified that all the infrastructure and web servers got created
- Tested the web site by using the ELB's public DNS Name/URL
- Tested AWS AutoScaling
   - health checks: stopped nginx service on a web server and verified auto scaler replaced it
   - scaling out/in: increased loads on web servers (via `stress`) and verified
     autoscaler scaled up and down accordingly
- Tested destroy script to remove all
- Tested create script from scracth again after destroying

# To-Do
1. Add Chef config/creation steps in create_webserver.sh script that will automatically:
   a. Create the Chef Server organization and grab the validator.pem
   b. Create the Chef Server admin user and grab the user's pem file
   c. Create the knife.rb file and place the pem files in the .chef directory
   d. Run `knife ssh fetch`
2. Create a AWS Lambda function to automatically update the CIDR in the security group
   that the web servers use to only allow HTTP traffic from the ELB
   (currently it's set to '0.0.0.0/0')
3. Create a AWS Lambda function to automatically remove Chef nodes/clients from the 
   Chef Server once their state becomes 'terminated'

