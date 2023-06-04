resource "aws_instance" "webserver" {
    count = 2
    ami                 = "ami-08e415170f52d1657" 
    instance_type       = "t2.micro"
    # availability_zone   = "eu-central-1a"
    security_groups     = ["${aws_security_group.webaccess.name}"] 
    user_data           = file("install-wordpress.sh")

    depends_on = [aws_db_instance.wordpressdb]

    tags = {
      Name = "webserver-${count.index}"
    }
}

resource "aws_db_instance" "wordpressdb" {
  identifier           = "sample1"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  db_name              = "wordpress"
  username             = var.database_user
  password             = var.database_password
  skip_final_snapshot  = true
  vpc_security_group_ids = ["${aws_security_group.RDS_allow_rule.id}"]
}

data "template_file" "user_data" {
  template = file("install-wordpress.sh")
  vars = {
    db_username      = var.database_user
    db_user_password = var.database_password
    db_name          = "wordpress"
    db_RDS           = aws_db_instance.wordpressdb.endpoint
  }
}

resource "aws_security_group" "webaccess" {
  name        = "Allow web Traffic"
  description = "HTTP"
  #vpc_id      = aws_vpc.main.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "http"
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_lb" "example" {
  name               = var.alb_name
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_target_group" "tg" {

  name = var.alb_name

  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_security_group" "alb" {

  name = var.alb_security_group_name

  # Allow inbound HTTP requests
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb_target_group_attachment" "tgattachment" {
  count            = length(aws_instance.webserver.*.id) == 2 ? 2 : 0
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = element(aws_instance.webserver.*.id, count.index)
}

# Security group for RDS
resource "aws_security_group" "RDS_allow_rule" {
  #vpc_id = aws_vpc.prod-vpc.id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.webaccess.id}"]
  }
  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow ec2"
  }
}
