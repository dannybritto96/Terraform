variable "region" {
  default = "us-east-1"
  description = "AWS Region"
}

variable "reponame" {
  default = "helloWorld"
  description = "CodeCommit Repository Name"
}

variable "s3bucket_name" {
  default = "sample-dannybritto96"
  description = "S3 Bucket Name"
}

variable "codebuild_project" {
  default = "sample-project"
  description = "CodeBuild Project Name"
}

variable "codepipeline" {
  default = "samp-pipeline"
  description = "CodePipeline Name"
}

variable "codedeploy_name" {
  default = "example-app"
  description = "CodeDeploy App name"
}

variable "codedeploy_group_name" {
  default = "example-group"
  description = "Deployment Group Name"
}

variable "instance_az" {
  default = "us-east-1a"
  description = "Instance AZ"
}

variable "keyname" {
  default = "samp2"
  description = "Keyfile for Instance"
}

variable "instance_tag" {
  default = "SERV"
  description = "Name tags of instance"
}
