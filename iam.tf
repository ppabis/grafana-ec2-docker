/**
  Configures IAM role for the instance to be accessible via SSM and allows it to read from the Timestream database.
**/

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile-${random_string.stack_id.result}"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_role-${random_string.stack_id.result}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "timestream" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonTimestreamReadOnlyAccess"
}
