resource "docker_network" "jenkins_network" {
  name   = "${var.project_name}_external"
  driver = "overlay"
}
