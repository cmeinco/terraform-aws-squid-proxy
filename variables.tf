#variable "aws_access_key" {}
#variable "aws_secret_key" {}
#variable "aws_key_path" {}
#variable "aws_key_name" {}
variable "aws_key_name" {
  default = "MacBookProCMEINCO"
}

variable "aws_region" {
    description = "EC2 Region for the VPC"
    default = "us-west-2"
}

#https://aws.amazon.com/amazon-linux-ami/
variable "amis" {
    description = "AMIs by region"
    default = {
        eu-west-1 = "" # ubuntu 14.04 LTS
        #us-west-2 = "ami-35d6664d"
        us-west-2 = "ami-74d8680c"
    }
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "10.0.0.0/24"
}
variable "public_subnet_cidr_b" {
    description = "CIDR for the Public Subnet"
    default = "10.0.3.0/24"
}
variable "private_subnet_cidr" {
    description = "CIDR for the Private Subnet"
    default = "10.0.1.0/24"
}

variable "private_subnet_cidr_b" {
    description = "CIDR for the Private Subnet"
    default = "10.0.2.0/24"
}
