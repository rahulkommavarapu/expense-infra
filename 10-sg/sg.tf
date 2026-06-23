
module "mysql_sg" {
  source         = "git::https://github.com/rahulkommavarapu/terraform-aws-securitygroup.git?ref=main"
  project_name   = var.project_name
  environment    = var.environment
  sg_name        = "mysql"
  sg_description = "Created for mysql instances expense dev"
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
  common_tags    = var.common_tags
  sg_tags        = var.sg_tags
}

module "backend_sg" {
  source         = "git::https://github.com/rahulkommavarapu/terraform-aws-securitygroup.git?ref=main"
  project_name   = var.project_name
  environment    = var.environment
  sg_name        = "backend"
  sg_description = "Created for backend instances expense dev"
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
  common_tags    = var.common_tags
  sg_tags        = var.sg_tags
}

module "frontend_sg" {
  source         = "git::https://github.com/rahulkommavarapu/terraform-aws-securitygroup.git?ref=main"
  project_name   = var.project_name
  environment    = var.environment
  sg_name        = "frontend"
  sg_description = "Created for frontend instances expense dev"
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
  common_tags    = var.common_tags
  sg_tags        = var.sg_tags

}

# Security Group for Bastion Purpose 
module "bastion_sg" {
  source         = "git::https://github.com/rahulkommavarapu/terraform-aws-securitygroup.git?ref=main"
  project_name   = var.project_name
  environment    = var.environment
  sg_name        = "bastion"
  sg_description = "Created for bastion instances expense dev"
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
  common_tags    = var.common_tags
  sg_tags        = var.sg_tags

}
# Create Security Group for Application Load Balancer 
module "app_alb_sg" {
  source         = "git::https://github.com/rahulkommavarapu/terraform-aws-securitygroup.git?ref=main"
  project_name   = var.project_name
  environment    = var.environment
  sg_name        = "app-alb"
  sg_description = "Created for backend ALB for instances expense dev"
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
  common_tags    = var.common_tags
  sg_tags        = var.sg_tags

}

module "alb_ingress_sg" {
    source = "git::https://github.com/rahulkommavarapu/terraform-aws-securitygroup.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "app-alb"
    sg_description = "Created for backend ALB in expense dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
    sg_tags = var.sg_tags
}

module "eks_control_plane_sg" {
    source = "git::https://github.com/rahulkommavarapu/terraform-aws-securitygroup.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "eks-control-plane"
    sg_description = "Created for backend ALB in expense dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
    sg_tags = var.sg_tags
}


module "eks_node_sg" {
    source = "git::https://github.com/rahulkommavarapu/terraform-aws-securitygroup.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "eks-node"
    sg_description = "Created for backend ALB in expense dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
     sg_tags = var.sg_tags
}

# terraform aws security group rule,  Application Load Balancer accepting Traffic from bastion Host IP
resource "aws_security_group_rule" "app-alb-bastion" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.bastion_sg.sg_id # string ,Lst []
  security_group_id        = module.app_alb_sg.sg_id # Accepting the Traffic from Bastion Host IP
}
# Give the Permission to Access the Bastion Pubic Server
resource "aws_security_group_rule" "bastion_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # Dynamic Ip Address
  security_group_id = module.bastion_sg.sg_id
}

# Create the Security Group for VPN
# Manage The Ports for VPV 22,443 ,1194,943
module "vpn_sg" {
  source         = "git::https://github.com/rahulkommavarapu/terraform-aws-securitygroup.git?ref=main"
  project_name   = var.project_name
  environment    = var.environment
  sg_name        = "vpn"
  sg_description = "Created for VPN instances expense dev"
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
  common_tags    = var.common_tags
  sg_tags        = var.sg_tags

}



# GIVE THE Port Number 22 fOR Server Logging and Checking 
resource "aws_security_group_rule" "vpn_ssh" {
  type      = "ingress"
  from_port = 22
  to_port   = 22
  protocol  = "tcp"
  # Useually It Should be Static IP
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn_sg.sg_id
}

# GIVE THE Port Number 443 fOR Browsing Purpose 
resource "aws_security_group_rule" "vpn_443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn_sg.sg_id
}

# GIVE THE Port Number 943 fOR Internal Checking Purpose
resource "aws_security_group_rule" "vpn_943" {
  type              = "ingress"
  from_port         = 943
  to_port           = 943
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn_sg.sg_id
}
# GIVE THE Port Number 1194 fOR Internal Checking Purpose
resource "aws_security_group_rule" "vpn_1194" {
  type              = "ingress"
  from_port         = 1194
  to_port           = 1194
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn_sg.sg_id
}

# # Create the Security Group for RDS  ,Mysql Accepting the Traffic From Bastion Host
resource "aws_security_group_rule" "mysql_bastion" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id        = module.mysql_sg.sg_id
}
# Create the Security Group for, Mysql Accepting the Traffic from VPN as well
resource "aws_security_group_rule" "mysql_vpn" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.vpn_sg.sg_id
  security_group_id        = module.mysql_sg.sg_id

}
# Create the Secuity Group for Backend in VPN 
resource "aws_security_group_rule" "backend_vpn" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22    # here the Take the Ssh access from Port no 22
  protocol          = "tcp"
  source_security_group_id = module.vpn_sg.sg_id
  security_group_id = module.backend_sg.sg_id
}
# Create the Security Group for  backend with mysql in VPN
resource "aws_security_group_rule" "mysql_backend" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306   # here the Take the mysql access from Port no 3306
  protocol          = "tcp"
  source_security_group_id = module.backend_sg.sg_id # Source
  security_group_id = module.mysql_sg.sg_id  # Destination Source mysql
}