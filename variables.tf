variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}

variable "region_master" {}
variable "region_worker" {}
variable "external_ip" { default = "0.0.0.0/0" }
variable "workers-count" {
  type    = number
  default = 1
}
variable "instance-type" {
  default = "t3.micro"
}

