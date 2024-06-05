#/bin/bash/
sudo apt update
sudo apt install apache2 -y
systemctl start apache2 
systemctl enable apache2