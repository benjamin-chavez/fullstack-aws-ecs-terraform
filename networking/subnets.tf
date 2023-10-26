# networking/subnets.tf

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.audio_archive_vpc.id
  cidr_block = "10.0.3.0/24"
  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.audio_archive_vpc.id
  cidr_block = "10.0.4.0/24"
  tags = {
    Name = "Private Subnet"
  }
}



# resource "aws_subnet" "audio_archive_subnet_a" {
#   vpc_id     = aws_vpc.audio_archive_vpc.id
#   cidr_block = "10.0.1.0/24"
#   # availability_zone       = "us-east-1a"
#   map_public_ip_on_launch = true
#   tags = {
#     Name = "audio-archive-subnet-a"
#   }
# }

# resource "aws_subnet" "audio_archive_subnet_b" {
#   vpc_id     = aws_vpc.audio_archive_vpc.id
#   cidr_block = "10.0.2.0/24"
#   # availability_zone       = "us-east-1b"
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "audio-archive-subnet-b"
#   }
# }
