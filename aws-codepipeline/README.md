# CI/CD Pipeline with AWS CodePipeline

## Building a Java Spring Web Application using Maven with AWS CodeBuild, AWS CodeDeploy.

- The source code of the application is in a private AWS CodeCommit Repository. 
- Have uploaded the code at https://github.com/dannybritto96/HelloWorld-WAR also.
- The repository contains the buildspec and appspec files in its root.

## To use GitHub as source provider:

- Change the below block accordingly in *code_build.tf*
```hcl
source {
        type = "GITHUB"
        location = "https://github.com/dannybritto96/HelloWorld-WAR.git"
    }
```
- Change the below values in the source block of *code_pipeline.tf*
```hcl
owner            = "ThirdParty"
provider         = "GitHub"
```
- Set GITHUB_TOKEN environment variable.