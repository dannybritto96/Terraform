output "public_instance_dns" {
  value = "${aws_instance.serv.public_ip}"
}