provider "aws" {
  region = "us-east-1"
}

# VPC Configuration
resource "aws_vpc" "myvpc" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "spring-app-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "spring-app-igw"
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "172.16.10.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "spring-app-public-subnet"
  }
}

# Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "spring-app-public-rt"
  }
}

# Route Table Association
resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group for Spring Boot application
resource "aws_security_group" "app_sg" {
  name        = "spring-app-sg"
  description = "Security group for Spring Boot application"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Spring Boot application port"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "spring-app-sg"
  }
}

# Key Pair
resource "aws_key_pair" "my_key" {
  key_name   = "my-key-file"
  public_key = file("my-key-file.pem.pub")
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami                    = "ami-0e2c8caa4b6378d8c" # Ubuntu 22.04 LTS
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  key_name               = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              # Update system packages
              sudo apt update -y
              sudo apt upgrade -y

              # Install Java 17
              sudo apt install openjdk-17-jdk -y

              # Install Git
              sudo apt install git -y

              # Clone your application
              git clone https://github.com/Javeriya00/spring-boot-app.git /home/ubuntu/spring-boot-app

              # Install Maven
              sudo apt install maven -y

              # Ensure target directory is clean (with retries)
              TARGET_DIR="/home/ubuntu/spring-boot-app/target"
              if [ -d "$TARGET_DIR" ]; then
                  echo "Cleaning target directory..."
                  # Attempt to delete the target directory up to 5 times with a delay
                  for i in {1..5}; do
                      sudo rm -rf "$TARGET_DIR" && break
                      echo "Failed to delete target directory, retrying ($i/5)..."
                      sleep 5
                  done
              fi

              # Build and run the application
              cd /home/ubuntu/spring-boot-app
              mvn clean package || { 
                  # If mvn clean package fails, ensure target is cleaned up and retry
                  echo "Build failed, cleaning target and retrying..."
                  sudo rm -rf "$TARGET_DIR" && mvn clean package
              }
              nohup java -jar target/*.jar > /home/ubuntu/application.log 2>&1 &
              EOF

  tags = {
    Name = "spring-boot-app-server"
  }
}


# Output the application URL
output "application_url" {
  value = "http://${aws_instance.app_server.public_ip}:8080"
}
