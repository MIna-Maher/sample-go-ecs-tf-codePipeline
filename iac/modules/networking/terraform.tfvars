
# VPC
vpcCIDR            = "10.50.0.0/16"
publicSubnet1CIDR  = "10.50.1.0/24"
publicSubnet2CIDR  = "10.50.2.0/24"
privateSubnet1CIDR = "10.50.10.0/24"
privateSubnet2CIDR = "10.50.20.0/24"
# public security group but its not used ,all other resources that needs security group creates another one with with a different ingress cidr range
public_securitygroup_cidr = "0.0.0.0/0"
