# Security Group for EC2 instances
resource "aws_security_group" "two-tier-ec2-sg" {
  name        = "two-tier-ec2-sg"
  description = "Allow traffic from VPC"
  vpc_id      = aws_vpc.two-tier-vpc.id
  depends_on = [
    aws_vpc.two-tier-vpc
  ]

  # Ingress rules (allow incoming traffic)
  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1" # Allow all incoming traffic
  }
  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP traffic from anywhere
  }
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH traffic from anywhere (CAUTION: This is not recommended for production)
  }

  # Egress rules (allow outgoing traffic)
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1" # Allow all outgoing traffic
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic to anywhere
  }

  tags = {
    Name = "two-tier-ec2-sg"
  }
}

# Security Group for Load Balancer
resource "aws_security_group" "two-tier-alb-sg" {
  name        = "two-tier-alb-sg"
  description = "Load balancer security group"
  vpc_id      = aws_vpc.two-tier-vpc.id
  depends_on = [
    aws_vpc.two-tier-vpc
  ]

  # Ingress rules (allow incoming traffic)
  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1" # Allow all incoming traffic
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic from anywhere (CAUTION: This is not recommended for production)
  }

  # Egress rules (allow outgoing traffic)
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1" # Allow all outgoing traffic
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic to anywhere
  }

  tags = {
    Name = "two-tier-alb-sg"
  }
}

# Security Group for Database Tier
resource "aws_security_group" "two-tier-db-sg" {
  name        = "two-tier-db-sg"
  description = "Allow traffic from the internet"
  vpc_id      = aws_vpc.two-tier-vpc.id

  # Ingress rules (allow incoming traffic)
  ingress {
    from_port       = 3306 # MySQL port
    to_port         = 3306 # MySQL port
    protocol        = "tcp"
    security_groups = [aws_security_group.two-tier-ec2-sg.id] # Allow traffic from EC2 instances
    cidr_blocks     = ["0.0.0.0/0"] # Allow MySQL traffic from anywhere (CAUTION: This is not recommended for production)
  }

  ingress {
    from_port       = 22 # SSH port
    to_port         = 22 # SSH port
    protocol        = "tcp"
    security_groups = [aws_security_group.two-tier-ec2-sg.id] # Allow SSH traffic from EC2 instances
    cidr_blocks     = ["10.0.0.0/16"] # Allow SSH traffic from a specific IP range within the VPC
  }

  # Egress rules (allow outgoing traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outgoing traffic
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic to anywhere
  }
}
