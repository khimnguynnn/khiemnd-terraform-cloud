resource "aws_vpc" "main" {
  cidr_block = var.cidr_block

  tags = merge(var.tags, {
    Name = "${var.tags["Environment"]}-${var.tags["Project"]}-vpc"
  })
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.tags["Environment"]}-${var.tags["Project"]}-public-subnet-${count.index + 1}"
  })
  depends_on = [aws_vpc.main]
}

resource "aws_subnet" "private" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "${var.tags["Environment"]}-${var.tags["Project"]}-public-subnet-${count.index + 1}"
  })
  depends_on = [aws_vpc.main]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public.id
  }

  tags = merge(var.tags, {
    Name = "${var.tags["Environment"]}-${var.tags["Project"]}-public-rt"
  })
  depends_on = [aws_vpc.main]
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw[count.index].id
  }

  tags = merge(var.tags, {
    Name = "${var.tags["Environment"]}-${var.tags["Project"]}-private-rt"
  })
  depends_on = [aws_vpc.main, aws_nat_gateway.nat_gw]
}

resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.tags["Environment"]}-${var.tags["Project"]}-igw"
  })
  depends_on = [aws_vpc.main]
}

resource "aws_eip" "nat_eip" {
  count      = length(var.public_subnet_cidrs)
  depends_on = [aws_internet_gateway.public]
  
}

resource "aws_nat_gateway" "nat_gw" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(var.tags, {
    Name = "${var.tags["Environment"]}-${var.tags["Project"]}-nat-gw-${count.index + 1}"
  })
  depends_on = [aws_internet_gateway.public, aws_eip.nat_eip]
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

