# VPC
resource "aws_vpc" "two-tier-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "two-tier-vpc"
  }
}

# Public Subnets 
resource "aws_subnet" "two-tier-pub-sub-1" {
  vpc_id            = aws_vpc.two-tier-vpc.id
  cidr_block        = "10.0.0.0/18"
  availability_zone = "us-east-1"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "two-tier-pub-sub-1"
  }
}

resource "aws_subnet" "two-tier-pub-sub-2" {
  vpc_id            = aws_vpc.two-tier-vpc.id
  cidr_block        = "10.0.64.0/18"
  availability_zone = "us-east-1"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "two-tier-pub-sub-2"
  }
}

# Private Subnets
resource "aws_subnet" "two-tier-pvt-sub-1" {
  vpc_id                  = aws_vpc.two-tier-vpc.id
  cidr_block              = "10.0.128.0/18"
  availability_zone       = "us-east-1"
  map_public_ip_on_launch = false
  tags = {
    Name = "two-tier-pvt-sub-1"
  }
}
resource "aws_subnet" "two-tier-pvt-sub-2" {
  vpc_id                  = aws_vpc.two-tier-vpc.id
  cidr_block              = "10.0.192.0/18"
  availability_zone       = "us-east-1"
  map_public_ip_on_launch = false
  tags = {
    Name = "two-tier-pvt-sub-2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "two-tier-igw" {
  tags = {
    Name = "two-tier-igw"
  }
  vpc_id = aws_vpc.two-tier-vpc.id
}

# Route Table
resource "aws_route_table" "two-tier-rt" {
  tags = {
    Name = "two-tier-rt"
  }
  vpc_id = aws_vpc.two-tier-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.two-tier-igw.id
  }
}

# Route Table Association
resource "aws_route_table_association" "two-tier-rt-as-1" {
  subnet_id      = aws_subnet.two-tier-pub-sub-1.id
  route_table_id = aws_route_table.two-tier-rt.id
}

resource "aws_route_table_association" "two-tier-rt-as-2" {
  subnet_id      = aws_subnet.two-tier-pub-sub-2.id
  route_table_id = aws_route_table.two-tier-rt.id
}

# Create Load balancer
resource "aws_lb" "two-tier-lb" {
  name               = "two-tier-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.two-tier-alb-sg.id]
  subnets            = [aws_subnet.two-tier-pub-sub-1.id, aws_subnet.two-tier-pub-sub-2.id]

  tags = {
    Environment = "two-tier-lb"
  }
}

resource "aws_lb_target_group" "two-tier-lb-tg" {
  name     = "two-tier-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.two-tier-vpc.id
}

# Create Load Balancer listener
resource "aws_lb_listener" "two-tier-lb-listner" {
  load_balancer_arn = aws_lb.two-tier-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.two-tier-lb-tg.arn
  }
}

# Create Target group
resource "aws_lb_target_group" "two-tier-loadb_target" {
  name       = "target"
  depends_on = [aws_vpc.two-tier-vpc]
  port       = "80"
  protocol   = "HTTP"
  vpc_id     = aws_vpc.two-tier-vpc.id
  
}

resource "aws_lb_target_group_attachment" "two-tier-tg-attch-1" {
  target_group_arn = aws_lb_target_group.two-tier-loadb_target.arn
  target_id        = aws_instance.two-tier-web-server-1.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "two-tier-tg-attch-2" {
  target_group_arn = aws_lb_target_group.two-tier-loadb_target.arn
  target_id        = aws_instance.two-tier-web-server-2.id
  port             = 80
}

# Subnet group database
resource "aws_db_subnet_group" "two-tier-db-sub" {
  name       = "two-tier-db-sub"
  subnet_ids = [aws_subnet.two-tier-pvt-sub-1.id, aws_subnet.two-tier-pvt-sub-2.id]
}
