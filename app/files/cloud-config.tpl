#cloud-config

    
runcmd:
  - apt-get update -y
  - apt-get upgrade -y
  - apt-get install nginx -y
  - echo '<h1>${app_version} App Server</h1>' > /var/www/html/index.html