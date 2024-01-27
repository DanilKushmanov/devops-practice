terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = "ru-central1-a"
  token = "y0_AgAAAAAJ89LzAATuwQAAAADXw9Jg9c02CFcWRByVNmiLPNOJSPw0xPA"
  cloud_id = "b1gc7onttnadnivcrdpf"
  folder_id = "b1g43aq7nnnac7rsogvm"
}

resource "yandex_vpc_network" "default" {
  name = "test_network"
}

resource "yandex_vpc_subnet" "test-subnet-a" {
  v4_cidr_blocks = ["192.168.0.0/24"]
  zone = "ru-central1-a"
  network_id = "${yandex_vpc_network.default.id}"
}

resource "yandex_compute_disk" "vm-hdd" {
  name = "hdd"
  type = "network-hdd"
  zone = "ru-central1-a"
  size = 10

  image_id = "fd8vljd295nqdaoogf3g"
}

resource "yandex_compute_instance" "vm-site" {
  name = "site"
  zone = "ru-central1-a"

  resources {
    cores = 2
    memory = 4
  }

  boot_disk {
    disk_id = yandex_compute_disk.vm-hdd.id
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.test-subnet-a.id}"
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }

}

output "site-addr" { # не выдал внешний айпи, надо это отработать
  value       = "${yandex_compute_instance.vm-site.network_interface.0.nat_ip_address}"
}
