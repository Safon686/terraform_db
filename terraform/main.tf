provider "aws"  {
        region                 = "eu-central-1"
}

resource "aws_security_group" "public" {
  name   = "security_group_for_instance"
  vpc_id = aws_vpc.main.id
  dynamic "ingress" {
    for_each = ["80", "8080"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
    }
  }
   ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "private" {
  name   = "security_group_for_db"
  vpc_id = aws_vpc.main.id
  dynamic "ingress" {
    for_each = ["22", "3306"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_launch_template" "instance" {
  name_prefix   = "redhat-"
  image_id      = "ami-03cbad7144aeda3eb"
  instance_type = "t3.micro"
  key_name      = "aws"
  lifecycle {
    create_before_destroy = true
  }
  vpc_security_group_ids = [aws_security_group.public.id]
    tags = {
      Name        = "test"
    }

}
resource "aws_autoscaling_group" "public_asg" {
  vpc_zone_identifier       = [aws_subnet.public.id]
  min_size                  = 1
  max_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  launch_template {
    id      = aws_launch_template.instance.id
  }
}
resource "aws_db_instance" "default" {
  allocated_storage    = 10
  db_name              = "db_for_test"
  engine               = "mysql"
  engine_version       = "8.0.32"
  instance_class       = "db.t3.micro"
  port                 = "3306"
  username             = var.usr
  password             = var.pass
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.private.id]
}