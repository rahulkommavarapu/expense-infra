variable "project_name" {
    default = "expense"
}

variable "environment" {
    default = "dev"
}

variable "common_tags" {
    default = {
        Project = "expense"
        Environment = "dev"
        Terraform = "true"
    }
}

variable "domain_name" {
    default = "practice25.online"
}

variable "zone_id" {
    default = "Z001854036XQKN6X4S0CB"
}