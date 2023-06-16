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
apt-get -y -q install unzip

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
     # При необходимости - создание нужных каталогов и файлов
FILE=/home/download
if [ ! -d "$FILE" ]; then
    mkdir /home/download
fi

# 2.1. Проверяем, установлен ли веб-сервер Nginx
       # Если нет - удаляем возможные остатки программы, и устанавливаем с нуля
nginxCheckInstall=$(locate --basename '\nginx')

checkVarNginxCheck=`cat <<_EOF_
/etc/nginx
/etc/default/nginx
/etc/init.d/nginx
/etc/logrotate.d/nginx
/etc/ufw/applications.d/nginx
/usr/lib/nginx
/usr/sbin/nginx
/usr/share/nginx
/usr/share/doc/nginx
/var/lib/nginx
/var/log/nginx
_EOF_
`
if [[ ! $nginxCheckInstall = $checkVarNginxCheck ]]
then
    systemctl stop nginx
    systemctl disable nginx
    apt-get -y -q purge nginx nginx-common
    apt-get -y -q autoremove
    rm -Rf /etc/nginx/*
    
    apt-get -y -q install nginx
    systemctl enable nginx
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

# 2.2. Эта проверка инвертирована
FILE4=$nbicsNameDomain
if [ -d "$FILE4" ]; then
    rm -rf $nbicsNameDomain
fi

cd $pwdScan

# 2.3. Проверка файла службы Kestrel еа существование 
       # Не существует - создать, скопировать туда шаблон и вписать доменное имя 
       # Существует - очистить, скопировать туда шаблон и вписать доменное имя
FILE5=/etc/systemd/system/kestrel-"$nbicsNameDomain"-service.service
if [ ! -d "$FILE5" ]; then
    touch /etc/systemd/system/kestrel-"$nbicsNameDomain"-service.service
    cp ./n/files/kestrel-NAME_DOMAIN-service.service /etc/systemd/system/kestrel-"$nbicsNameDomain"-service.service
    sed -i -e "s|NAME_DOMAIN|$nbicsNameDomain|" /etc/systemd/system/kestrel-"$nbicsNameDomain"-service.service
else
    echo -n > /etc/systemd/system/kestrel-"$nbicsNameDomain"-service.service
    cp ./n/files/kestrel-NAME_DOMAIN-service.service /etc/systemd/system/kestrel-"$nbicsNameDomain"-service.service
    sed -i -e "s|NAME_DOMAIN|$nbicsNameDomain|" /etc/systemd/system/kestrel-"$nbicsNameDomain"-service.service
fi

# 2.4. Проверка файла default (для Nginx) на существование, заполнение актуальным текстом
FILE6=/etc/nginx/sites-available/default
if [ ! -d "$FILE6" ]; then
    touch /etc/nginx/sites-available/default
    cp ./n/files/default /etc/nginx/sites-available/default
    sed -i -e "s|NAME_DOMAIN|$nbicsNameDomain|" /etc/nginx/sites-available/default
else
    echo -n > /etc/nginx/sites-available/default
    cp ./n/files/default /etc/nginx/sites-available/default
    sed -i -e "s|NAME_DOMAIN|$nbicsNameDomain|" /etc/nginx/sites-available/default
fi

# 2.5. Создание каталогов для для базы данных
       # Предварительная проверка каталогов на существование
FILE7=/var/opt/db
if [ ! -d "$FILE7" ]; then
    mkdir /var/opt/db /var/opt/db/BACKUP /var/opt/db/DATA /var/opt/db/LOG
else
    rm -rf /var/opt/db
    mkdir /var/opt/db /var/opt/db/BACKUP /var/opt/db/DATA /var/opt/db/LOG
fi

# 3. Скачиваем архивы с сайтом и базой данных
# 3.1. Скачиваем архив с сайтом
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1OZgcIORQVUiB_dovBPPiyB2L3iuIWpuC' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\n/p')&id=1OZgcIORQVUiB_dovBPPiyB2L3iuIWpuC" -O update-school-sample.nbics.net.zip && rm -rf /tmp/cookies.txt

# 3.2. Скачиваем архив с базой данных
wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1px2z-TirY15P_zkjE9KEbot5JYGCL8--' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\n/p')&id=1px2z-TirY15P_zkjE9KEbot5JYGCL8--" -O TestDB.zip && rm -rf /tmp/cookies.txt

