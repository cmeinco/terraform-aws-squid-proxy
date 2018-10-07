resource "aws_directory_service_directory" "seafoam" {
  name     = "example.seafoam.com"
  password = "REPLACE_SIMPLE_AD_PASSWORD"
  size     = "Small"

  vpc_settings {
    vpc_id     = "${data.aws_vpc.default.id}"
    subnet_ids = ["${data.aws_subnet.eu-west-1a-private.id}", "${data.aws_subnet.eu-west-1b-private.id}"]
  }

  tags {
    Project = "foo"
  }
}
