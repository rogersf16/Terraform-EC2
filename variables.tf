variable "ami_ubuntu" {
  type        = string 
  description = "AMI do O.S ubuntu"
}

variable ami_redhat {
  type        = string
  description = "AMI do O.S Red Hat"
}

variable tags_vpc {
    type   = object({
        Name = string
    })
    description = "tags da vpc"
}

variable tags_instance {
    type = object({
        Name = string
    })
    description = "tags da instancia"
}

variable tags_subnet_pub {
    type = object({
        Name = string
    })
    description = "tags da subnet"
}

variable tags_subnet_priv {
    type = object({
        Name = string
    })
    description = "tags da subnet"
}

variable tags_IGTW {
    type = object({
        Name = string
    })
    description = "tags do internet gateway"
}

variable tags_rtb_pub {
type = object({
    Name - string
})
description - "tags da router table publica"
}

variable "tags_rtb_priv" {
    type = object({
        Name = string
    })
description = "tags da router table privada"
}

variable "tags_sg" {
    type = object({
        Name = string
    })
description = "Tag do security group"
}

variable "nome_sg" {
  type        = string 
  description = "Nome do Security group criado"
}

