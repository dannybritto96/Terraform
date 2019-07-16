data "external" "config_file" {
  program = ["cat", "C:\\Users\\Danny\\Downloads\\My First Project-5125e5fb6c94.json"]
  query = {

  }
}

locals {
  project_id = "${data.external.config_file.result["project_id"]}"
}

output "test" {
  value = "${local.project_id}"
}

data "google_compute_image" "ubuntu" {
  project = "ubuntu-os-cloud"
  family = "ubuntu-1804-lts"
}

resource "google_compute_network" "vpc" {
  name = "sampvpc"
  project = "${local.project_id}"
  auto_create_subnetworks = true
  routing_mode = "GLOBAL"
}

resource "google_compute_instance" "instance" {
  name = "${var.instance_name}"
  machine_type = "${var.machine_type}"
  zone = "${var.instance_zone}"
  project = "${local.project_id}"
  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.ubuntu.self_link}"
    }
  }

  metadata {
    ssh-keys = "ubuntu:${file("C:\\Users\\Danny\\key_pub.pub")}"
  }

  network_interface {
    network = "${google_compute_network.vpc.self_link}"

    access_config {

    }

  }
}
