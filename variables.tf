#Account
variable "region" {
  type = string
  default = "us-east-2"
}

# Network Variables
variable "vpc_cidr_block" {
  type = string
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  type = string
  default = "my_vpc"
}

variable "subnet_cidr_block" {
  type = string
  default = "10.0.1.0/24"
}

variable "public_subnet_cidr_block" {
  type = string
  default = "10.0.2.0/24"
}

variable "db_subnet1_cidr_block" {
  type = string
  default = "10.0.11.0/24"
}

variable "db_subnet2_cidr_block" {
  type = string
  default = "10.0.12.0/24"

}


variable "subnet_name" {
  type = string
  default = "web-subnet-a"
}

variable "sg_name" {
  type = string
  default = "web-security-group"
}

variable "sg_description" {
  type = string
  default = "security group for the web instences"
}

# Compute Variables

variable "aws_ami_value" {
  type = string
  default = "al2023-ami-2023.*-x86_64"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "instance_name" {
  type = string
  default = "web-instance"
}

variable "key_name" {
  type = string
  default = "web_key"
}

#RDS Database

variable "port" {
  type = number
  default = 3306
}

variable "allocated_storage" {
  type = number
  default = 20
}

variable "engine" {
  type = string
  default = "mysql"
}

variable "engine_version" {
  type = number
  default = "5.7"
}

variable "instance_class" {
  type = string
  default = "db.t3.micro"
}

variable "db_name" {
  type = string
  default = "apache2_db"
}

variable "username" {
  type = string
  default = "admin"
}

variable "storage_encrypted" {
  type = string
  default = "true"
}

variable "storage_type" {
  type = string
  default = "gp2"
}