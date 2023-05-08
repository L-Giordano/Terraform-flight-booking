variable "fbooking-cluster-name" {
    type = string
}
variable "task-definition-family" {
    type = string
}
variable "task-definition-cpu" {
    type = number
}
variable "task-definition-memory" {
    type = number
}
variable "task-definition-memory" {
    type = number
}
variable "enviroment_container_definitions" {
    type = list(map(string))
}
variable "container_definitions_image" {
    type = string
}
variable ""container_definitions_name"" {
  
}