##go inside the security-group.tf delete everything and add this  from line 3 till 50
  
  resource "aws_security_group" "web_sg" {
  name        = "${local.name_prefix}-web-sg"
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
  ingress {
    description      = "ssh"
    from_port        = 22
    to_port          = 22
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
    Name = "${local.name_prefix}-web-sg"
   
  }
}

output "security_group_id" {
  value = aws_security_group.web_sg.id
}

#lets create the vm.tf file copy from 53 till 86 then do terraform apply
  resource "aws_instance" "web_vm" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"
  subnet_id = aws_subnet.web_subnet["subnet1"].id
  vpc_security_group_ids = [ aws_security_group.web_sg.id ]

  associate_public_ip_address = true
    user_data = file("${path.module}/app.sh")
  #path.module is an meta argument in terraform which will look for any file in the current directory
  #user_data = C:\Users\gopal\OneDrive\Desktop\terraform-project\path.sh
  tags = {
    Name = "${local.name_prefix}-web-server"
    Project = var.project_name
    Environment = var.environment
  }
}

#once our instance get create we want to display some values
#instance id public ip of the instance 
/*output "instance_details" {
    description = "show the instance id public ip and private ip"
    value = {
        for name, instance in aws_instance.web_vm :
        name => {
            instance_id = instance.id 
            public_ip = instance.public_ip
            private_ip = instance.private_ip
        }
    }
}*/

output "public_ip" {
  value = aws_instance.web_vm.public_ip
}
