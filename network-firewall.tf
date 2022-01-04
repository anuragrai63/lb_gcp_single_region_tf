# allow http traffic
resource "google_compute_firewall" "allow-http" {
  name = "terraform-fw-allow-http"
  network = "${google_compute_network.vpc.name}"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["130.211.0.0/22","35.191.0.0/16",]
  target_tags = ["http"]
}
# allow ssh traffic
resource "google_compute_firewall" "allow-ssh" {
  name = "terraform-fw-allow-ssh"
  network = "${google_compute_network.vpc.name}"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
 source_ranges = ["130.211.0.0/22","35.191.0.0/16",]
  target_tags = ["ssh"]
}
