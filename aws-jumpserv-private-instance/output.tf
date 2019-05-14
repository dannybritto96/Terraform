output "public_instance_dns" {
  value = "${aws_instance.jump.public_dns}"
}

output "private_instance_ip" {
  value = "${aws_instance.private_instance.private_ip}"
}

