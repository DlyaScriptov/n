nbicsNameDomain=A
#nbicsNameDataBase=A
nbicsPasswordDataBase=A

pwdScan=$(pwd)
hostnameScan=$(hostname)

read -p "Введите имя домена для NBICS: " nbicsNameDomain
#read -p "Введите имя базы данных: " nbicsNameDataBase
read -p "Введите пароль администратора базы данных: " nbicsPasswordDataBase

apt-get -y -q install mlocate
apt-get -y -q install curl
apt-get -y -q install apt-transport-https
apt-get -y -q install ufw

# 1. Открытие портов
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

# 2. Последовательная проверка каталогов и файлов на существование
FILE=/home/download
if [ ! -d "$FILE" ]; then
    mkdir /home/download
fi

FILE2=/var/www
if [ ! -d "$FILE2" ]; then
    mkdir /var/www
fi

FILE3=/var/www/html
if [ ! -d "$FILE3" ]; then
    mkdir /var/www/html
fi

cd /var/www/html

# 2.1. Эта проверка инвертирована
FILE4=$nbicsNameDomain
if [ -d "$FILE4" ]; then
    rm -rf $nbicsNameDomain
fi

cd $pwdScan

FILE5=/etc/systemd/system/kestrel-"$nbicsNameDomain"-service.service
if [ ! -d "$FILE5" ]; then
    touch /etc/systemd/system/kestrel-"$nbicsNameDomain"-service.service
else
    echo -n > /etc/systemd/system/kestrel-"$nbicsNameDomain"-service.service
    cp ./n/files/kestrel-NAME_DOMAIN-service.service /etc/systemd/system/kestrel-"$nbicsNameDomain"-service.service
fi

# 3. Заполняем файл службы Kestrel из шаблона
cp ./n/files/kestrel-NAME_DOMAIN-service.service /etc/systemd/system/kestrel-"$nbicsNameDomain"-service.service

# 4. Вписываем имя домена в шаблон файла службы Kestrel
sed -i -e "s|NAME_DOMAIN|$nbicsNameDomain|" /etc/systemd/system/kestrel-"$nbicsNameDomain"-service.service

