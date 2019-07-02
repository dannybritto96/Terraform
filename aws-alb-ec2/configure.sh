#!/bin/bash
apt update -y
apt install -y apache2
touch /var/www/html/health.html
service apache2 start
