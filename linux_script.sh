#!/bin/bash

echo "This is Installation script"
echo "###########################"
echo "PLEASE RUN THIS SCRIPT AS ROOT"
echo "If you are not signed as root, press CTRL+C and please come back with superpowers"

function main_menu() {
    echo "INSTALLATION MENU"
    echo "1 - Apache"
	echo "2 - MariaDB"
	echo "3 - PHP"
	echo "4 - WordPress"
	echo "5 - Troubleshoot wordpress"
	echo "6 - FTP Server"
	echo "7 - Python"
	echo "8 - Java"
	echo "9 - Update system"
    echo " "
}

main_menu

echo "To choose from list above please enter the number from 1 - 9: "
read number


function apache() {
	echo "Starting APACHE instalation...."
	sleep 5

	yum -y install httpd
	firewall-cmd --permanent --add-service=http -add-service=https
	firewall-cmd --reload
	systemctl start httpd
	systemctl enable httpd

	touch /apache_installed

	echo "Instalation of APACHE is complete."
	sleep 5

}


function mariadb() {
	echo "Starting MariaDB instalation...."
	sleep 5

	yum -y install mariadb-server
	systemctl start mariadb
	mysql_secure_installation
	systemctl enable mariadb

	touch /mariaDB_installed

	echo "Instalation of MariaDB is complete."
	sleep 5

}

function php() {
	if [ ! -f /apache_installed]
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

		echo "Instalation of PHP is complete."
		sleep 5
	else
		echo "Apache is not installed, make sure you install that before instalation of PHP."
	fi
}

function wordpress() {
	if [ ! -f /mariaDB_installed ]
	then
		echo "Creating database..."
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
		rsync -avP ~/wordpress/ /var/www/html/
		mkdir /var/www/html/wp-content/uploads
		chown -R apache:apache /var/www/html/*
		echo "Configuring wordpress..."
		sleep 5
		cd /var/www/html
		cp wp-config-sample.php wp-config.php

		sed -i "s/database_name_here/wordpress/g" wp-config.php
		sed -i "s/username_here/admin/g" wp-config.php
		sed -i "s/password_here/Dua1edu/g" wp-config.php

		touch /wordpress_installed

		echo "Instalation of WordPress is complete"
		echo "Please verify your WordPress install is working on http://server_domain_name_or_IP/wp-admin"
		sleep 5
	else
		echo "Cannot proceed to WordPress instalation, make sure you have APACHE, MariaDB and PHP installed."

	fi

}

function troubleshoot_wordpress() {
	if [ ! -f /wordpress_installed ]
	then
		cd /var/www/html
		touch phpinfo.php
		chmod 644 phpinfo.php
		echo -e "<?php\n// Show all information, defaults to INFO_ALL\nphpinfo();\n?>" >> phpinfo.php

		echo "Please verify troubleshooting succeeded. Go to http://server_domain-name_or_IP/phpinfo.php"
		echo "Was trouble shooting succesfull? (Y/N)"
		read answer

		if [ $answer = "Y" ]
		then
			echo "Troubleshooting complete!"
			sleep 5
		else
			echo" Proceeding with second step of Troubleshooting..."
			sleep 5
			yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
			 sed -i "s/enabled=1g"
			 yum update
			 yum install php-fpm php-gd php-pdo php-mbstring php-pear -y
			 systemctl enable php-fpm
			 systemctl start php-fpm
			 service httpd restart
	    fi
    fi

}

function ftp() {
	echo "Beginning FTP Server instalation..."

	yum install ftp vsftpd -y
	systemctl start vsftpd.service
	systemctl enable vsftpd.service
	firewall-cmd --zone=public --permanent --add-port=21/tcp
	firewall-cmd --zone=public --permanent --add-service=ftp
	firewall-cmd --reload
	# Configuring VSFTPD.
	local dir=/etc/vsftpd/vsftpd.conf
	cp $dir /etc/vsftpd/vsftpd.conf.default
	sed -i 's/anonymous_enable=YES/anonymous_enable=NO/g' $dir
	sed -i 's/#chroot_local_user=YES/chroot_local_user=YES/g' $dir
	echo "allow_writeable_chroot=YES" >> $dir
	echo "userlist_file=/etc/vsftpd/user_list" >> $dir
	echo "userlist_deny=NO" >> $dir
	systemctl restart vsftpd
 	# Create a new FTP user.
	echo -e -n "${light_cyan}Enter an username for FTP service: ${no_color}"
	read ftp_user_name
	useradd $ftp_user_name

	echo -e -n "Enter a password for $ftp_user_name: "
	read -s ftp_user_password

	echo "$ftp_user_name:$ftp_user_password" | chpasswd
	# Add new user to the user_list.
	echo "$ftp_user_name" | sudo tee -a /etc/vsftpd/user_list > /dev/null

	mkdir -p "/home/$ftp_user_name/ftp/upload"
	chmod 550 "/home/$ftp_user_name/ftp"
	chmod 750 "/home/$ftp_user_name/ftp/upload"
	chown -R $ftp_user_name: "/home/$ftp_user_name/ftp"

	echo -e "\nSee this: https://www.johnyoung.tech/is-it-the-end-for-ftp/"
	echo "Applying full access for ftpd to the system..."
	sudo setsebool -P ftpd_full_access on

	echo "Installation of FTP is complete."


}

function python() {
	echo "Do you wish to install from the source or via yum? (source/yum)"
	read python_answer

	if [python_answer = "yum" ]
	then
		echo "Installing via yum"
		yum update -y
		yum install -y python3
		echo "Installation is finished."
		echo "Please verify by droping into Python3 using the python3 command"
	else
		echo "Installing from the source..."
		yum install gcc openssl-devel bzip2-devel libffi-devel -y
		curl -O https://www.python.org/ftp/python/3.8.1/Python-3.8.1.tgz
		tar -xzf Python-3.8.1.tgz
		cd Python-3.8.1/
		./configure --enable-optimizations
		make altinstall
		echo "Installation is finished."
		echo "Please verify by droping into Python 3 using the python3.8 command"
	fi
}

function java() {
	echo "Installing Java"
	yum install java-latest-openjdk-devel -y
	update-alternatives --set java java-latest-openjdk.x86_64
	update-alternatives --set javac java-latest-openjdk.x86_64
	echo "Installation of Java is finished."
}

function update_system() {
	yum clean all -y
	yum update -y
	echo "System succesfuly updated."
}

case $number in

    1) apache ;;
    2) mariadb ;;
    3) php ;;
    4) wordpress ;;
    5) troubleshoot_wordpress ;;
    6) ftp ;;
    7) python ;;
    8) java ;;
    9) update_system ;;
    *) echo "Wrong input"
       exit ;;
esac
