#This is the main script used by the project

resource "docker_service" "jenkins_service" {
  name = var.project_name
  task_spec {
    container_spec {
      image = docker_image.jenkins_image.name
      mounts {
        source = var.jenkins_volume
        target = "/var/jenkins_home"
        type   = "bind"
      }
      mounts {
        source = "/var/run/docker.sock"
        target = "/var/run/docker.sock"
        type   = "bind"
      }
    }
    networks = ["${docker_network.jenkins_network.name}"]
  }

  endpoint_spec {
    ports {
      target_port    = "8080"
      published_port = var.web_interface_port
      publish_mode   = "ingress"
      name           = "WEB_INTERFACE"
    }
    ports {
      target_port    = "50000"
      published_port = var.api_interface_port
      publish_mode   = "ingress"
      name           = "API_INTERFACE"
    }
  }
}
