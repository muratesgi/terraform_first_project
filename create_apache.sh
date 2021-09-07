#! /bin/bash
sudo su
yum -y install httpd
echo "<p> This is My Terraform First Project </p>" >> /var/www/html/index.html
sudo systemctl enable httpd
sudo systemctl start httpd