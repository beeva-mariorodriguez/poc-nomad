variable "region" {
  default = "eu-west-2"
}

variable "azs" {
  default = ["eu-west-2a", "eu-west-2b"]
}

variable "keyname" {
  default = "poc-nomad"
}

variable "consul" {
  default = "consul:1.0.0"
}

variable "fabiolb" {
  default = "fabiolb/fabio:1.5.2-go1.9.1"
}
