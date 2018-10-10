# create VPC
# create IGW
# create public subnet
# create security group
# create new instance with cloud-init
# output instance IP
variable "aws_region" {
  default = "us-east-1"
}

variable "aws_profile" {
  default = "default"
}

variable "vpc_cidr" {
  default = "172.16.0.0/16"
}

variable "public_subnet_cidr" {
  default = "172.16.0.0/24"
}

variable "private_subnet_cidr" {
  default = "172.16.1.0/24"
}

variable "key_name" {
  default = "default"
}

# Ubuntu Server 16.04 LTS in us-east-1
variable "ami_id" {
  default = "ami-059eeca93cf09eebd"
}

provider aws {
  region                  = "${var.aws_region}"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "${var.aws_profile}"
}

resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr}"
}

resource "aws_subnet" "public_net" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.public_subnet_cidr}"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_net" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "${var.private_subnet_cidr}"
  map_public_ip_on_launch = false
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"
}

resource "aws_security_group" "http_ssh" {
  name        = "http_ssh"
  description = "Allow http and ssh inbound and all outbound traffic"
  vpc_id      = "${aws_vpc.main.id}"
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "postgresql_ssh" {
  name        = "postgresql_ssh"
  description = "Allow postgresql and ssh inbound and all outbound traffic"
  vpc_id      = "${aws_vpc.main.id}"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "TCP"
    cidr_blocks = ["${var.vpc_cidr}"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_route" "route" {
  route_table_id               = "${aws_vpc.main.default_route_table_id}"
  destination_cidr_block       = "0.0.0.0/0"
  gateway_id                   = "${aws_internet_gateway.gw.id}"
}

resource "aws_instance" "web" {
  ami           = "${var.ami_id}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.public_net.id}"
  vpc_security_group_ids   = ["${aws_security_group.http_ssh.id}"]
  user_data     = "${replace("${replace("${file("init.sh")", "##ROLE##", "WEB")}", "##DB_IP##", aws_instance.db.public_ip)}"  
  key_name      = "${var.key_name}"
  depends_on = ["aws_instance.db"]
}

resource "aws_instance" "db" {
  ami           = "${var.ami_id}"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.public_net.id}"
  vpc_security_group_ids   = ["${aws_security_group.postgresql_ssh.id}"]
  user_data     = "${replace("$file("init.sh")", "##ROLE##", "DB"}"
  key_name      = "${var.key_name}"
}

output "web_public_ip" {
  value = ["${aws_instance.web.public_ip}"]
}

output "db_public_ip" {
  value = ["${aws_instance.db.public_ip}"]
}

