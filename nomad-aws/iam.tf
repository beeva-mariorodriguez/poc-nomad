resource "aws_iam_instance_profile" "consulagent" {
  name = "consul"
  role = "${aws_iam_role.consulagent.name}"
}

resource "aws_iam_role" "consulagent" {
  name = "consulagent"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "describeinstances" {
  name = "describeinstances"
  role = "${aws_iam_role.consulagent.id}"

  policy = <<EOF
{
  "Statement": [{
    "Effect": "Allow",
    "Action": [
      "ec2:DescribeInstances"
    ],
    "Resource": "*"
  }]
}
EOF
}
