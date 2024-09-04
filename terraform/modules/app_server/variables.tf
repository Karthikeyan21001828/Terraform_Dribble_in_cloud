variable "vpc_id" {
  description = "The VPC ID where the instance will be deployed."
  default     = "vpc-024e76b5f8ee97841"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID to use for the instance."
  default     = "ami-04cdc91e49cb06165"
  type        = string
}

variable "instance_type" {
  description = "The type of the instance."
  default     = "t3.medium"
  type        = string
}

variable "key_name" {
  description = "The key name for SSH access."
  default     = "DevOpsKeyPair"
  type        = string
}
