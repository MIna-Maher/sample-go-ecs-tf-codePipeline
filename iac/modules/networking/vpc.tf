data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "pocvpc" {
  cidr_block       = var.vpcCIDR
  instance_tenancy = "default"
  tags             = merge({ Name = "vpc_test" })
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.pocvpc.id
  tags   = merge({ Name = "igw_test" })
}
resource "aws_subnet" "publicSN1" {
  vpc_id                  = aws_vpc.pocvpc.id
  cidr_block              = var.publicSubnet1CIDR
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags                    = merge({ Name = "publicsubnet1" })
}
resource "aws_subnet" "publicSN2" {
  vpc_id                  = aws_vpc.pocvpc.id
  cidr_block              = var.publicSubnet2CIDR
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags                    = merge({ Name = "publicsubnet2" })
}
resource "aws_subnet" "privateSN1" {
  vpc_id                  = aws_vpc.pocvpc.id
  cidr_block              = var.privateSubnet1CIDR
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
  tags                    = merge({ Name = "privatesubnet1" })
}
resource "aws_subnet" "privateSN2" {
  vpc_id                  = aws_vpc.pocvpc.id
  cidr_block              = var.privateSubnet2CIDR
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false
  tags                    = merge({ Name = "privatesubnet2" })
}

resource "aws_route_table" "publicRouteTable" {
  vpc_id = aws_vpc.pocvpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge({ Name = "POC" })
}
resource "aws_route_table_association" "publicSN1RouteRable" {
  subnet_id      = aws_subnet.publicSN1.id
  route_table_id = aws_route_table.publicRouteTable.id
}
resource "aws_route_table_association" "publicSN2RouteRable" {
  subnet_id      = aws_subnet.publicSN2.id
  route_table_id = aws_route_table.publicRouteTable.id
}

resource "aws_route_table" "privateRouteTable1" {
  vpc_id = aws_vpc.pocvpc.id


  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.terraformNatGateway.id
  }
  tags = merge({ Name = "privateroutetable1" })
}
resource "aws_route_table" "privateRouteTable2" {
  vpc_id = aws_vpc.pocvpc.id


  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.terraformNatGateway2.id
  }
  tags = merge({ Name = "privateroutetable1" })
}
resource "aws_route_table_association" "privateSN1RouteRable" {
  subnet_id      = aws_subnet.privateSN1.id
  route_table_id = aws_route_table.privateRouteTable1.id
}
resource "aws_route_table_association" "privateSN2RouteRable" {
  subnet_id      = aws_subnet.privateSN2.id
  route_table_id = aws_route_table.privateRouteTable2.id
}

resource "aws_eip" "terraformNatEIP" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
  tags       = merge({ Name = "nateip1" })
}

resource "aws_nat_gateway" "terraformNatGateway" {
  allocation_id = aws_eip.terraformNatEIP.id
  subnet_id     = aws_subnet.publicSN1.id
  tags          = merge({ Name = "natgw1" })
}

resource "aws_eip" "terraformNatEIP2" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
  tags       = merge({ Name = "nateip2" })
}

resource "aws_nat_gateway" "terraformNatGateway2" {
  allocation_id = aws_eip.terraformNatEIP2.id
  subnet_id     = aws_subnet.publicSN1.id
  tags          = merge({ Name = "natgw2" })
}
