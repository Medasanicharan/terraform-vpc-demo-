# create VPC ##

resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = "expense-project"
  }
}

## IGW ##

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "expense-project-igw"
  }
}

## public subnet ##

# resource "aws_subnet" "public_subnet_1a" {
#   count = 1
#   vpc_id     = aws_vpc.main.id
#   cidr_block = "10.0.1.0/24"
#   availability_zone = "us-east-1a"

#   tags = {
#     Name = "public-subet-us-east-1a"
#   }
# }

# resource "aws_subnet" "public_subnet_1b" {
#   count = 1
#   vpc_id     = aws_vpc.main.id
#   cidr_block = "10.0.11.0/24"
#   availability_zone = "us-east-1b"

#   tags = {
#     Name = "public-subet-us-east-1b"
#   }
# }

resource "aws_subnet" "public_subnet_cidrs" {
  count = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.common_tags,
    {
    Name = "${var.project_name}-${var.environment}-public-${data.aws_availability_zones.available.names[count.index]}"
  }
  )
}

## private subnet ##

resource "aws_subnet" "private_subnet_cidrs" {
  count = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  map_public_ip_on_launch = "true"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge (
    var.common_tags,
    {
    Name = "${var.project_name}-${var.environment}-private-${data.aws_availability_zones.available.names[count.index]}"
  }
  )
}

## database subnet ##

resource "aws_subnet" "database_subnet_cidrs" {
  count = length(var.database_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.common_tags,
    {
    Name = "${var.project_name}-${var.environment}-database-${data.aws_availability_zones.available.names[count.index]}"
  }
  )
}

 ## public route table ##

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
    Name = "Public-route-table"
  }
  )
}

 ## private route table ##

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
    Name = "Private-route-table"
  }
  )
}

 ## database route table ##

resource "aws_route_table" "database_route_table" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
    Name = "database-route-table"
  }
  )
}


## database subnet groups ##

# resource "aws_db_subnet_group" "default" {
#   name       = "expense-dev-project"
#   subnet_ids = aws_route_table.database_route_table[*].id

#   tags = {
#     Name = "DB-subnet-group"
#   }
# }


## elastic ip ##

resource "aws_eip" "nat" {
  domain   = "vpc"
}


## nat gateway ##

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet_cidrs[0].id

  tags = merge(
    var.common_tags,
    {
    Name = "expense-nat-gateway"
  }
  )

  depends_on = [aws_internet_gateway.gw]
}


resource "aws_route" "public_route" {
  route_table_id            = aws_route_table.public_route_table.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}

resource "aws_route" "private_route" {
  route_table_id            = aws_route_table.private_route_table.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gateway.id
}

resource "aws_route" "database_route" {
  route_table_id            = aws_route_table.database_route_table.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gateway.id
}


resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id  = element(aws_subnet.public_subnet_cidrs[*].id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id  = element(aws_subnet.private_subnet_cidrs[*].id, count.index)
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id  = element(aws_subnet.database_subnet_cidrs[*].id, count.index)
  route_table_id = aws_route_table.database_route_table.id
}




