wget http://repo.zabbix.com/zabbix/x.x/ubuntu/pool/main/z/zabbix-release/zabbix-release_all.deb

sudo dpkg -i zabbix-release*

sudo apt update

sudo apt install zabbix-server-mysql zabbix-frontend-php zabbix-agent zabbix-apache-conf (zabbix-nginx-conf)

mysql -u root -p

mysql> CREATE DATABASE zabbixdb CHARACTER SET utf8 COLLATE utf8_bin;

mysql> CREATE USER zabbixuser@localhost IDENTIFIED BY ‘this my password’;

mysql> GRANT ALL PRIVILEGES ON *zabbixdb.* TO 'zabbixuser'@'localhost';

mysql> FLUSH PRIVILEGES;

mysql> \q

wget https://cdn.zabbix.com/zabbix/sources/stable/x.x/zabbix-x.tar.gz

tar xpvf zabbix-*.tar.gz

cd ./zabbix-*/database/mysql/

cat data.sql | mysql -uroot -p zabbix

cat images.sql | mysql -uroot -p zabbix

cat schema.sql | mysql -uroot -p zabbix


sudo nano /etc/zabbix/zabbix_server.conf


DBHost=localhost
DBName=zabbixdb
DBUser=zabbix
DBPassword=this my password


sudo a2enconf zabbix-frontend-php
sudo systemctl restart apache2
sudo systemctl restart zabbix-server


sudo dpkg-reconfigure locales

ru_RU.UTF-8
ru_RU.ISO-8859-5

