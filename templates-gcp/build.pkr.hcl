// * Source image as baseline golden images
source "googlecompute" "basic-golden-images" {
  project_id = "clgcporg2-128"
  zone = "us-central1-a"
  image_storage_locations = ["us-central1-a"]
  source_image = "debian-11-bullseye-v20220920"
  source_image_family = "debian"
  image_name = "test-debian10-docker-{{timestamp}}"
  image_description = "This general image for Debian 11 (bullseye)"
  image_family = "test-debian11-docker"
  disk_size = "20"
  ssh_username = "packer"
  use_os_login = false
  communicator= "ssh"
  ssh_port = "22"
  ssh_handshake_attempts = "5"
  network = "default"
  subnetwork = "default"
  tags = ["allow-ssh"]
}

// * Builder for creating new GCP golden images
build {
  sources = ["sources.googlecompute.basic-golden-images"]

  // * Provisioner install ansible
  provisioner "shell" {
    inline = [
        "sudo apt-get update -y",
        "sudo apt-get install vim wget curl net-tools -y",
        "sudo apt-get install htop telnet -y",
        "sudo apt-get install ansible -y",
    ]
  } 

  // * Provisioner using ansible-local
  provisioner "ansible-local" {
    playbook_file   = "../files/ansible/playbook.yaml"
    extra_arguments = [
        "-vvvv",
        "--extra-vars",
        "\"ansible_user=packer\""
      ]
  }
}