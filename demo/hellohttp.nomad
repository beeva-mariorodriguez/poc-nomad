job "hellohttp" {
    datacenters = ["dc1"]
        type = "service"
        update {
            max_parallel = 1
                min_healthy_time = "10s"
                healthy_deadline = "3m"
                auto_revert = true
                canary = 1
        }
    group "hello" {
        count = 4
            restart {
                attempts = 10
                    interval = "5m"
                    delay = "25s"
                    mode = "delay"
            }
        task "hellohttp" {
            driver = "docker"
                config {
                    image = "beevamariorodriguez/hellohttp:alpine"
                        port_map {
                            h = 8080
                        }
                }

            resources {
                cpu    = 500 # 500 MHz
                    memory = 256 # 256MB
                    network {
                        port "h" {}
                    }
            }
            service {
                name = "hellohttp"
                port = "h"
                tags = ["http","urlprefix-/hello strip=/hello"]
                check {
                    name = "alive"
                    type = "http"
                    path = "/health"
                    interval = "10s"
                    timeout = "2s"
                }
            }
        }
    }
}
