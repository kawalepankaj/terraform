resource "aws_iam_user" "multi-user" {
  count= "10"
  name = "pankaj.${count.index+1}"
  tags = {
    Name = "pankaj"
  }
} 