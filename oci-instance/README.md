## Terraform deployment to create a Instance, Virtual Network, Public Subnet, Internet Gateway and a Route Table in Oracle Cloud.

### To get Tenant OCID, User OCID and adding Keys
Follow the link: <https://docs.cloud.oracle.com/iaas/Content/API/Concepts/apisigningkey.htm>

### Add Private and Public Keys file locations to Path

export TF_VAR_public_key_path=/Users/user/.oci/oci_api_key_public.pem
export TF_VAR_private_key_path=/Users/user/.oci/oci_api_key.pem