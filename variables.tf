variable "region" {
  type    = string
  default = "us-east-2"
}
variable "ami_id" {
  type    = string
  default = "ami-09d3b3274b65d4aa"

}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "az" {
  type    = string
  default = "us-east-2a"
}