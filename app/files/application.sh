#!/bin/bash
apt-get update -y
apt-get upgrade -y
apt-get install nginx -y
echo '<h1>v${app_version}</h1>' > /var/www/html/index.html