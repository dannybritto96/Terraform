resource "aws_iam_role" "codepipeline_role" {
  name = "pipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = "${aws_iam_role.codepipeline_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.samps3.arn}",
        "${aws_s3_bucket.samps3.arn}/*"
      ]
    },
    {
        "Effect": "Allow",
        "Resource": [
            "${data.aws_codecommit_repository.test.arn}"
        ],
        "Action": [
            "codecommit:GitPull",
            "codecommit:GetBranch",
            "codecommit:GetCommit",
            "codecommit:UploadArchive",
            "codecommit:GetUploadArchiveStatus"
        ]
    },
    {
        "Effect": "Allow",
        "Resource": "*",
        "Action": [
            "codedeploy:*"
        ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_codepipeline" "codepipeline" {
    name = "${var.codepipeline}"
    role_arn = "${aws_iam_role.codepipeline_role.arn}"
    artifact_store {
        location = "${aws_s3_bucket.samps3.id}"
        type = "S3"
    }
    stage {
        name = "Source"

        action {
            name = "Source"
            category = "Source"
            owner = "AWS"
            provider = "CodeCommit"
            version = "1"
            output_artifacts = ["source_output"]

            configuration = {
                RepositoryName = "${data.aws_codecommit_repository.test.repository_name}"
                BranchName = "master"
            }
        }
    }

    stage {
        name = "Build"

        
            action {
                name = "Build"
                category = "Build"
                owner = "AWS"
                provider = "CodeBuild"
                input_artifacts = ["source_output"]
                output_artifacts = ["build_output"]
                version = "1"

                configuration = {
                    ProjectName = "${aws_codebuild_project.sample.name}"
                }
            }


    }

    stage {
        name = "Deploy"

        action {
            name = "Deploy"
            category = "Deploy"
            owner = "AWS"
            provider = "CodeDeploy"
            input_artifacts = ["build_output"]
            version = "1"

            configuration = {
                ApplicationName = "${aws_codedeploy_app.example.name}"
                DeploymentGroupName = "${aws_codedeploy_deployment_group.example.deployment_group_name}"
            }
        }
    }
    depends_on = [
        "aws_codebuild_project.sample",
        "aws_codedeploy_app.example",
        "aws_codedeploy_deployment_group.example"
    ]
}