resource "aws_vpc_peering_connection" "peering" {
  count = var.is_peering_required ? 1 : 0
  peer_vpc_id   = var.acceptor_vpc == "" ? data.aws_vpc.default.id : var.acceptor_vpc 
  vpc_id        = aws_vpc.main.id 
  auto_accept = var.acceptor_vpc == "" ? true : false

   tags = {
    Name = "expense-default"
  }
}