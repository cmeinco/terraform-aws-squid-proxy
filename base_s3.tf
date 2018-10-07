/******************************************************************************\
| main.tf
| Creates the S3 bucket and IAM stuffs
|
| Known Bugs: None
| Estimated Runtime Cost: Low
| Change Log:
| 2018/02/09 - tls - initial version
| 9999/99/99 - xxx - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
|                    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
| Known Issues:
| #01 - 2018/02/09 - tls - make region variable
| #02 - 2018/02/09 - tls - Warning: aws_iam_instance_profile.chumbucket_consumer_profile: "roles": [DEPRECATED] Use `role` instead. Only a single role can be passed to an IAM Instance Profile
\******************************************************************************/

#resource "aws_s3_bucket" "chumbucket" {
#  # We explicitly prevent destruction using terraform. Remove this only if you really know what you're doing.
#  lifecycle {
#    prevent_destroy = true
#  }
data "aws_s3_bucket" "chumbucket" {
  bucket = "my-s3-chumbucket"
}

resource "aws_iam_instance_profile" "chumbucket_consumer_profile" {
  name = "s3bucket_consumer_profile"
  roles = ["${aws_iam_role.chumbucket_consumer_role.name}"]
}

resource "aws_iam_role" "chumbucket_consumer_role" {
  name = "ec2role_s3bucket_consumer_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_s3_bucket_policy" "chumbucket" {
  bucket = "${data.aws_s3_bucket.chumbucket.id}"
  policy =<<POLICY
{
  "Version": "2012-10-17",
  "Id": "CHUMBUCKET_POLICY_20180220",
  "Statement": [
    {
        "Effect": "Allow",
        "Principal":{"AWS":"${aws_iam_role.chumbucket_consumer_role.arn}"},
        "Action": "s3:ListBucket",
        "Resource": "${data.aws_s3_bucket.chumbucket.arn}"
    },
    {
        "Effect": "Allow",
        "Principal":{"AWS":"${aws_iam_role.chumbucket_consumer_role.arn}"},
        "Action": [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject"
        ],
        "Resource": "${data.aws_s3_bucket.chumbucket.arn}/*"
    },
    {
      "Effect": "Deny",
      "Principal":"*",
      "Action": [
        "*"
      ],
      "Resource": [
        "${data.aws_s3_bucket.chumbucket.arn}/*"
      ],
      "Condition": {
        "DateLessThan": {
          "aws:TokenIssueTime": "2018-02-21T04:53:28.084Z"
        }
      }
    }
  ]
}
POLICY
}

output "s3_bucket_name" {
  value = "${data.aws_s3_bucket.chumbucket.bucket}"
}

output "s3_iam_instance_profile_name" {
  value = "${aws_iam_instance_profile.chumbucket_consumer_profile.name}"
}
