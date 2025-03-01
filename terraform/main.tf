# VPC and Subnets
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true  
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "devops_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instances
resource "aws_instance" "jenkins_master" {
  ami                     = "ami-0e1bed4f06a3b463d" 
  instance_type           = "t2.medium"
  subnet_id               = aws_subnet.public.id
  vpc_security_group_ids  = [aws_security_group.devops_sg.id]
  associate_public_ip_address = true  # Explicitly ensure public IP
  tags = { Name = "Jenkins-Master" }
}

resource "aws_instance" "jenkins_slave" {
  ami                     = "ami-0e1bed4f06a3b463d"
  instance_type           = "t2.medium"
  subnet_id               = aws_subnet.public.id
  vpc_security_group_ids  = [aws_security_group.devops_sg.id]
  associate_public_ip_address = true
  tags = { Name = "Jenkins-Slave" }
}

resource "aws_instance" "k8s_master" {
  ami                     = "ami-0e1bed4f06a3b463d"
  instance_type           = "t2.large"
  subnet_id               = aws_subnet.public.id
  vpc_security_group_ids  = [aws_security_group.devops_sg.id]
  associate_public_ip_address = true
  tags = { Name = "K8s-Master" }
}

resource "aws_instance" "k8s_node" {
  count                   = 2
  ami                     = "ami-0e1bed4f06a3b463d"
  instance_type           = "t2.medium"
  subnet_id               = aws_subnet.public.id
  vpc_security_group_ids  = [aws_security_group.devops_sg.id]
  associate_public_ip_address = true
  tags = { Name = "K8s-Node-${count.index}" }
}

resource "aws_instance" "monitoring" {
  ami                     = "ami-0e1bed4f06a3b463d"
  instance_type           = "t2.medium"
  subnet_id               = aws_subnet.public.id
  vpc_security_group_ids  = [aws_security_group.devops_sg.id]
  associate_public_ip_address = true
  tags = { Name = "Monitoring" }
}

resource "aws_instance" "ansible_control" {
  ami                     = "ami-0e1bed4f06a3b463d"
  instance_type           = "t2.micro"
  subnet_id               = aws_subnet.public.id
  vpc_security_group_ids  = [aws_security_group.devops_sg.id]
  associate_public_ip_address = true
  tags = { Name = "Ansible-Control" }
}
