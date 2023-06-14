nbicsNameDomain=A
nbicsNameDataBase=A
nbicsPasswordDataBase=A

pwdScan=$(pwd)
hostnameScan=$(hostname)

read -p "Введите имя домена для NBICS: " nbicsNameDomain
read -p "Введите имя базы данных: " nbicsNameDataBase
read -p "Введите пароль администратора базы данных: " nbicsPasswordDataBase

apt-get -y -q install curl
apt-get -y -q install apt-transport-https
apt-get -y -q install ufw

ufw default deny incoming
ufw default allow outgoing
ufw allow 8080/tcp
ufw allow 8443/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 3478
ufw allow 40000:57000/tcp
ufw allow 40000:57000/udp
ufw allow 57001:65535/tcp
ufw allow 57001:65535/udp
ufw allow 1433
ufw allow from 127.0.0.1 to any port 1433
ufw enable
ufw delete allow 1433

FILE=/home/download
if [ ! -d "$FILE" ]; then
    mkdir /home/download
fi




