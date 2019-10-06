output "ImageName" {
  value = docker_image.jenkins_image.name
}
output "NetworkName" {
  value = docker_network.jenkins_network.name
}
output "NetworkDriver" {
  value = docker_network.jenkins_network.driver
}
output "ContainerName" {
  value = docker_service.jenkins_service.name
}

