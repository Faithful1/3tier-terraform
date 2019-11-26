#!/bin/bash -xe

sudo yum update - y
sudo yum install httpd - y
sudo / etc / init.d / httpd start
echo\ "<html><body><h1>Awesome !!!</h1>\" > /var/www/html/index.html
echo\ "</body></html>\" >> /var/www/html/index.html
sudo service httpd start
sudo chkconfig httpd on