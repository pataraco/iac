# Blueprints Directory

# Overview
Hold common blueprints used by individual module deployments

## Usage
1. Create sybolic links from the blueprints directory to desired blueprint
2. Refer to blueprint symlink in coresponding config (YAML) file

## Stacker Blueprints
* acm.py - generate an ACM request
    * variables (required)
        - DomainName: Name of Domain to secure
        - AlternateDomainNames: Alternate domain name(s) for SSL Certificate
* alb.py
    * variables (required)
        - AlbName: Name of ALB
        - ApplicationName: Name of application for which ALB will be used
        - SgIdList: List of Security Group IDs for ALB
        - Subnets: List of Subnet Ids to attach
    * variables (optional)
        - EnvironmentName: Name of Environment (default: production)
        - Scheme: Specify whether ALB is Internal or Internet-facing choices: internal or internet-facing (default: internet-facing)
* ecs.py
    * variables (required)
        - ContainerName: Name of Container
        - EcsTaskExecIamRoleArn: ARN of the ECS Task execution IAM Role
        - EcsTaskRoleName: Name of ECS Task IAM Role
        - HealthCheckGracePeriod: Service Health Check Grace Period (seconds)
        - MaxPercent: Maximum Percent for Running Tasks
        - MinHealthyPercent: Minimun Healthy Percent for Running Tasks
        - Subnets: Private Subnet name(s) of the VPC
        - S3Bucket: Bucket Name for App
        - SgIdList: List of Security Group IDs for the ECS Service
        - TargetGroupArn: ARN of ALB Target Group
        - TaskCpu: Task CPU Size
        - TaskMem: Task Memory Size
    * variables (optional)
        - EnvironmentName: Name of Environment (default: production)
        - NumberOfTasks: Number of Tasks to run (default: 1)
* listener.py
    * variables (required)
        - AlbArn: ARN of ALB
        - ListeningPort: ALB Listening Port'
        - ListeningProtocol: Listening Protocol (HTTP or HTTPS)
    * variables (optional)
        - AcmCertArn: ARN of ACM Certificate (default: '')
        - DefaultTargetGroupArn: ARN of the default Target Group
        - SslPolicy: Security policy defining ciphers and protocols (default: ELBSecurityPolicy-TLS-1-1-2017-01)
* listener_rule.py
    * variables (required)
        - Condition: Rule Condition (host-header or path-pattern)
        - Value: Value of the Condition (host name or path)
        - Priority: Rule Priority (must be unique)'
        - ListenerArn: ARN of the Listener to attach to
        - TargetGroupArn: ARN of the Target Group to forward to
* s3.py
    * variables (required)
        - BucketName: Name of S3 Bucket to create'
* security_group.py
    * variables (required)
        - ApplicationName: Name of application for tagging purposes
        - SgName: Name of Security Group to create
        - SgDescription: Description of new Security Group
        - VpcId: VPC ID
    * variables (optional)
        - EnvironmentName: Name of Environment (default: production)
* security_group_ingress.py
    * variables (required)
        - FromPort: From Port to allow
        - ToPort: To Port to allow
        - GroupId: Security Group ID to attach ingress rule to
    * variables (optional)
        - IpProtocol: IP Protocol to allow: tcp, udp or icmp (default: tcp)
        - FromCidr: CIDR to allow traffic from (default: '')
        - FromSgId: Security Group ID to allow traffic from (default: '')
* target_group.py
    * variables (required)
        - AppPort: Application Listening Port'
        - AppProtocol: Application Protocol (HTTP, HTTPS or TCP)
        - ApplicationName: Name of Application
        - TargetGroupName: Name of Target Group (max length 32)
        - VpcId: VPC ID
    * variables (optional)
        - EnvironmentName: Name of Environment (default: production)
        - Matcher: Successful health check response(s) from a target (Examples: 200, 200,301 or 200-299. (default: 200)
        - TargetType: Target Type (instance or ip) (default: instance)
* utils - standalone utility for testing

## Testing
To validate syntax and see generated CloudFormation template, for example you can execute `python blueprints/alb.py` at the top of the deployment directory.

## Troubleshooting
Typically `make deploy` will fail for the following common reasons:

* Missing/Undefined variables in the environment file (`*.env`) referenced in the configuration (`YAML`) file
* Missing/Undefined/Mismatched variables in the configuration (`YAML`) file referenced in the blueprint (Python) file
* Python syntax errors in the blueprints
* CloudFormation errors

Pay attention to and look closely in the Python error/traceback. It should be fairly obvious where the issue is. Again, you can use the `Testing` method above to test your blueprints. And, if it is a CloudFormation error, it should list which stack failed. Go into the AWS console and into CloudFormation and look at the events of the failed stack to get more insight into the issue.
