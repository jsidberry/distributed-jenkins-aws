#Create VPC in us-east-2
resource "aws_vpc" "vpc_master" {
  provider             = aws.region_master
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "master-vpc-jenkins"
  }

}

#Create VPC in us-west-2
resource "aws_vpc" "vpc_master_oregon" {
  provider             = aws.region_worker
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "worker-vpc-jenkins"
  }

}

#Create IGW in us-east-2
resource "aws_internet_gateway" "igw" {
  provider = aws.region_master
  vpc_id   = aws_vpc.vpc_master.id
  tags = {
    Name = "master-vpc-jenkins"
  }

}

#Create IGW in us-west-2
resource "aws_internet_gateway" "igw-oregon" {
  provider = aws.region_worker
  vpc_id   = aws_vpc.vpc_master_oregon.id
  tags = {
    Name = "worker-vpc-jenkins"
  }

}

#Get all available AZ's in VPC for master region
data "aws_availability_zones" "azs" {
  provider = aws.region_master
  state    = "available"
}


#Create subnet # 1 in us-east-2
resource "aws_subnet" "subnet_1" {
  provider          = aws.region_master
  vpc_id            = aws_vpc.vpc_master.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = element(data.aws_availability_zones.azs.names, 0) # element retrieves a single element from a list.
  tags = {
    Name = "jenkins-master-1"
  }
}


#Create subnet #2  in us-east-2
resource "aws_subnet" "subnet_2" {
  provider          = aws.region_master
  vpc_id            = aws_vpc.vpc_master.id
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  cidr_block        = "10.0.2.0/24"
  tags = {
    Name = "jenkins-master-2"
  }
}


#Create subnet in us-west-2
resource "aws_subnet" "subnet_1_oregon" {
  provider   = aws.region_worker
  vpc_id     = aws_vpc.vpc_master_oregon.id
  cidr_block = "192.168.1.0/24"
  tags = {
    Name = "jenkins-worker-1"
  }
}

#Initiate Peering connection request from us-east-2
resource "aws_vpc_peering_connection" "useast2-uswest2" {
  provider    = aws.region_master
  peer_vpc_id = aws_vpc.vpc_master_oregon.id
  vpc_id      = aws_vpc.vpc_master.id
  peer_region = var.region_worker
  tags = {
    Name = "useast2-uswest2-vpc-jenkins"
  }
}

#Accept VPC peering request in us-west-2 from us-east-2
resource "aws_vpc_peering_connection_accepter" "accept_peering" {
  provider                  = aws.region_worker
  vpc_peering_connection_id = aws_vpc_peering_connection.useast2-uswest2.id
  auto_accept               = true
}

#Create route table in us-east-1
resource "aws_route_table" "internet_route" {
  provider = aws.region_master
  vpc_id   = aws_vpc.vpc_master.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  route {
    cidr_block                = "192.168.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.useast2-uswest2.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "Master-Region-RT"
  }
}

#Replace default route table of VPC(Master) with the route table entries
resource "aws_main_route_table_association" "set-master-default-rt-assoc" {
  provider       = aws.region_master
  vpc_id         = aws_vpc.vpc_master.id
  route_table_id = aws_route_table.internet_route.id
}

#Create route table in us-west-2
resource "aws_route_table" "internet_route_oregon" {
  provider = aws.region_worker
  vpc_id   = aws_vpc.vpc_master_oregon.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-oregon.id
  }
  route {
    cidr_block                = "10.0.1.0/24"
    vpc_peering_connection_id = aws_vpc_peering_connection.useast2-uswest2.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "Worker-Region-RT"
  }
}

#Replace default rtb of VPC(Worker) with the rtb entries
resource "aws_main_route_table_association" "set-worker-default-rt-assoc" {
  provider       = aws.region_worker
  vpc_id         = aws_vpc.vpc_master_oregon.id
  route_table_id = aws_route_table.internet_route_oregon.id
}

