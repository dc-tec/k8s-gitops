variable "static_ip" {
  description = "The static IP address for the instance"
  type        = string
}

variable "gateway" {
  description = "The gateway for the instance"
  type        = string
}

variable "talos_image" {
  description = "The Talos image to use for the instance"
  type        = string
}
