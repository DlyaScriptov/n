#!/bin/bash

nbicsNameDomain=A
#nbicsNameDataBase=A
nbicsPasswordDataBase=A

pwdScan=$(pwd)
hostnameScan=$(hostname)

read -p "Введите имя домена для NBICS: " nbicsNameDomain
#read -p "Введите имя базы данных: " nbicsNameDataBase
read -p "Введите пароль администратора базы данных: " nbicsPasswordDataBase

# ==================================================================


# 2. Последовательная проверка каталогов и файлов на существование
#    При необходимости - создание нужных каталогов и файлов
FILE=/home/download
if [ ! -d "$FILE" ]; then
    mkdir /home/download
    a1="+ 1. Создан каталог /home/download/"
else
    a2="- 1. Каталог /home/download/ уже существует, поэтому нет необходимости его создавать"
fi
# ........................................

FILE2=/var/www
if [ ! -d "$FILE2" ]; then
    mkdir /var/www
    a3="+ 2. Создан каталог /var/www/"
else
    a4="- 2. Каталог /var/www/ уже существует, поэтому нет необходимости его создавать"
fi

FILE3=/var/www/html
if [ ! -d "$FILE3" ]; then
    mkdir /var/www/html
    a5="+ 3. Создан каталог /var/www/html/"
else
    a6="- 3. Каталог /var/www/html/ уже существует, поэтому нет необходимости его создавать"
fi

cd /var/www/html
# ........................................

# 2.2. Эта проверка инвертирована
FILE4=$nbicsNameDomain
if [ -d "$FILE4" ]; then
    rm -rf $nbicsNameDomain
    a7="+ 4. Каталог /var/www/html/$nbicsNameDomain/ УЖЕ существует, поэтому удалён во избежание конфликтов"
else
    a8="- 4. Каталог /var/www/html/$nbicsNameDomain/ НЕ существует, и будет скопирован из /home/download/"
fi

cd $pwdScan
# ........................................

# 2.3. Проверка файла службы Kestrel на существование 
#      Не существует - создать, скопировать туда шаблон и вписать доменное имя 
#      Существует - очистить, скопировать туда шаблон и вписать доменное имя
FILE5=/etc/systemd/system/kestrel-"$nbicsNameDomain"-service.service
if [ ! -f "$FILE5" ]; then
    touch /etc/systemd/system/kestrel-"$nbicsNameDomain"-service.service
    cp ./files/kestrel-NAME_DOMAIN-service.service /etc/systemd/system/kestrel-"$nbicsNameDomain"-service.service
    sed -i -e "s|NAME_DOMAIN|$nbicsNameDomain|" /etc/systemd/system/kestrel-"$nbicsNameDomain"-service.service
    a9="+ 5. Файл /etc/systemd/system/kestrel-$nbicsNameDomain-service.service НЕ существует. Поэтому создан и заполнен актуальным текстом"
else
    echo -n > /etc/systemd/system/kestrel-"$nbicsNameDomain"-service.service
    cp ./files/kestrel-NAME_DOMAIN-service.service /etc/systemd/system/kestrel-"$nbicsNameDomain"-service.service
    sed -i -e "s|NAME_DOMAIN|$nbicsNameDomain|" /etc/systemd/system/kestrel-"$nbicsNameDomain"-service.service
    a10="- 5. Файл /etc/systemd/system/kestrel-$nbicsNameDomain-service.service УЖЕ существует. Поэтому очищен и заполнен актуальным текстом"
fi
# ........................................

# 2.4. Проверка файла default (для Nginx) на существование, заполнение актуальным текстом
FILE6=/etc/nginx/sites-available/default
if [ ! -f "$FILE6" ]; then
    touch /etc/nginx/sites-available/default
    cp ./files/default /etc/nginx/sites-available/default
    sed -i -e "s|NAME_DOMAIN|$nbicsNameDomain|" /etc/nginx/sites-available/default
    a11="+ 6. Файл /etc/nginx/sites-available/default НЕ существует. Поэтому создан и заполнен актуальным текстом"
else
    echo -n > /etc/nginx/sites-available/default
    cp ./files/default /etc/nginx/sites-available/default
    sed -i -e "s|NAME_DOMAIN|$nbicsNameDomain|" /etc/nginx/sites-available/default
    a12="- 6. Файл /etc/nginx/sites-available/default УЖЕ существует. Поэтому очищен и заполнен актуальным текстом"
fi
# ........................................

# 2.5. Проверка ссылки на файл default
FILE7=/etc/nginx/sites-enabled/default
if [ ! -L "$FILE7" ]; then
    ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
    a13="+ 7. Ссылочный ф айл /etc/nginx/sites-enabled/default НЕ существует, поэтому создан"
else
    a14="- 7. Ссылочный файл /etc/nginx/sites-enabled/default УЖЕ существует, поэтому не нуждается в создании"
fi
# ........................................

# 2.6. Создание каталогов для для базы данных
#      Предварительная проверка каталогов на существование
FILE8=/var/opt/db
if [ ! -d "$FILE8" ]; then
    mkdir /var/opt/db /var/opt/db/BACKUP /var/opt/db/DATA /var/opt/db/LOG
    chown -R mssql:mssql /var/opt/db/
    a15="+ 8. Создан каталог /var/opt/db/"
else
    rm -rf /var/opt/db
    mkdir /var/opt/db /var/opt/db/BACKUP /var/opt/db/DATA /var/opt/db/LOG
    chown -R mssql:mssql /var/opt/db/
    a16="- 8. Каталог /var/opt/db/ уже существует, поэтому удалён во избежание конфликтов. Создан новый каталог /var/opt/db/ с подкаталогами"
fi
# ==================================================================

# 3. Скачиваем архивы с сайтом и базой данных, а также файл SkiaSharp.dll
cd /home/download
FILElinks1=update-school-sample.nbics.net.zip
if [ ! -f "$FILElinks1" ]; then
    wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1OZgcIORQVUiB_dovBPPiyB2L3iuIWpuC' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\n/p')&id=1OZgcIORQVUiB_dovBPPiyB2L3iuIWpuC" -O update-school-sample.nbics.net.zip && rm -rf /tmp/cookies.txt
    a17="+ 9. Скачан архив с сайтом"
else
    a18="- 9. Архив с сайтом уже есть в каталоге /home/download/, поэтому не нуждается в скачивании"
fi

FILElinks2=TestDB.zip
if [ ! -f "$FILElinks2" ]; then
    wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1px2z-TirY15P_zkjE9KEbot5JYGCL8--' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\n/p')&id=1px2z-TirY15P_zkjE9KEbot5JYGCL8--" -O TestDB.zip && rm -rf /tmp/cookies.txt
    a19="+ 10. Скачан архив с базой данных"
else
    a20="- 10. Архив с базой данных уже есть в каталоге /home/download/, поэтому не нуждается в скачивании"
fi 

FILElinks3=SkiaSharp.dll
if [ ! -f "$FILElinks3" ]; then
    wget https://nbics.net/SiteResurses/BaseProject/SkiaSharp.dll
    a19a="+ 11. Скачан файл SkiaSharp.dll"
else
    a20a="- 11. Файл SkiaSharp.dll уже есть в каталоге /home/download/, поэтому не нуждается в скачивании"
fi 
# ==================================================================

# 4. Распаковываем архивы
# 4.1. Распаковываем архив с сайтом
unzip /home/download/update-school-sample.nbics.net.zip
a21="  12. Распакован архив с сайтом"
# ........................................

# 4.2. Распаковываем архив с базой данных
unzip /home/download/TestDB.zip
a22="  13. Распакован архив с базой данных"
# ==================================================================

# 5. Переименовываем каталог с сайтом (назначаем ему имя домена)
#    И меняем настройки в файле appsettings.json
# 5.1. Меняем настройки в файле appsettings.json
echo -n > /home/download/update-school-sample.nbics.net/appsettings.json
cd $pwdScan
cp ./files/appsettings.json /home/download/update-school-sample.nbics.net/appsettings.json
cd /home/download
sed -i -e "s|NAME_DOMAIN|$nbicsNameDomain|" ./update-school-sample.nbics.net/appsettings.json
sed -i -e "s|SA_PASSWORD_BD|$nbicsPasswordDataBase|" ./update-school-sample.nbics.net/appsettings.json
sed -i -e "s|NAME_SERVER|$hostnameScan|" ./update-school-sample.nbics.net/appsettings.json
sed -i -e "s|NAME_DATABASE|TestDB|" ./update-school-sample.nbics.net/appsettings.json
a23="  14. Очистка файла appsettings.json и заполнение его актуальным текстом"
# ........................................

# 5.2. Переименовываем каталог с сайтом
mv update-school-sample.nbics.net $nbicsNameDomain
a24="  15. Переименован каталог с сайтом (назначено ему такое же имя, как у домена)"
# ==================================================================

# 6. Копируем каталог с сайтом и базу данных и удаляем оригиналы
# 6.1. Копируем каталог с сайтом
cp -r $nbicsNameDomain /var/www/html/"$nbicsNameDomain"
a25="  16. Каталог с сайтом скопирован в /var/www/html/"
# ........................................

# 6.2. Копируем базу данных
cp TestDB.bak /var/opt/db/BACKUP/
a26="  17. База данных скопирована в /var/opt/db/BACKUP/"
# ........................................

# 6.3. [Позже реализовать цикл проверки копии и оригинала по размеру]
# ........................................

# 6.4. Удаляем распакованные оригиналы
rm -rf $nbicsNameDomain
rm -f TestDB.bak
a27="  18. Распакованные каталог с сайтом и база данных удалены из /home/download/"

cd $pwdScan
# ==================================================================

# 7. Увеличиваем ограничение на размер файлов для Nginx
sed -i -e "s|client_max_body_size 1000m||"  /etc/nginx/nginx.conf
sed -i -e '22a\    client_max_body_size 1000m'  /etc/nginx/nginx.conf
a28="  19. Увеличено до 1000 ограничение на размер файлов для Nginx"
# ==================================================================

# 8. Даём права для nginx на каталог с сайтом
chown -R www-data:www-data /var/www/
chmod -R 755 /var/www/
a29="  20. Выданы права для nginx на каталог с сайтом"
# ==================================================================

# 9. Перезагружаем службу Nginx
systemctl restart nginx
a30="  21. Перезагружена служба Nginx"
# ==================================================================

# 10. Устанавливаем DotNET
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm -f packages-microsoft-prod.deb
apt-get -y -q update
apt-get -y -q install dotnet-sdk-7.0
apt-get -y -q update
apt-get -y -q install aspnetcore-runtime-7.0
apt-get -y -q install libgdiplus
a31="  22. Установлены DotNET и библиотека libgdiplus"
# ==================================================================

# 11. Копируем файл SkiaSharp.dll в нужные каталоги и даём на него права
cp /home/download/SkiaSharp.dll /var/www/html/"$nbicsNameDomain"/
cp /home/download/SkiaSharp.dll /usr/lib/
cd /usr/lib/
chmod +x SkiaSharp.dll
cd $pwdScan
a32="  23. Скопирован файл SkiaSharp.dll в нужные каталоги и выданы на него права"


# 9. Устанавливаем SQL Server
#sed -i -e "s|<YourStrong!Passw0rd>|$nbicsPasswordDataBase|" ./files/mssql_install.sh
#sed -i -e "s|localhost|$hostnameScan|" ./files/mssql_install.sh

#source ./files/mssql_install.sh

echo -en "\033[32m ====================================================== \033[0m \n"
echo -en "\033[32m Скрипт завершён. Лог установки: \033[0m \n"
echo -en "\033[32m ------------------------------------------------------ \033[0m \n"
echo $a1
echo $a2
echo $a3
echo $a4
echo $a5
echo $a6
echo $a7
echo $a8
echo $a9
echo $a10
echo $a11
echo $a12
echo $a13
echo $a14
echo $a15
echo $a16
echo $a17
echo $a18
echo $a19
echo $a20
echo $a19a
echo $a20a
echo $a21
echo $a22
echo $a23
echo $a24
echo $a25
echo $a26
echo $a27
echo $a28
echo -en "\033[32m ====================================================== \033[0m \n"
