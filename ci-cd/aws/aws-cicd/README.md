# AWS CI/CD

CI/CD testing with AWS CodeCommit, CodeBuild and CodePipeline


## Contents

- [Setup](#Setup)
- [Questions](#Questions)
- [To Do](#To-Do)


## Setup

1. Create AWS CodeCommit repo
2. Create IAM user with access to the repo
3. Generate Git credentials (HTTPS) for the user for the repo (or upload SSH public key)
4. Configure `git` for CodeCommit access by following [this documentation](https://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-https-unixes.html#setting-up-https-unixes-credential-helper)
5. Create AWS CodeBuild project (refer to the correct `buildspec.yaml` file)
6. Create AWS CodePipeline pipeline


## Questions

List of questions that come up and need to be answered


## To Do

List of actions items that come up and need to be completed
