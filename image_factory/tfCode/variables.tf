variable "project_name" {
  description = "Name of the project"
  type        = string
}
variable "image_name" {
  description = "Docker Image Name To Be Used along with the image tag (e.g., jenkins:latest)"
  type        = string
}
variable "web_interface_port" {
  description = "HTTP Port used by Jenkins Container"
  type        = number
}
variable "api_interface_port" {
  description = "API Interface Port used by Jenkins Container"
  type        = number
}
variable "jenkins_volume" {
  description = "Jenkins Home Bind Location"
  type        = string
}
