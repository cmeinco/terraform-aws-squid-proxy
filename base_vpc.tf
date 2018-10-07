/******************************************************************************\
| vpc.tf
| This config builds the base vpc, subnets and SGs which systems can be
| stood up and attached to.
|
| Known Bugs: None
| Estimated Runtime Cost: Minimal
| Change Log:
| 2018/02/09 - tls - refactored and moved out NAT gateways and those routes to
|                    diff config to separate out states based on runtime cost
| 9999/99/99 - xxx - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
|                    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
| Known Issues: None
| #01 - 2018/02/09 - tls - need to variabalize vpc name; just realized this
|                          was setting the default vpc also.
| #02 - 2018/02/09 - tls - cleanup the ugly security groups
\******************************************************************************/

/* Base VPC */
resource "aws_vpc" "default" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags {
        Name = "terraform-aws-vpc"
    }
}

/* Security Group - NAT Instance */
resource "aws_security_group" "nat" {
    name = "vpc_nat"
    description = "Allow traffic to pass from the private subnet to the internet"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}","${var.private_subnet_cidr_b}"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}","${var.private_subnet_cidr_b}"]
    }
    ingress {
            from_port = 3128
            to_port = 3130
            protocol = "tcp"
            cidr_blocks = ["${var.private_subnet_cidr}","${var.private_subnet_cidr_b}"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["${var.private_subnet_cidr}","${var.private_subnet_cidr_b}"]
    }
    /*
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    */

    egress {
        from_port = 80
        to_port = 80
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
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    egress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.default.id}"

    tags {
        Name = "NATSG"
    }
}


/*
  Common IGW - create IGW and add routes to public subnets
*/
resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.default.id}"
}

resource "aws_route_table" "eu-west-1a-public" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags {
        Name = "Public Subnet"
    }
}
resource "aws_route_table_association" "eu-west-1a-public" {
    subnet_id = "${aws_subnet.eu-west-1a-public.id}"
    route_table_id = "${aws_route_table.eu-west-1a-public.id}"
}

resource "aws_route_table" "eu-west-1b-public" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags {
        Name = "Public Subnet"
    }
}

resource "aws_route_table_association" "eu-west-1b-public" {
    subnet_id = "${aws_subnet.eu-west-1b-public.id}"
    route_table_id = "${aws_route_table.eu-west-1b-public.id}"
}



/*
  Public Subnet A
*/
resource "aws_subnet" "eu-west-1a-public" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.public_subnet_cidr}"
    availability_zone = "${var.aws_region}a"

    tags {
        Name = "Public Subnet"
    }
}

/*
  Public Subnet B
*/
resource "aws_subnet" "eu-west-1b-public" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.public_subnet_cidr_b}"
    availability_zone = "${var.aws_region}b"

    tags {
        Name = "Public Subnet"
    }
}

/*
  Private Subnet A
*/
resource "aws_subnet" "eu-west-1a-private" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.private_subnet_cidr}"
    availability_zone = "${var.aws_region}a"

    tags {
        Name = "Private Subnet"
    }
}

/*
  Private Subnet B
*/
resource "aws_subnet" "eu-west-1b-private" {
    vpc_id = "${aws_vpc.default.id}"

    cidr_block = "${var.private_subnet_cidr_b}"
    availability_zone = "${var.aws_region}b"

    tags {
        Name = "Private Subnet"
    }
}


output "vpc_default_id" {
  value = "${aws_vpc.default.id}"
}

