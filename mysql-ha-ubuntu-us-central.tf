provider "google" {
  project = "<your_project_id>"
  region  = "us-central1"
}

resource "google_compute_instance" "mysql-master" {
  name         = "mysql-master"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20231011"
      size  = 20
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = <<EOT
#!/bin/bash
apt update && apt install -y mysql-server git pcs
sed -i 's/#server-id/server-id=1/' /etc/mysql/mysql.conf.d/mysqld.cnf
sed -i 's/#log_bin/log_bin=mysql-bin/' /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl restart mysql
mysql -e "CREATE USER 'replica'@'%' IDENTIFIED BY 'replica_password';"
mysql -e "GRANT REPLICATION SLAVE ON *.* TO 'replica'@'%';"
EOT
}

resource "google_compute_instance" "mysql-slave" {
  name         = "mysql-slave"
  machine_type = "e2-medium"
  zone         = "us-central1-b"

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20231011"
      size  = 20
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = <<EOT
#!/bin/bash
apt update && apt install -y mysql-server git pcs
sed -i 's/#server-id/server-id=2/' /etc/mysql/mysql.conf.d/mysqld.cnf
sed -i 's/#log_bin/log_bin=mysql-bin/' /etc/mysql/mysql.conf.d/mysqld.cnf
mysql -e "CHANGE MASTER TO MASTER_HOST='${google_compute_instance.mysql-master.network_interface.0.network_ip}', MASTER_USER='replica', MASTER_PASSWORD='replica_password', MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=0;"
systemctl restart mysql
EOT
}

output "master-ip" {
  value = google_compute_instance.mysql-master.network_interface.0.access_config.0.nat_ip
}

output "slave-ip" {
  value = google_compute_instance.mysql-slave.network_interface.0.access_config.0.nat_ip
}
