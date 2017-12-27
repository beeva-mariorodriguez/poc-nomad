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
