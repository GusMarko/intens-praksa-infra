
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

variable "cert_arn" {
  type= string
}

variable "vpc_cidr_block" {
  description = "CIDR range for the VPC"
  type        = string
}

variable "pub_subnet_a_cidr" {
  description = "CIDR for public subnet A"
  type        = string
}

variable "pub_subnet_b_cidr" {
  description = "CIDR for public subnet B"
  type        = string
}

variable "priv_subnet_a_cidr" {
  description = "CIDR for private subnet A"
  type        = string
}

variable "priv_subnet_b_cidr" {
  description = "CIDR for private subnet B"
  type        = string
}

variable "az_a" {
  description = "Availability Zone A"
  type        = string
}

variable "az_b" {
  description = "Availability Zone B"
  type        = string
}
