data "aws_iam_policy_document" "describeinstances" {
  statement {
    actions = [
      "ec2:DescribeInstances",
    ]

    resources = ["*"]
    effect    = "Allow"
  }
}

data "aws_iam_policy_document" "assumerole" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_instance_profile" "consulagent" {
  name = "consul"
  role = "${aws_iam_role.consulagent.name}"
}

resource "aws_iam_role" "consulagent" {
  name               = "consulagent"
  assume_role_policy = "${data.aws_iam_policy_document.assumerole.json}"
}

resource "aws_iam_role_policy" "describeinstances" {
  name   = "describeinstances"
  role   = "${aws_iam_role.consulagent.id}"
  policy = "${data.aws_iam_policy_document.describeinstances.json}"
}
