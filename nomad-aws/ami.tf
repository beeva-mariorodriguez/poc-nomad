data "aws_ami" "coreos" {
  most_recent = true

  filter {
    name   = "owner-id"
    values = ["679593333241"]
  }

  filter {
    name   = "name"
    values = ["CoreOS-stable-*"]
  }
}

data "aws_ami" "beevalabs-poc-nomad-consulserver" {
  most_recent = true

  filter {
    name   = "owner-id"
    values = ["602636675831"]
  }

  filter {
    name   = "name"
    values = ["beevalabs-poc-nomad-consulserver-1.0.0-*"]
  }
}

data "aws_ami" "beevalabs-poc-nomad-nomadserver" {
  most_recent = true

  filter {
    name   = "owner-id"
    values = ["602636675831"]
  }

  filter {
    name   = "name"
    values = ["beevalabs-poc-nomad-nomadserver-0.6.3-*"]
  }
}

data "aws_ami" "beevalabs-poc-nomad-nomadclient" {
  most_recent = true

  filter {
    name   = "owner-id"
    values = ["602636675831"]
  }

  filter {
    name   = "name"
    values = ["beevalabs-poc-nomad-nomadclient-0.6.3-*"]
  }
}
