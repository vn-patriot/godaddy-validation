#!/bin/sh

sudo apt-get update -y
sudo apt-get install nginx -y

mkdir -p /usr/share/nginx/html/.well-known/pki-validation
touch godaddy.html && echo -n "YOUNEVERSEEME" > godaddy.html
mv godaddy.html /usr/share/nginx/html/.well-known/pki-validation
chmod -R 755 /usr/share/nginx/html/.well-known/pki-validation

sudo service nginx restart
