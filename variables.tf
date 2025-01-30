variable project_name {
    type = string
    default = "expense-project"
}

variable environment {
    type = string
    default = "dev"
}


variable  public_subnet_cidrs {
   type        = list
   default = ["10.0.1.0/24", "10.0.11.0/24"]

#    validation {
#     condition     = length(var.public_subnet_cidrs) == 2
#     error_message = "please provide the two valid public subnet CIDR"
#   }
 }

variable  private_subnet_cidrs {
   type        = list
   default = ["10.0.12.0/24", "10.0.21.0/24"]
}

variable  database_subnet_cidrs {
   type        = list
   default = ["10.0.13.0/24", "10.0.22.0/24"]
}

variable common_tags {
    type = map
    default = {
        Project = "expense" 
        Terraform = "true"
    }
}

variable vpc_cidr {
    type = string
    default = "10.0.0.0/16"
}

## peering ##

variable is_peering_required {
    type = bool
    default = true
}

variable acceptor_vpc {
    type = string
    default = ""
}