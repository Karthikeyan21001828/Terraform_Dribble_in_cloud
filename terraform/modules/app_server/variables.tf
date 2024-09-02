variable "vpc_id" {
  description = "The VPC ID where the instance will be deployed."
  type        = string
}

variable "ami_id" {
  description = "The AMI ID to use for the instance."
  type        = string
}

variable "instance_type" {
  description = "The type of the instance."
  default     = "t2.micro"
  type        = string
}

variable "key_name" {
  description = "The key name for SSH access."
  type        = string
}
