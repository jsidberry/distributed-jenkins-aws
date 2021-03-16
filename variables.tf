variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}

variable "region_master" {}
variable "region_worker" {}

variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "workers-count" {
  type    = number
  default = 2
}

variable "instance-type" {
  default = "t3.micro"
}

variable "profile" {
  type    = string
  default = "default"
}

variable "webserver-port" {
  type    = number
  default = 8080
}

variable "dns-name" {
  type    = string
  default = "juansidberry.link."
}
