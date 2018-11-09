variable "identifier" {
  default     = "concordia"
  description = "Identifier for your DB"
}

variable "storage" {
  default     = "20"
  description = "Storage size in GB"
}

variable "engine" {
  default     = "mysql"
  description = "Engine type, example values mysql, postgres"
}

variable "engine_version" {
  type = "map"
  description = "Engine version"

  default = {
    mysql    = "5.7.21"
    postgres = "9.6.8"
  }
}

variable "instance_class" {
  default     = "db.t2.micro"
  description = "Instance class"
}

variable "db_name" {
  default     = "concordia"
  description = "db name"
}

variable "username" {
  default     = "sa"
  description = "User name"
}

variable "password" {
  description = "password, provide through your ENV variables"
}

variable "vpc_security_group_ids"{
  description = "Vpc security_group_ids"
}

variable "final_snapshot_identifier"{
  default = "concordia_final_snapshot"
  description = "Provide a name for the final_snapshot when database is deleted"
}

variable "multi_az"{
  default = "false"
  description = "Install the database with multiAZ option for automatic failover"
}
