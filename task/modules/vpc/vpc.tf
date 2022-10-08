locals {
  public_subnets  = toset(sort(var.public_subnets))
  private_subnets = toset(sort(var.private_subnets))
  azs             = sort([for az in data.aws_availability_zones.current.names : az])
}

data "aws_region" "current" {}

data "aws_availability_zones" "current" {
  state = "available"
}

# our vpc
resource "aws_vpc" "self" {
  cidr_block = var.cidr

  tags = {
    role   = "vpc"
    region = data.aws_region.current.name
    name   = "devops-tech-task"
  }
}

# our public subnets
resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.self.id
  cidr_block              = each.key
  availability_zone       = local.azs[index(tolist(sort(local.public_subnets)), each.key)]
  map_public_ip_on_launch = true

  tags = {
    role   = "vpc"
    region = data.aws_region.current.name
    zone   = local.azs[index(tolist(sort(local.public_subnets)), each.key)]
    name   = "devops-tech-task"
  }
}

# our private subnets
resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id                  = aws_vpc.self.id
  cidr_block              = each.key
  availability_zone       = local.azs[index(tolist(sort(local.private_subnets)), each.key)]
  map_public_ip_on_launch = false

  tags = {
    role   = "vpc"
    region = data.aws_region.current.name
    zone   = local.azs[index(tolist(sort(local.private_subnets)), each.key)]
    name   = "devops-tech-task"
  }
}

# our public routes & gateway
resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.self.id

  tags = {
    role   = "vpc"
    region = data.aws_region.current.name
    name   = "devops-tech-task"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.self.id

  tags = {
    role   = "vpc"
    region = data.aws_region.current.name
    name   = "devops-tech-task"
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.public.id

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "public" {
  for_each = local.public_subnets

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

# our private routes and gateway
resource "aws_eip" "private" {
  for_each = local.private_subnets

  vpc = true

  tags = {
    role   = "vpc"
    region = data.aws_region.current.name
    zone   = local.azs[index(tolist(sort(local.private_subnets)), each.key)]
    name   = "devops-tech-task"
  }
}

resource "aws_nat_gateway" "private" {
  for_each = local.private_subnets

  allocation_id = aws_eip.private[each.key].id
  subnet_id     = aws_subnet.private[each.key].id

  tags = {
    role   = "vpc"
    region = data.aws_region.current.name
    zone   = local.azs[index(tolist(sort(local.private_subnets)), each.key)]
    name   = "devops-tech-task"
  }

  depends_on = [aws_internet_gateway.public]
}

resource "aws_route_table" "private" {
  for_each = local.private_subnets

  vpc_id = aws_vpc.self.id

  tags = {
    role   = "vpc"
    region = data.aws_region.current.name
    zone   = local.azs[index(tolist(sort(local.private_subnets)), each.key)]
    name   = "devops-tech-task"
  }
}

resource "aws_route" "private" {
  for_each = local.private_subnets

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.private[each.key].id

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "private" {
  for_each = local.private_subnets

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}
