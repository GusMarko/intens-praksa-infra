resource "aws_ecr_repository" "intens_praksa" {
  name                 = "intens-praksa-${var.env}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "aws_iam_policy_document" "intens_praksa" {
  statement {
    sid    = "ecr-access"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"] 
    }

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
  }
}

resource "aws_ecr_repository_policy" "intens_praksa" {
  repository = aws_ecr_repository.intens_praksa.name
  policy     = data.aws_iam_policy_document.intens_praksa.json
}