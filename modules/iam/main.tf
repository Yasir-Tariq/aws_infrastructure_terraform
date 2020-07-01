resource "aws_iam_instance_profile" "instance_profile" {
  name = var.instance_profile
  role = aws_iam_role.role.name
}
resource "aws_iam_role" "role" {
  name = var.iam_role
  path = "/"

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
resource "aws_iam_policy" "policy" {
  name        = var.iam_policy
  path        = "/"
  description = "Full s3 access"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_policy_attachment" "role_attachment" {
  name       = var.policy_attachment
  roles      = [aws_iam_role.role.name]
  policy_arn = aws_iam_policy.policy.arn
}