
provider "aws" {
  region                  = "us-west-2"

}

# terraform.tf
terraform {
 backend "s3" {
   encrypt = true
   bucket = "terraform-remote-state-cmeinco"
   dynamodb_table = "terraform-state-lock-dynamo"
   region = "us-west-2" 
   key = "chumbucketstate/squid-state.tfstate"
 }
}


