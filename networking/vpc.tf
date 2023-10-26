# networking/vpc.tf

resource "aws_vpc" "audio_archive_vpc" {
  cidr_block = "10.0.0.0/16"
  # enable_dns_support   = true
  # enable_dns_hostnames = true

  tags = {
    Name = "audio-archive-vpc"
  }
}
