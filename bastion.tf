######
### VPCS
######

data "aws_vpc" "default" {
  default = true
}

######
### ROUTE TABLES
######

data "aws_route_table" "default" {
  vpc_id = "${data.aws_vpc.default.id}"
}

######
### SECURITY GROUPS
######

resource "aws_security_group" "bastion_sg" {
  name   = "bastion"
  vpc_id = "${data.aws_vpc.default.id}"

  ingress {
    description = "SSH from allowed IP addresses"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      "103.208.220.0/24",  # VPN
      "209.146.25.246/32", # PH
    ]
  }

  tags = {
    Name = "bastion-sg"
  }
}

######
### INSTANCES
######

resource "aws_instance" "bastion_instance" {
  ami                    = "ami-06d9ad3f86032262d"
  instance_type          = "t2.micro"
  key_name               = "DevStgBastion"
  vpc_security_group_ids = ["${aws_security_group.bastion_sg.id}"]

  tags = {
    Name = "bastion"
  }
}

######
### ELASTIC IPS
######

resource "aws_eip" "bastion_eip" {
  instance = "${aws_instance.bastion_instance.id}"

  tags = {
    Name = "bastion-ip"
  }
}

######
### OUTPUTS
######

output "bastion_public_ip" {
  value = "${aws_eip.bastion_eip.public_ip}"
}
