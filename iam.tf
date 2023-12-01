resource "aws_iam_policy" "test_policy" {
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ec2:*"],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "${aws_db_instance.example.master_user_secret[0].secret_arn}"
    }
  ]
}
EOF
}


resource "aws_iam_role" "test_role" {
  name               = "testRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
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

resource "aws_iam_role_policy_attachment" "test_attachment" {
  role       = aws_iam_role.test_role.name
  policy_arn = aws_iam_policy.test_policy.arn
}

resource "aws_iam_instance_profile" "teste_profile" {
  name = "test-iam-instance-profile"
  role = aws_iam_role.test_role.name
}