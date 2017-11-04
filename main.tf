provider "aws" {
   region = "${var.aws_region}"
   profile = "${var.aws_profile}"
}

#IAM
S3_access

#VPC

resource "aws_vpc" "vpc" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_insternet_gatewat" "internet_gateway" {
  vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  resource { 
           cidr_block = "0.0.0.0/0"
           gateway_id = "${aws_internet_gateway.internet_gateway.id}"
           }
  tags {
       Name = "public"
  }
}

resource "aws_default_route_table" "private" { 
  default_route_table_id = "${aws_vpc.vpc.default_route_table_id}"
  tags {
     Name = "private"
  }
}

resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1d"

  tags {
    Name = "public"
  }
}

resource "aws_subnet" "private1" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1a"

  tags {
    Name = "private1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.1.3.0/24"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1c"

  tags {
    Name = "private2"
  }
}

resource "aws_subnet" "rds1" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.1.4.0/24"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1a"

  tags {
    Name = "rds1"
  }
}
 
resource "aws_subnet" "rds2" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.1.5.0/24"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1c"

  tags {
    Name = "rds2"
  }
}

resource "aws_subnet" "rds3" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.1.6.0/24"
  map_public_ip_on_launch = false
  availability_zone = "us-east-1d"

  tags {
    Name = "rds3"
  }
}

#Subnet Associations

resource "aws_route_table_association" "public_assoc" {
  subnet_id = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private1_assoc" {
  subnet_id = "${aws_subnet.private1.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private2_assoc" {
  subnet_id = "${aws_subnet.private2.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_db_subnet_group" "rds_subnetgroup" {
  name = "rds_subnetgroup"
  subnet_ids = ["${aws_subnet.rds1.id}", "${aws_subnet.rds.id}", "${aws_subnet.rds3.id}"]

  tags {
    Name = "rds_sng"
  }
}

#Security Groups

resource "aws_security_group" "public" {
  name = "sg_public"
  description = "Used for public and private instances for load balancer access"
  vpc_id = "${aws_vpc.vpc.id}"

  #SSH

  ingress {
    from_port	= 22
    to_port	= 22
    protocol	= "tcp"
    cidr_blocks = ["${var.localip}"]
  }

#HTTP
  
  ingress { 
    from_port	= 80
    to_port	= 80
    protocol	= "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Outbound Internet Access

  egress {
    from_port	= 0
    to_port	= 0
    protocol	= "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
}


