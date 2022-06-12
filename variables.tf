variable "region" {
  description = "Your region"
  type        = string
  default     = "eu-west-3"
}

variable "instance_type" {
  description = "your instance type"
  type        = string
  default     = "t2.micro"
}


variable "allow_ports" {
  description = "Your open ports"
  type        = list(any)
  default     = ["80", "443", "22", "8089", "8081", "8082", "8083", "8084"]
}

variable "common_tags" {
  description = "Your common tags"
  type        = map(any)
  default = {
    Owner = "Artem Shubin"
    Env   = "Dev"
  }
}
