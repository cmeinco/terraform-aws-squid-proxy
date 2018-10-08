/******************************************************************************\
| nat-gateways.tf
| This config builds the nat gateways, installs squid and adds default routes
| to the subnets.
|
| Known Bugs: None
| Estimated Runtime Cost: Medium
| Change Log:
| 2018/02/09 - tls - refactored and moved out NAT gateways and those routes to
|                    diff config to separate out states based on runtime cost
| 9999/99/99 - xxx - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
|                    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
| Known Issues:
| #01 - 2018/02/09 - tls - logging/sendings logs to s3 needs to be fixed
| #02 - 2018/02/09 - tls - need to have the instances update/patch themselves
|                          as soon as they launch to make sure they are latest
|                          and greatest.
\******************************************************************************/

/*
  NAT Instance - AZ A
*/
#https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html#AvailableInstanceTypes
resource "aws_instance" "nat" {
    ami = "${data.aws_ami.nat_ami.id}"
    availability_zone = "${var.aws_region}a"
    instance_type = "t2.micro"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.nat.id}"]
    subnet_id = "${aws_subnet.eu-west-1a-public.id}"
    associate_public_ip_address = true
    source_dest_check = false

    user_data = "${file("./squid-nat-user-data.txt")}"

    #created by s3 config and state
    iam_instance_profile = "${aws_iam_instance_profile.chumbucket_consumer_profile.name}"

    tags {
        Name = "VPC NAT"
    }
}

resource "aws_eip" "nat" {
    instance = "${aws_instance.nat.id}"
    vpc = true
}

resource "aws_route_table" "eu-west-1a-private" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.nat.id}"
    }

    tags {
        Name = "Private Subnet"
    }
}
output "nat_address-dns" {
  value = "${aws_instance.nat.public_dns}"
}
output "nat_address-ip" {
  value = "${aws_instance.nat.public_ip}"
}

/*
  NAT Instance - AZ B
*/
resource "aws_route_table_association" "eu-west-1a-private" {
    subnet_id = "${aws_subnet.eu-west-1a-private.id}"
    route_table_id = "${aws_route_table.eu-west-1a-private.id}"
}
resource "aws_route_table" "eu-west-1b-private" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        instance_id = "${aws_instance.nat-b.id}"
    }

    tags {
        Name = "Private Subnet"
    }
}

resource "aws_route_table_association" "eu-west-1b-private" {
    subnet_id = "${aws_subnet.eu-west-1b-private.id}"
    route_table_id = "${aws_route_table.eu-west-1b-private.id}"
}

resource "aws_instance" "nat-b" {
    ami = "${data.aws_ami.nat_ami.id}"
    availability_zone = "${var.aws_region}b"
    instance_type = "t2.micro"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.nat.id}"]
    subnet_id = "${aws_subnet.eu-west-1b-public.id}"
    associate_public_ip_address = true
    source_dest_check = false

    user_data = "${file("./squid-nat-user-data.txt")}"

    #created by s3 config and state
    iam_instance_profile = "${aws_iam_instance_profile.chumbucket_consumer_profile.name}"

    tags {
        Name = "VPC NAT"
    }
}
resource "aws_eip" "nat-b" {
    instance = "${aws_instance.nat-b.id}"
    vpc = true
}
output "nat_addressb-dns" {
  value = "${aws_instance.nat-b.public_dns}"
}
output "nat_addressb-ip" {
  value = "${aws_instance.nat-b.public_ip}"
}

# automatic lookup based on   #https://aws.amazon.com/amazon-linux-ami/
data "aws_ami" "nat_ami" {
  most_recent      = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat*"]
  }

}

output "latest_ami" {
  value = "${data.aws_ami.nat_ami.name}"
}