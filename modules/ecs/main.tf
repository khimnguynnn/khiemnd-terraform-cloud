resource "aws_ecs_cluster" "main" {
  name = "${var.tags["Enviroment"]}-${var.tags["Project"]}-cluster"

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Enviroment"]}-${var.tags["Project"]}-cluster"
    },
  )
}
