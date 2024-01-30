terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "5.31.0"
        }
    }
    required_version = ">= 1.2.0"
}

provider "aws" {
    region  = "us-east-1"
    default_tags {
        Projeto = "exemplo_terraform"
    }
}

#Criação da Virtual Private Cloud - VPC
resource "aws_vpc" "exemplo_VPC" {
    cidr_block              = "100.64.0.0/20"
    enable_dns_hostnames    = true

    tags = var.tags_vpc
}

#criação subnet publica
resource "aws_subnet" "ex_subnet_pub" {
    vpc_id                      = aws_vpc.vpc_terraform2.id
    cidr_block                  = "100.64.0.0/24"
    availability_zone           = "us-east-1b"
    map_public_ip_on_launch     = true

    tags = var.tags_subnet
}

#criação subnet privada
resource "aws_subnet" "ex_subnet_priv" {
    vpc_id                      = aws_vpc.exemplo_VPC.id
    cidr_block                  = "100.64.1.0/24"
    availability_zone           = "us-east-1b"
    map_public_ip_on_launch     = true

    tags = var.tags_subnet
}

#Criação Gateway | aponte para vpc
resource "aws_internet_gateway" "exemplo_gateway" {
    vpc_id  = aws_vpc.exemplo_VPC.id

    tags    = var.tags_IGTW
}

#Criando Rota para internet, utilizando gateway
resource "aws_route_table" "exemplo_rtb_pub" {
    vpc_id   = aws_vpc.exemplo_VPC.id
    tags     = {
        Name = var.exemplo_rtb_pub
    }
}

#Rotas privadas
resource "aws_route_table" "exemplo_rtb_priv" {
    vpc_id    = aws_vpc.exemplo_VPC.id
    tags      = {
        Name  = var.exemplo_rtb_priv
    }
}

#Adicionando uma rota para a Internet
resource "aws_route" "exemplo_rota" {
  route_table_id = aws_route_table.exemplo_rtb_pub.id
  destination_cidr_block = "0.0.0.0/0"  # Rota para a Internet
  gateway_id = aws_internet_gateway.exemplo_gateway.id
}

#Associando subnet publica para uma rota WAN
resource "aws_route_table_association" "relacionando subnet" {
    subnet_id       = aws_subnet.ex_subnet_pub.id
    route_table_id  =  aws_route_table.exemplo_rtb_pub.id
}

#Criando Security Group
resource "aws_security_group" "exemplo_SG" {
    name        = var.nome_sg
    description = "SG usado pela aplicação X, bloqueia acessos Y"
    vpc_id      = exemplo_VPC

    tags = var.tags_sg

    #Regras de Entrada para o Security Group
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["X.X.X.X/X"]  #MUDAR ESSE PARAMETRO PARA UM IP CONFIAVEL TER ACESSO SSH NA MAQUINA
  }

  #Regras de Saída para o Security group
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
}

# Criando uma Network ACL (ACL de Rede)
resource "aws_network_acl" "exemplo_ACL" {
  vpc_id = aws_vpc.exemplo_VPC.id
  ingress {
    rule_no   = 10
    action        = "allow"
    cidr_block    = "0.0.0.0/0"   #liberando todo trafego na ACL, usar segurança do SG
    protocol      = "-1"      # "-1" aponta para todos os protocolos
    from_port     = 0
    to_port       = 0
  }
  egress {
    rule_no   = 20
    action        = "allow"
    cidr_block    = "0.0.0.0/0"   #liberando todo trafego na ACL, usar segurança do SG
    protocol      = "-1"      # "-1" aponta para todos os protocolos
    from_port     = 0       # porta 0 - 0 para permitir o protocolo -1 acima (liberando toda saida) 
    to_port       = 0
  }
}

resource "aws_instance" "instanciaEC2_exemplo" {
    instance_type = "t2.micro"
    ami                     = var.ami_ubuntu
    subnet_id               = aws_subnet.ex_subnet_pub.id
    key_name                = "chave_linux_temporária"

    vpc_security_group_ids  = [aws_security_group.exemplo_SG.id]

    tags = var.tags_instance
}

resource "local_file" "create_hosts_yml" {
  content = <<-DOC
 all:
  hosts:
    servidor_terraform:
      ansible_host: ${aws_instance.instanciaEC2_exemplo.public_ip}
  DOC
  filename = "${path.module}/ansible/hosts.yml"
} 
