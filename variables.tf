variable "domain" {
  type        = string
  description = "The domain your site will be hosted at."
  default     = "freegogreen.tk"
}

variable "region" {
  type        = string
  description = "The AWS region where you want to deploy resources."
  default     = "us-west-1"
}
