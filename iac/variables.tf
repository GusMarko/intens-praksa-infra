
variable "env" {
  type = string
  description = "current branch"
}

variable "aws_region" {
  type = string
}

variable "access_key" {
  type = string
  description = "AWS credentials"
}

variable "secret_key" {
  type = string
  description = "AWS credentials"
}

variable "priv_sub" {
  type = string
}

variable "pub_sub" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "cert_arn" {
  type= string
}