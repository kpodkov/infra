module "iam_user" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "~> 4.3"

  name                          = "terraform-user"
  create_user                   = true
  create_iam_access_key         = true
  create_iam_user_login_profile = false
}

module "iam_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 4.3"

  trusted_role_actions = ["sts:AssumeRole"]
  trusted_role_arns    = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/AccountAdmin",
    module.iam_user.iam_user_arn
  ]

  create_role = true

  role_name         = "TerraformRole"
  role_requires_mfa = false

  custom_role_policy_arns = [module.iam_policy.arn]

  number_of_custom_role_policy_arns = 2
}

module "iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 4.3"

  name        = "TerraformPolicy"
  path        = "/"
  description = "Permissions for the TerraformRole"

  create_policy = true

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*",
        "sts:AssumeRole",
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}