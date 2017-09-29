# Exercise Description
Create a web server in AWS via automation

# Objective
Create infrastructure automation code that installs a web page onto a group of auto scaled servers that serve it up via a load balancer

# Requirements
I. Use an ELB to register the web server instances
 - Should include health check(s) to monitor the web servers and terminate them if they are unhealthy

II. Use Auto Scaling Group/Launch Configuration to launch the EC2 instances and connect them to the ELB
 - **BONUS**: Configure instance counts to enable scale up/down capability based on a metric of your choice

III. Does not allow direct access to the web servers (instances)
 - Use one Security Group allowing HTTP traffic to the ELB
 - And another Security Group allowing HTTP traffic from the ELB to the instance(s)

IV. Infrastructure Automation (Chef, Ansible) that achieves the following:
 - Installs a web server (e.g. Apache or Nginx)
 - Installs a simple “hello world” web page to be served up
  - Written in any language (your choice: HTML, PHP, etc)
  - Sourced from any location (your choice: S3, cookbook file/template, etc)
  - **BONUS**: Include the server’s hostname on the web page presented
 - **Bonus**: Chef - Establish basic cookbook testing using Test Kitchen

V. Some method of running Chef on the instance
 - This could be Chef Server, Chef Solo, Chef Zero
  (May or may not be baked into the AMI - as long as Chef is performing all of the configuration)

# Success Criteria
A website displaying “hello world” served up by a Auto Scaled EC2 instances behind an ELB configured using Chef.

**Bonus**: Use automation (CloudFormation, Terraform, Stacker, etc) to create the AWS infrastructure
