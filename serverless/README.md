# Serverless Framework
Some general notes about using and configuring the
[Serverless Framework](https://serverless.com/) for deployment in to cloud
infrastructure, such as AWS.

More information can be [found here](https://serverless.com/framework/docs/)

- [Installation](#Installation)
- [Dashboard (optional)](#Dashboard-optional)
- [Basic CLI Usage](#Basic-CLI-Usage)
- [Plugins](#Plugins)
- [Questions & To Do](#Questions-and-To-Do)
- [Observations](#Observations)
- [Prerequisites](#Prerequisites)


## Installation
You need to install both `node` and `serverless`.

### Install `node` & `serverless` using `Homebrew`
   ```
   $ brew install node
   $ brew install serverless
   ```

### Install using other package manager
Install `node` as [detailed here](https://nodejs.org/en/download/package-manager/) 
and `serverless` with `node`:

   * `$ npm install --global|-g serverless[@<version>]`


## Dashboard (optional)
[Serverless Framework Dashboard](https://dashboard.serverless.com) is a unified
view of your Serverless applications, featuring monitoring, alerting,
deployments & much more.

   1. You can sign-up for free and create an Account
   2. Login to your account:

   * `$ serverless login`


## Basic CLI Usage
Basic usage of the `Serverless framework`. And the plugins in use. `sls` is an
alias for `serverless`, which should be automatically installed when installing
`serverless`. The `--help | -h` options to the `serverless` CLI are very helpful.

For more information see (for example for AWS and/or GCP):
   * [AWS Provider Docs](https://www.serverless.com/framework/docs/providers/aws/)
   * [AWS CLI Reference](https://www.serverless.com/framework/docs/providers/aws/cli-reference/)
   * [AWS Events](https://www.serverless.com/framework/docs/providers/aws/events/)
   * [GCP Provider Docs](https://www.serverless.com/framework/docs/providers/google/)
   * [GCP CLI Reference](https://www.serverless.com/framework/docs/providers/google/cli-reference/)
   * [GCP Event](https://www.serverless.com/framework/docs/providers/google/events/)

### Start/Create a new project
This will walk you through creating a new project/service and generate a 
starting point for you to build upon.

   ```bash
   $ serverless  # interactive
   # or
   $ sls create -t aws-nodejs -p hello-world
   ```

### Update Serverless
   ```bash
   $ npm i serverless
   ```

### Install Plugins
Install a plugin. See [Plugins](#Plugins) (below) for more info.
   ```bash
   # One step (installs and lists in the `serverless.yaml` "plugins section")
   # Note: this method will remove any comments within the 'plugins' section
   $ sls plugin install -n PLUGIN
   ```

### Validate Config Syntax (Resolve Variables)
Prints your serverless config file with all variables resolved. Helps to verify
syntax and variable resolution.
   ```bash
   $ sls print [--config | -c CONFIG] [--format yaml | json | text]
   ```

### Deploy
Deploys your service via cloud provider API's/Service, for example
`AWS CloudFormation` or `Google Cloud API`.
   ```bash
   $ sls deploy [-s STAGE] [-r REGION] [-f FUNCTION] [-v]
   # or
   $ sls deploy [--stage STAGE] [--region REGION] [--config CONFIG] [--verbose]
   ```

### Information
Get information (including API endpoints) [and, if in AWS, AWS CloudFormation
Stack Outputs] about the service(s)
   ```bash
   $ sls info [-s STAGE] [-r REGION] [-c CONFIG] [-v]
   # or
   $ sls info [--stage STAGE] [--region REGION] [--config CONFIG] [--verbose]
   ```

### Deployed Lambdas
Get deployed lambda functions information
   ```bash
   $ sls deploy list functions
   ```

### Test
Test functions (both deployed/locally) and API locally of the service
   ```bash
   # Lambda Functions:
   $ sls invoke [local] -f FUNCTION [-d '{"Key": "Val"}']
   # APIs (requires: `serverless-offline` plugin):
   $ npm install serverless-offline --save-dev  # (needed only once)
   $ sls offline
   ```

### Remove (destroy)
Remove [all] deployed service(s).
   ```bash
   $ sls remove [-s STAGE] [-c CONFIG]
   ```

### View/Watch Logs
View/Watch the logs of a specific function.
   ```bash
   $ sls logs -f FUNCTION [--startTime 5m] [-t | --tail]
   ```


## Plugins
[Serverless Plugins](https://www.serverless.com/framework/docs/providers/aws/guide/plugins/)
allow users to extend or overwrite the framework's core functionality. 

### Search for Plugins
   ```bash
   serverless plugin search --query QUERY
   ```

### Install Plugins
   ```bash
   # (Option A): two steps
   # 1. install the plugin
   $ npm install --save-dev PLUGIN
   # 2. add to "plugins section" in the `serverless.yaml` file, e.g.
   plugins:
     - PLUGIN
   
   # OR

   # (Option B): one step (installs and lists in the `serverless.yaml` "plugins section")
   # Note: this method will remove any comments within the 'plugins' section
   $ sls plugin install -n PLUGIN
   ```

### Example/Common Plugins

- **serverless-offline**
  - Allows local testing of REST API gateways
- **serverless-aws-documentation**
  - Create/Use API models and documentation
- **serverless-pseudo-parameters**
  - Use CloudFormation pseudo parameters
  - E.G. `"arn:aws:lambda:#{AWS::Region}:#{AWS::AccountId}:function:${self:service}"`
- **serverless-reqvalidator-plugin**
  - Configure/Use request validators on a method
- **serverless-add-api-key**
  - Manages API keys and allows re-usage across multiple API gateway services
- **serverless-python-requirements**
  - Grabs all Pipfile requirements and packages up for deployment
  - This can be used as an alternative to using lambda layers and just having
    everything that a function needs
  - **Pros**: one step, automatic process
  - **Cons**: Larger deployment artifacts, functions not in-line
    observable/editable within AWS console, and duplication of code
  - Use instead of Lambda layers


## Questions and To Do
List of questions, things to do and ideas to try.

- Make use lambda aliases and API stages for automatic deployments for version
  control
- How to create/use lambda functions aliases?
- Check out the `serverless-layers` (or similar) plugin(s) for managing lambda
  layers


## Observations
List of observations found while testing.

- Serverless deploys new versions of lambda functions, layers and re-deploys
  the API stage for every deployment (`sls deploy`)
- A `sls deploy` deploys all functions, hence creating a new version of the
  lambda (unless you specify the `-f` option to only deploy one functon)
  (`cloudformation package` would only upload/update functions that change)
- The `sls deploy` command results displays API endpoint(s)/method(s) created
- Default lambda memory/timeout settings: 1024MB/6 seconds (override in
  provider/functions)
- Lambda's tagged with key ’STAGE’ automatically set to the stage
- API endpoint does NOT change with multiple deployments
- VPC settings are hard-coded (but shouldn’t/wouldn’t change much) (maybe
  create a plugin)
- Local lambda and api testing
- Can see CW logs from cli
- Can’t remove single/specific function
- API IDs/endpoints don't change with subsequent deploys
- Lambda ARNs and API IDs do not change for each serverless deployment
- Don't think you can set lambda aliases natively without a plugin
- You can not define/use models or docs without a plugin
- Serverless documentation/models plugin - can't use the pre-existing "Empty"
  API model, had to create a new
- Serverless documentation/models plugin - models are created as one-liners as
  viewed in the AWS console
- Doesn't appear to be a way to use encrypted lambda environment variables with
  CloudFormation or Serverless


## Prerequisites
Having a familiarity with the following concepts and libraries will help in
understanding serverless technologies.

- [Serverless (AWS)](https://serverless.com/framework/docs/providers/aws/)
- [AWS Gateway API](https://docs.aws.amazon.com/apigateway/latest/developerguide/welcome.html)
- [AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html)
- [AWS Lambda Layers](https://docs.aws.amazon.com/lambda/latest/dg/configuration-layers.html)
