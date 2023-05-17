# output "aws_ami" {
#   value = data.aws_ami.latest-amazon-linux-image.id
# }
output "server-ip" {
    value = aws_instance.myapp-server.public_ip
}