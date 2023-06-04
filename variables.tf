variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}

variable "db_port" {
  description = "The port the db uses"
  type        = number
  default     = 3306
}

variable "alb_name" {
  description = "The name of the ALB"
  type        = string
  default     = "terraform-asg-example"
}

variable "instance_security_group_name" {
  description = "The name of the security group for the EC2 Instances"
  type        = string
  default     = "terraform-example-instance"
}

variable "alb_security_group_name" {
  description = "The name of the security group for the ALB"
  type        = string
  default     = "terraform-example-alb"
}

variable "database_name" {
  description = "database_name"
  type        = string
  sensitive   = true
}

variable "database_user" {
  description = "database_user"
  type        = string
  sensitive   = true
}

variable "database_password" {
  description = "database_password"
  type        = string
  sensitive   = true
}