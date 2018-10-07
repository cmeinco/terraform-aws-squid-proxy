# TODO: make password a variable passed in
# err, pwd must satisfy:
# satisfy regular expression pattern: (?=^.{8,64}$)((?=.*\d)(?=.*[A-Z])(?=.*[a-z])|(?=.*\d)(?=.*[^A-Za-z0-9\s])(?=.*[a-z])|(?=.*[^A-Za-z0-9\s])(?=.*[A-Z])(?=.*[a-z])|(?=.*\d)(?=.*[A-Z])(?=.*[^A-Za-z0-9\s]))^.*
# grc love: https://www.grc.com/passwords.htm
resource "aws_directory_service_directory" "seafoam" {
  name     = "example.seafoam.com"
  password = "|ZAoQ;3#UV,0G%`TxaBi<U*jJ)ErWLep=IW-IJkcadzARv(ZPuW4vTpfPzd"
  size     = "Small"

  vpc_settings {
    vpc_id     = "${aws_vpc.default.id}"
    subnet_ids = ["${aws_subnet.eu-west-1a-private.id}", "${aws_subnet.eu-west-1b-private.id}"]
  }

  tags {
    Project = "foo"
  }
}
