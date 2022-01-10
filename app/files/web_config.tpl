#cloud-config
write_files:
  - path: "/etc/nginx/sites-available/reverse-proxy.conf"
    permissions: "0744"
    owner: "root:root"
    encoding: "base64"
    content: |
      ${nginx_conf}
      
runcmd:
  - apt-get update -y
  - apt-get upgrade -y
  - apt-get install nginx -y
  - unlink /etc/nginx/sites-enabled/default
  - ln -s /etc/nginx/sites-available/reverse-proxy.conf /etc/nginx/sites-enabled/reverse-proxy.conf
  - systemctl reload nginx