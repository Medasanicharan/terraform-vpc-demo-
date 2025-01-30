output "availability_zones" {
    value = slice(data.aws_availability_zones.available.names, 0, 2)
}

output "default_vpc" {
    value = data.aws_vpc.default.id
}