#!/bin/bash

echo "===This is a WordPress instalation Script==="

echo "Do you wish to proceed to instalation of Apache? (Y/N)"
read answer_apache

if [ $
answer_apache = "Y" ]
then
	echo "Starting APACHE instalation"
	echo "Apache is the webserver software that is responsible for serving the content to your web browser from the server. It takes the requests that it receives and sends back the HTML code for your browser to interpret."
	sleep 5

 	yum -y install httpd
	firewall-cmd --permanent --add-service=http -add-service=https
	firewall-cmd --reload
	systemctl start httpd
	systemctl enable httpd
	
	
	echo "For APACHE instalation locations please see /PATH"
	sleep 5

else 
	echo "Instalation aborted mate!"
fi

echo "Do you wish to proceed to instalation of MySQL/MariaDB? (Y/N)"
read answer_maria

if [ $answer_maria = "Y" ]
then
	echo "Starting MySQL/MariaDB instalation"
	echo "MySQL and MariaDB are what handle your website's database."
	sleep 5

	yum -y install mariadb-server
	systemctl start mariadb
	mysql_secure_installation
	systemctl enable mariadb

	
	echo "For APACHE instalation locations please see /PATH"
	sleep 5
else
	echo "Instalation aborted mate!"

fi

echo "Do you wish to proceed to instalation of PHP? (Y/N)"
read answer_PHP

if [ $answer_PHP = "Y" ]
then
	echo "Instalation of PHP starting..."
	sleep 5

	yum install centos-release-scl
	yum install rh-php72 rh-php72-php rh-php72-php-mysqlnd
	ln -s /opt/rh/rh-php72/root/usr/bin/php /usr/bin/php
	ln -s /opt/rh/httpd24/root/etc/httpd/conf.d/rh-php72-php.conf /etc/httpd/conf.d/
	ln -s /opt/rh/httpd24/root/etc/httpd/conf.modules.d/15-rh-php72-php.conf /etc/httpd/conf.modules.d/
	ln -s /opt/rh/httpd24/root/etc/httpd/modules/librh-php72-php7.so /etc/httpd/modules/
	systemctl restart httpd

	
else
	echo "Instalation aborted mate!"
fi

echo "Do you wish to proceed to instalation of wordpress? (Y/N)"
read answer_wordpress

if [ $answer_wordpress = "Y" ]
then
	echo "Database creation..."
	sleep 5
	mysql -u root -p
	CREATE DATABASE wordpress;
	CREATE USER admin@localhost IDENTIFIED BY 'Dua1edu';
	GRANT ALL PRIVILEGES ON wordpress.* TO admin@localhost IDENTIFIED BY 'Dua1edu';
	FLUSH PRIVILEGES;
	exit
	echo "Installing wordpress..."
	sleep 5
	cd ~
	yum install wget
	wget http://wordpress.org/latest.tar.gz
	tar -xzvf latest.tar.gz
	sudo rsync -avP ~/wordpress/ /var/www/html/
	mkdir /var/www/html/wp-content/uploads
	sudo chown -R apache:apache /var/www/html/*
	echo "Configuring wordpress..."
	cd /var/www/html
	cp wp-config-sample.php wp-config.php

	sed -i "s/database_name_here/wordpress/g" wp-config.php
	sed -i "s/username_here/admin/g" wp-config.php
	sed -i "s/password_here/Dua1edu/g" wp-config.php

else
	echo "Instalation aborted mate!"
fi

echo "Instalation complete"
echo "Please verify your WordPress install is working on http://server_domain_name_or_IP/wp-admin"

	


