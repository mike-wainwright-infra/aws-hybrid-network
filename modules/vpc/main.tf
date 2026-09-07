# 1. The Core Enterprise Network Border
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_name
  }
}

# 2. The Edge Public Subnet (For Ingress/Egress Hub points)
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "${var.vpc_name}-public-sn"
  }
}

# 3. The Isolated Private Subnet (For high-security application/DB nodes)
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "${var.vpc_name}-private-sn"
  }
}

# 4. The Dedicated Transit Gateway Plug Subnet (Tiny /28 slice)
resource "aws_subnet" "tgw" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.tgw_subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "${var.vpc_name}-tgw-sn"
  }
}

# 5. The Edge Internet Doorway (Conditional: Built ONLY if enabled)
resource "aws_internet_gateway" "this" {
  count  = var.enable_internet_gateway ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}