provider "aws" {
  region = "eu-west-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "pocvpc" {
  cidr_block       = var.vpcCIDR
  instance_tenancy = "default"
  tags             = merge({ Name = "POC" })
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.pocvpc.id
  tags   = merge({ Name = "POC" })
}
resource "aws_subnet" "publicSN1" {
  vpc_id                  = aws_vpc.pocvpc.id
  cidr_block              = var.publicSubnet1CIDR
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags                    = merge({ Name = "POC" })
}
resource "aws_subnet" "publicSN2" {
  vpc_id                  = aws_vpc.pocvpc.id
  cidr_block              = var.publicSubnet2CIDR
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags                    = merge({ Name = "POC" })
}
resource "aws_subnet" "privateSN1" {
  vpc_id                  = aws_vpc.pocvpc.id
  cidr_block              = var.privateSubnet1CIDR
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
  tags                    = merge({ Name = "POC" })
}
resource "aws_subnet" "privateSN2" {
  vpc_id                  = aws_vpc.pocvpc.id
  cidr_block              = var.privateSubnet2CIDR
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false
  tags                    = merge({ Name = "POC" })
}
resource "aws_security_group" "publicSecurityGroup" {
  name   = "POC_PublicSecurityGroup"
  vpc_id = aws_vpc.pocvpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.public_securitygroup_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge({ Name = "POC" })
}
resource "aws_security_group" "privateSecurityGroup" {
  name   = "POC_PrivateSecurityGroup"
  vpc_id = aws_vpc.pocvpc.id

  ingress = [{
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.pocvpc.cidr_block]
    ipv6_cidr_blocks = null
    prefix_list_ids  = null
    security_groups  = null
    self             = null
    },
    {
      description      = "HTTP from VPC"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = [aws_vpc.pocvpc.cidr_block]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
  }]
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge({ Name = "POC" })
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

resource "aws_route_table" "privateRouteTable" {
  vpc_id = aws_vpc.pocvpc.id


  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.terraformNatGateway.id
  }
  tags = merge({ Name = "POC" })
}
resource "aws_route_table_association" "privateSN1RouteRable" {
  subnet_id      = aws_subnet.privateSN1.id
  route_table_id = aws_route_table.privateRouteTable.id
}
resource "aws_route_table_association" "privateSN2RouteRable" {
  subnet_id      = aws_subnet.privateSN2.id
  route_table_id = aws_route_table.privateRouteTable.id
}

resource "aws_eip" "terraformNatEIP" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
  tags       = merge({ Name = "POC" })
}

resource "aws_nat_gateway" "terraformNatGateway" {
  allocation_id = aws_eip.terraformNatEIP.id
  subnet_id     = aws_subnet.publicSN1.id
  tags          = merge({ Name = "POC" })
}

/*resource "aws_flow_log" "flowLogs" {
  iam_role_arn    = "${aws_iam_role.flowLogRule.arn}"
  log_destination = "${aws_cloudwatch_log_group.flowLogGroup.arn}"
  traffic_type    = "ALL"
  vpc_id          = "${aws_vpc.pocvpc.id}"
}


resource "aws_cloudwatch_log_group" "flowLogGroup" {
  name = "flowLogGroup"
}

resource "aws_iam_role" "flowLogRule" {
  name = "vpc-flow-log-rule"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "flowLogPolicy" {
  name = "flow-log-policy"
  role = "${aws_iam_role.flowLogRule.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}
*/
