provider "aws" {
region = "eu-north-1"
}

resource "aws_key_pair" "testkey" {
  key_name   = "stockholmkey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC3ta2scDtLSemCHhzE1CGI/EpjB7xNI4CQS5m+k/QXy8vOwwWhwcQI1SE1gu10MaUoX0i+Z23pF8gasQiMHczgkKCd6fA3x+Y4dbOzKEaaIal9oybpasUL/zxvN8gUa4yHjyTPRV7s3dUHDmBFG7XpVuuMf+IeXn+vhMQoszSpujYo7PTPU4fojfaCclkO5nCs4pS+c0vxcnHDzr01JiOGa02r9JUFXuytVDx/OrcUJmUjnjTINq8h2yiY9xjEsGD9zkWeSEVQ99wnkyYwd0r9ENY3AJhx8XGRFzwa91ESsBNWxNIUWFV93E25dVrKEvjadcwCxEe0CJN7kGafCdmDU3a4712ZBoaVL0p6FAF9qXJd6kxQqILRj765uWOhL3q8fRXuMlIDojQf2/4DOloCDTQSL9QHnuWXIm+2QlvPC0cFqv2W4ShLp35jV0JCbU2z29gXEpbHCKwFM7TU+zwLq/JYrPZHU4zl8Dhxer9zE5TajH2pKwrf8TYJYo11cIc= rockylinux@git"
}


resource "aws_instance" "web" {
  ami           = "ami-04e4606740c9c9381"
  instance_type = "t3.micro"
  key_name      = "stockholmkey"
  vpc_security_group_ids = ["${aws_security_group.webSG.id}"]
  tags = {
    Name = "remote-exec-provisioner"
  }
  
}

resource "null_resource" "copy_execute" {
  
    connection {
    type = "ssh"
    host = aws_instance.web.public_ip
    user = "ec2-user"
    private_key = file("stockholmkey")
    }

 
  provisioner "file" {
    source      = "httpd.sh"
    destination = "/tmp/httpd.sh"
  }
  
   provisioner "remote-exec" {
    inline = [
      "sudo chmod 777 /tmp/httpd.sh",
      "sh /tmp/httpd.sh",
    ]
  }
  
  depends_on = [ aws_instance.web ]
  
  }

resource "aws_security_group" "webSG" {
  name        = "webSG"
  description = "Allow ssh  inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    
  }
}
