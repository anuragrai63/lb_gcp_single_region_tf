resource "google_compute_instance_template" "web_server" {
  name = "terraform-web-server-template"
  description = "This template is used to create Apache web server"
  instance_description = "Web Server running Apache"
  can_ip_forward = false
  machine_type = "e2-micro"
  tags = ["ssh","http"]
  scheduling {
    automatic_restart = true
    on_host_maintenance = "MIGRATE"
  }
  disk {
    source_image = "debian-cloud/debian-10"
    auto_delete = true
    boot = true
    disk_size_gb = 10
  }
  disk {
    auto_delete  = true
    boot         = false
    disk_size_gb = 2
  }
  network_interface {
    network = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.private_subnet_1.name
  }
  
  lifecycle {
    create_before_destroy = true
  }
  # install nginx and serve a simple web page
  metadata = {
    startup-script = <<-EOF1
      #! /bin/bash
      set -euo pipefail

      export DEBIAN_FRONTEND=noninteractive
      apt-get update
      apt-get install -y nginx-light jq
      apt-get install -yq build-essential apache2
      apt-get install -y lvm*
      

      NAME=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/hostname")
      IP=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip")
      METADATA=$(curl -f -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=True" | jq 'del(.["startup-script"])')
      

      cat <<EOF > /var/www/html/index.html
      <pre>
      Hello VF-Cloud World – running on $NAME  on port 80
      Name: $NAME
      IP: $IP
      Metadata: $METADATA
      </pre>
      EOF

      /usr/sbin/pvcreate -y /dev/sdb
      /usr/sbin/vgcreate -y vg1 /dev/sdb 
      /usr/sbin/lvcreate -L 1G -n test_lv vg1
      /usr/sbin/mkfs.ext4 /dev/vg1/test_lv
      /usr/bin/mkdir /test
      /usr/bin/mount /dev/vg1/test_lv /test
    EOF1
  }
}