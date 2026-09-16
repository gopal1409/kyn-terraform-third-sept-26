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
#create a new file alb.tf copy from line 77 till 107
resource "aws_lb" "web_lb" {
  name     = "${local.name_prefix}-alb"
  internal           = false #this will create external lb
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [for subnet in aws_subnet.web_subnet : subnet.id]


   tags = {
    Name = "${local.name_prefix}-alb"

  }
}

output "alb_dns" {
    #this will give me the lb dns name using the same i can access all my instance
  value = aws_lb.web_lb.dns_name
}

#Listeners and routing this will get the traffic in lb and send to target group
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.web_lb.arn 
  port              = "80"
  protocol          = "HTTP"
  

  default_action { #listener will send the traffic to 
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tg.arn
  }
}

##exercise
1. do terraform apply. 
2. once apply complete go to load balancer click on the same you will get the dns name copy it paste it in browser keep on refreshing the page it will show traffic is in which instance private ip keep on changing
3. in load balancer listener and rule click on it it will show the target group
4. click on network mapping you will see all your subnet
5. click on resource map you will see the traffic flow from lb to load balancer
6. click on security you will see your custom sg is there
7. clieck on target group click on target you will se all the instance health. if it is not showing refresh the page
####finally destroy it
terraform destroy
