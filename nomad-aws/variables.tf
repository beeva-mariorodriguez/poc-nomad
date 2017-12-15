variable "region" {
  default = "eu-west-2"
}

variable "azs" {
  default = ["eu-west-2a", "eu-west-2b"]
}

variable "keyname" {
  default = "poc-nomad"
}

variable "consulversion" {
  default = "1.0.1"
}

variable "vaultversion" {
  default = "0.9.0"
}

variable "nomadversion" {
  default = "0.7.1"
}

variable "dnsmasqimage" {
  default = "andyshinn/dnsmasq:2.78"
}

variable "consulkey" {}
variable "nomadkey" {}
