job "hashiui" {
  datacenters = ["dc1"]
  type        = "service"

  group "hashiui" {
    count = 1

    task "hashiui" {
      driver = "docker"

      config {
        image   = "jippi/hashi-ui:v0.22.0"
        command = "/hashi-ui"

        args = [
          "--consul-enable",
          "--consul-address",
          "consul.service.consul:8500",
          "--nomad-enable",
          "--nomad-address",
          "http://nomad.service.consul:4646",
        ]

        port_map {
          p = 3000
        }

        dns_servers = ["172.17.0.1"]
      }

      resources {
        cpu    = 500
        memory = 256

        network {
          mbits = 1

          port "p" {}
        }
      }

      service {
        name = "hashiui"
        port = "p"
        tags = ["http"]

        check {
          name     = "alive"
          type     = "http"
          path     = "/_status"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
