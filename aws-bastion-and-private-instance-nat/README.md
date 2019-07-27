# Create a Bastion Instance and a Private Instance in AWS

### To create two EC2 instances, one of which cannot be accessed from the public internet but can be accessed only via the other instance which is the jump server.

This Terraform script creates the required VPC, Subnets, NAT Gateway, Route Tables, Route Table Associations, Security Groups and the EC2 Instances to acheive this.