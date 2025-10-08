output "network_ids" {
  value = {
    vpc_id                  = aws_vpc.main.id
    public_subnet_ids       = aws_subnet.public[*].id
    private_subnet_ids      = aws_subnet.private[*].id
    public_route_table_id   = aws_route_table.public.id
    private_route_table_ids = aws_route_table.private[*].id
    igw_id                  = aws_internet_gateway.public.id
    nat_gateway_ids         = aws_nat_gateway.nat_gw[*].id
  }
}
