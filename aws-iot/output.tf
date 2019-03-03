output "thing_client_id" {
  value = "${aws_iot_thing.iot_thing.default_client_id}"
}

output "thing_arn" {
  value = "${aws_iot_thing.iot_thing.arn}"
}

output "certificate_arn" {
  value = "${aws_iot_certificate.cert.arn}"
}
