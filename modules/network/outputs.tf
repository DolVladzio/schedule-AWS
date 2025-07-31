output "vpc_name" {
  value = aws_vpc.main-vpc.tags["Name"]
}