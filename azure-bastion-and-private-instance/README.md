# Create a Bastion Instance and a Private Instance in Azure

### To create two instances, one of which cannot be accessed from the public internet but can be accessed only via the other instance which is the bastion server.

This Terraform script creates the required VNET, Subnets, Route Tables, Route Table Associations, Network Security Groups and the Instances to acheive this.

PS: The instances in the private subnet do not have internet access by default.