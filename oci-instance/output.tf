output "public_ip" {
  value = "${oci_core_instance.demoinstance.public_ip}"
}
