#!/bin/bash
apt -y update
sudo apt -y install apache2
sudo mkdir -p /var/www/html
sudo touch /var/www/html/index.html
chmod 644 /var/www/html/index.html
sudo cat <<EOF > /var/www/html/index.html
<html>
<h2><font color="blue">WebServer</font></h2>
www
</html>
EOF

sudo service apache2 start
