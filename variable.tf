variable "access_key" {

}


variable "secret_key" {

}

variable "zone" {
  default = "us-east-1"

}

variable "ports" {
  type    = list(number)
  default = [22, 80, 443]

}