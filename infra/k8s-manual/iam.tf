data "aws_iam_policy_document" "ec2_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "k8s_instance_role" {
  name               = "k8s_instance_role"
  assume_role_policy = data.aws_iam_policy_document.ec2_trust_policy.json
}

resource "aws_iam_instance_profile" "k8s_instance_profile" {
  name = "k8s_instance_role"
  role = aws_iam_role.k8s_instance_role.name
}

resource "aws_iam_policy" "config_bucket_access" {
  name   = "config_bucket_access"
  path   = "/"
  policy = data.aws_iam_policy_document.config_bucket_access.json
}

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  role       = aws_iam_role.k8s_instance_role.name
  policy_arn = aws_iam_policy.config_bucket_access.arn
}

data "aws_iam_policy_document" "config_bucket_access" {
  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.kubeadm_bucket.arn,
    ]
  }

  statement {
    actions = [
      "s3:*",
    ]

    resources = [
      "${aws_s3_bucket.kubeadm_bucket.arn}",
      "${aws_s3_bucket.kubeadm_bucket.arn}/*",
    ]
  }
}
