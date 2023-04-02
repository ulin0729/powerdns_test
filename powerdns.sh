# DNS 3! powerdns Debian installation

1. Select "install"
2. Cancel DHCP configuration
3. Choose Configure network manually
    1. IP address: 10.1.6.79/21
    2. Gateway: 10.1.7.254
    3. Name server addresses: 1.1.1.1
    4. Hostname: dns-test3
    5. Domain name: empty
4. Root password: 123456
5. Full name for the new user: empty
6. new user: user
7. new user password: 123456
8. Partition disks:
    1. Partitioning method: Guided - use entire disk
    2. All file in same partition
    3. Finish partitioning and write changes to disk
    4. Yes
9. Configure the package manager
    1. Scan extra installation media? No
    2. Debian archive mirror country: Taiwan
    3. Debian archive mirror: deb.debian.org (the mirror in csie.ntu.edu.tw will freeze the installation??? )
    4. HTTP proxy: None
    You might encounter "Bad archive mirror":
        ctrl+alt+f2 and use the terminal to edit '/etc/resolv.conf' (`cat "nameserver 1.1.1.1 > /etc/resolv.conf`)
        ctrl+alt+f1 went back to installation and continue
10. Software selection
    1. Unselect desktop environments since we don't need it.
11. Install the GRUB boot loader: Yes -> /dev/sda
    
After login as root
run `wget https://raw.githubusercontent.com/ulin0729/powerdns_test/main/powerdns.sh`
```bash
apt update
apt upgrade
apt install vim -y
apt install build-essential -y

apt-get install apt-transport-https curl -y
curl -o /etc/apt/trusted.gpg.d/mariadb_release_signing_key.asc 'https://mariadb.org/mariadb_release_signing_key.asc'
sh -c "echo 'deb https://tw1.mirror.blendbyte.net/mariadb/repo/10.10/debian bullseye main' >>/etc/apt/sources.list"
apt update
apt install mariadb-server -y
systemctl restart mariadb
systemctl enable mariadb

mariadb-secure-installation    # manually type, need to fix no password issue by manually set password in mariadb

mariadb -u root --password=123456 -e "CREATE DATABASE powerdns;"
mariadb -u root --password=123456 -e "GRANT ALL ON powerdns.* TO 'powerdns'@'localhost' IDENTIFIED BY 'powerdns-password';"
mariadb -u root --password=123456 -e "FLUSH PRIVILEGES;"

wget https://raw.githubusercontent.com/PowerDNS/pdns/master/modules/gmysqlbackend/schema.mysql.sql

mariadb -u root --password=123456 powerdns < schema.mysql.sql

# PowerDNS Authoritative Server - master branch
echo "deb [arch=amd64] http://repo.powerdns.com/debian bullseye-auth-47 main" >> /etc/apt/sources.list.d/pdns.list

# PowerDNS Recursor - master branch
echo "deb [arch=amd64] http://repo.powerdns.com/debian bullseye-rec-48 main" >> /etc/apt/sources.list.d/pdns.list

echo "Package: pdns-*" >> /etc/apt/preferences.d/pdns
echo "Pin: origin repo.powerdns.com" >> /etc/apt/preferences.d/pdns
echo "Pin-Priority: 600" >> /etc/apt/preferences.d/pdns

#curl https://repo.powerdns.com/FD380FBB-pub.asc | apt-key add - && apt update    # maybe need to change the method since apt-key is deprecated

curl -o /etc/apt/trusted.gpg.d/FD380FBB-pub.asc 'https://repo.powerdns.com/FD380FBB-pub.asc'

apt update

systemctl disable systemd-resolved
systemctl stop systemd-resolved

# The recursor part is not included

apt install pdns-server pdns-backend-mysql -y

mv /etc/powerdns/pdns.conf /etc/powerdns/pdns.conf.bak

wget -P /etc/powerdns/ https://raw.githubusercontent.com/ulin0729/powerdns_test/main/pdns.conf

systemctl enable pdns
systemctl restart pdns

# install docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# run power_admin
docker run -d -e SECRET_KEY='a-very-secret-key' -v pda-data:/data -p 9191:80 powerdnsadmin/pda-legacy:latest
```
# PowerDNS installation
