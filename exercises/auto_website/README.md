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
2. Create CloudFormation website infrastructure template (files/raco_website_infra_cf_template.json) which:
   a. Creates all the infrastructure to run the website in
3. Create CloudFormation web servers template (files/raco_website_cf_template.json.template) which:
   a. Creates the AWS Lauch Configuration and AutoScaling Group to create the web-servers
      (this is a template to create the actual CF template after `sed` replaces Chef server info)
4. Create/run script (scripts/create_raco_website.sh) which:
   a. Creates AWS key pair and saves the private key
   b. Creates/Updates CloudFormation web server infra stack from the template
   c. Sets up Chef Workstation (install ChefDK, configure knife.rb, and 'install' pem files and SSL
   d. Set up the Chef Server (org, admin user) and grab pem files
   e. Upload Chef cookbooks and roles
   f. Creates the website CF template by update Chef Server info
   g. Creates/Updates CloudFormation website stack from the template using CloudFormation

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
1. Create a AWS Lambda function to automatically remove Chef nodes/clients from the
   Chef Server once their state becomes 'terminated'
2. Create a web servers via Ansible
   a. set up codecommit repo to push/pull ansible code
   b. use KMS for codecommit credentials

# Creation Example Run (output of 'create_website' script)
```
$ ./scripts/create_raco_website.sh
performing sanity checks
public key doesn't exist in AWS, creating key pair: raco
private key saved to: /home/praco/.ssh/raco.pem
configuring the website infrastructure CloudFormation stack template
creating website infrastructure via CloudFormation
CloudFormation stack does not exist - creating: raco-website-infra
{ "StackId": "arn:aws:cloudformation:us-west-1:783506417684:stack/raco-website-infra/b3b8b620-af79-11e7-9c52-500c5967ce56" }
waiting for CloudFormation stack creation to complete: raco-website-infra
getting the chef server public ip and forming it's URL
configuring the chef server
The authenticity of host '52.5.16.17 (52.5.16.17)' can't be established.
RSA key fingerprint is b:1:9:a:5:4:5:6:a:5:c:2:7:4:b:1.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '52.5.16.17' (RSA) to the list of known hosts.
User raco already associated with organization raco
User raco is added to admins and billing-admins group
configuring the knife.rb file
installing/uploading pem files
raco-validator.pem                                                      100% 1678     1.6KB/s   00:00
raco.chef.pem                                                           100% 1678     1.6KB/s   00:00
make_bucket: s3://raco/
upload: ../../../../../../../../home/praco/repos/infrastructure-automation/exercises/auto_website/chef/.chef/raco-validator.pem to s3://raco/chef/validation.pem
removing pem files from the chef server
fetching Chef SSL cert
WARNING: Certificates from ec2-52-5-16-17.us-west-1.compute.amazonaws.com will be fetched and placed in your trusted_cert
directory (/home/praco/repos/infrastructure-automation/exercises/auto_website/chef/.chef/trusted_certs).
Knife has no means to verify these are the correct certificates. You should
verify the authenticity of these certificates after downloading.
Adding certificate for ec2-52-5-16-17_us-west-1_compute_amazonaws_com in /home/praco/repos/infrastructure-automation/exercises/auto_website/chef/.chef/trusted_certs/ec2-52-5-16-17_us-west-1_compute_amazonaws_com.crt
uploading roles and cookbooks
Updated Role web-server
Uploading hostname     [0.0.2]
Uploaded 1 cookbook.
Uploading web-server     [0.0.1]
Uploaded 1 cookbook.
configuring the website CloudFormation stack template
creating website servers via CloudFormation
CloudFormation stack does not exist - creating: raco-website
{ "StackId": "arn:aws:cloudformation:us-west-1:783506417684:stack/raco-website/1118b6c0-af7b-11e7-b37a-500c21fb2c29" }
waiting for CloudFormation stack creation to complete: raco-website
getting website URL
website creation complete: raco-website-151649.us-west-1.elb.amazonaws.com
```


# Destruction Example Run (output of 'destroy_website' script)
```
$ ./scripts/destroy_raco_website.sh
performing sanity checks
URL of website you are about to delete: raco-website-35912.us-west-1.elb.amazonaws.com
Are you sure you want to delete this website ['yes' to confirm]? yes
disabling termination protection for instance: raco-bastion
disabling termination protection for instance: raco-chef-server
deleting website via CloudFormation
deleting CloudFormation stack: raco-website
waiting for CloudFormation stack delete to complete: raco-website
deleting website infrastructure via CloudFormation
deleting CloudFormation stack: raco-website-infra
waiting for CloudFormation stack delete to complete: raco-website-infra
deleting s3 bucket and files
delete: s3://raco/chef/data_key.enc
delete: s3://raco/chef/validation.pem.enc
remove_bucket: s3://raco/
deleting the SNS topic
deleting the key pair
scheduling the deletion of the KMS master key
{
    "KeyId": "arn:aws:kms:us-west-1:783506417684:key/6ae97dd8-879d-44e8-9143-1c462561c2d3",
    "DeletionDate": 1510617600.0
}
website destruction complete: raco-website-35912.us-west-1.elb.amazonaws.com
```
