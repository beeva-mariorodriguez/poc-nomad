variable "region" {
  default = "eu-west-2"
}

variable "azs" {
  default = ["eu-west-2a", "eu-west-2b"]
}

variable "keyname" {
  default = "poc-nomad"
}

variable "consulimage" {
  default = "consul:1.0.0"
}

variable "fabiolb" {
  default = "fabiolb/fabio:1.5.2-go1.9.1"
}

variable "vaultimage" {
  default = "vault:0.9.0"
}

variable "nomadversion" {
  default = "0.7.0"
}

variable "dnsmasqimage" {
  default = "andyshinn/dnsmasq:2.78"
}
