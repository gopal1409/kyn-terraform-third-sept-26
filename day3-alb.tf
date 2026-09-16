#lets create an alb-sg.tf where we have only open port 80 and 443 copy from line 2 till 42
  resource "aws_security_group" "alb_sg" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Allow  inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.web_vpc.id
  #creat the ingress rule
  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "HTTPs"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  

  egress {
    description      = "allow all outgoing rule"
    from_port        = 0
    to_port          = 0
    protocol         = "-1" #tcp
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${local.name_prefix}-alb-sg"

  }
}

output "albsecurity_group_id" {
  value = aws_security_group.alb_sg.id
}
#lets create the alb-target-group.tf
  resource "aws_lb_target_group" "alb-tg" {
  name     = "${local.name_prefix}-alb-sg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.web_vpc.id
  ###lets add the health check also
  health_check {
    enabled             = true
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 4
    timeout             = 5
    interval            = 30
    matcher             = 200
  }
  tags = {
    Name = "${local.name_prefix}-alb-sg"

  }
}

#behind the target group we need to attach all our instances
resource "aws_lb_target_group_attachment" "web_tg_attachment" {
  for_each         = aws_instance.web_vm
  target_group_arn = aws_lb_target_group.alb-tg.arn
  target_id        = each.value.id
  port             = 80
}

#do terraform apply
  ##check the target group created click on the same you will see all your instance in unused as once we create the lb health checkup will be started
