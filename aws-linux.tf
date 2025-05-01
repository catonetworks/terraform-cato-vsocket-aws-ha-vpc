resource "aws_instance" "aws-linux" {
  ami = "ami-08f78cb3cc8a4578e"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.server_subnet.id
  key_name = "rgoodalllinux2025"
}

resource "aws_subnet" "server_subnet" {
  vpc_id            = aws_vpc.cato-vpc.id
  cidr_block        = "10.132.5.0/25"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.site_name}-Server-Subnet"
  }
}