provider "oci" {
  tenancy_ocid = "${var.tenancy_ocid}"
  user_ocid = "${var.user_ocid}"
  fingerprint = "${var.fingerprint}"
  region = "${var.region}"
}

data "oci_core_images" "os" {
  compartment_id = "${var.tenancy_ocid}"
  operating_system = "Canonical Ubuntu"
  operating_system_version = "18.04"

  filter {
    name   = "display_name"
    values = ["^([a-zA-z]+)-([a-zA-z]+)-([\\.0-9]+)-([\\.0-9-]+)$"]
    regex  = true
  }
}

resource "oci_core_vcn" "demovcn" {
  cidr_block = "${var.vcn_cidr_block}"
  compartment_id = "${var.tenancy_ocid}"
}

resource "oci_core_internet_gateway" "demoigw" {
  compartment_id = "${var.tenancy_ocid}"
  vcn_id = "${oci_core_vcn.demovcn.id}"
  enabled = "true"
}

resource "oci_core_route_table" "demotable" {
  compartment_id = "${var.tenancy_ocid}"
  route_rules = [
    {
      destination = "0.0.0.0/0"
      network_entity_id = "${oci_core_internet_gateway.demoigw.id}"
    }
  ]

  vcn_id = "${oci_core_vcn.demovcn.id}"
}

resource "oci_core_security_list" "sshlist" {
  compartment_id = "${var.tenancy_ocid}"
  vcn_id = "${oci_core_vcn.demovcn.id}"
  display_name = "demo security list"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol = "${var.tcp_protocol}"
  }

  ingress_security_rules {
    protocol = "${var.tcp_protocol}"
    source = "0.0.0.0/0"
    stateless = "false"

    tcp_options {
      min =22
      max = 22
    }
  }
}


resource "oci_core_subnet" "demosubnet" {
  availability_domain = "${var.availability_zone}"
  compartment_id = "${var.tenancy_ocid}"
  cidr_block = "${var.subnet_cidr_block}"
  vcn_id = "${oci_core_vcn.demovcn.id}"
  route_table_id = "${oci_core_route_table.demotable.id}"
  security_list_ids = ["${oci_core_security_list.sshlist.id}"]
}

resource "oci_core_instance" "demoinstance" {
  availability_domain = "${var.availability_zone}"
  compartment_id = "${var.tenancy_ocid}"
  display_name = "${var.instance_name}"
  shape = "${var.shape_name}"

  source_details {
    source_id = "${lookup(data.oci_core_images.os.images[0], "id")}"
    source_type = "image"
  }

  create_vnic_details {
    subnet_id = "${oci_core_subnet.demosubnet.id}"
    assign_public_ip = "true"
  }

  metadata {
    ssh_authorized_keys = "${var.ssh_public_key}"
  }
}
