# ANSIBLE Tutorial Project
------------------------


## Requirements:

* Must be fully automated via Ansible, including
	- Entire infrastructure build out
	- All system bootstraps and configurations
	- Complete application configurations
* Ansible
	- Create one or more playbooks as needed
	- Create a new role named YOUR-INITIALS_sample_project
	- Leverage ansible-pull
* Infrastructure
	- ELB listening port 80
	- Correctly defined security groups
	- Correctly tagging all resources with necessary tags per AWS Tagging Requirements.
	- Deployed in the Mordor VPC
	- Utilize internal (private) and external (public) subnets
	- Two (2) Instances need to be deployed into different availability zones
* Software Requirements on the instance:
	- Web server listening on port 80
	- Deploy a dummy website ( static index.html )
	- URL for testing SHALL be:
		http://YOUR-INITIALS_sample-proj.nimaws.com
* Extra credit:
	- Ansible playbook(s) to cleanly take down any AWS resources created by this project
