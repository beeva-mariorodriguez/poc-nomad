job "vaultclient" {
  datacenters = ["dc1"]
  type        = "service"

  update {
    max_parallel     = 1
    min_healthy_time = "10s"
    healthy_deadline = "3m"
    auto_revert      = false
    canary           = 1
    stagger          = "30s"
  }

  group "client" {
    count = 2

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "hellohttp" {
      driver = "docker"

      config {
        image = "docker.io/vault:0.9.0"
        command = "/bin/ping"
        args = ["172.17.0.1"]
        dns_servers = ["172.17.0.1"]
      }

      vault {
        policies = ["vaultclient"]
        change_mode = "signal"
        change_signal = "SIGUSR1"
      }

      env {
        VAULT_ADDR = "http://vault.service.consul:8200"
      }

      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB
      }
    }
  }
}
