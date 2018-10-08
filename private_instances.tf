/******************************************************************************\
| private.tf
| This config builds instances and security groups used in the private subnet
| Instances can be used for testing instead of having to build out workstations
| to test routing problems, etc.  Security Groups are used by workstations.
|
| Known Bugs: None
| Estimated Runtime Cost: Medium
| Change Log:
| 2018/02/09 - tls - commented out to prevent run
| 9999/99/99 - xxx - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
|                    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
| Known Issues:
| #00 - 9999/99/99 - xxx - ZZZZZZZZZZZZZZZZZZZ
\******************************************************************************/

/*
  Database Servers
*/
resource "aws_security_group" "db" {
    name = "vpc_db"
    description = "Allow incoming database connections stuff."

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    egress {
        from_port = 3128
        to_port = 3130
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.default.id}"

    tags {
        Name = "DBServerSG"
    }
}

#https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html#AvailableInstanceTypes

resource "aws_instance" "db-1" {
    availability_zone = "us-west-2a"
    ami = "${data.aws_ami.private_instance_ami.id}"
    instance_type = "t2.nano"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.db.id}"]
    subnet_id = "${aws_subnet.eu-west-1a-private.id}"
    source_dest_check = false

    tags {
        Name = "DB Server 1"
    }
}

resource "aws_instance" "db-2" {
    ami = "${data.aws_ami.private_instance_ami.id}"
    availability_zone = "us-west-2b"
    instance_type = "t2.nano"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.db.id}"]
    subnet_id = "${aws_subnet.eu-west-1b-private.id}"
    source_dest_check = false

    tags {
        Name = "DB Server 2"
    }
}


output "db_address" {
  value = "${aws_instance.db-1.public_dns}"
}

# automatic lookup based on   #https://aws.amazon.com/amazon-linux-ami/
data "aws_ami" "private_instance_ami" {
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

output "latest_private_ami" {
  value = "${data.aws_ami.private_instance_ami.name}"
}