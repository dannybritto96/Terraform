output "public_instance_dns" {
  value = "${aws_instance.bastion.public_ip}"
}

output "private_instance_ip" {
  value = "${aws_instance.private_instance.private_ip}"
}

