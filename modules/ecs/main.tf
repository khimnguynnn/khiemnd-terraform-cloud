resource "aws_ecs_cluster" "main" {
  name = "${var.tags["Environment"]}-${var.tags["Project"]}-cluster"

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Environment"]}-${var.tags["Project"]}-cluster"
    },
  )
}
