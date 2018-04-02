#!/bin/sh

VERSION=0

if grep -q -s -i "release 7" /etc/redhat-release ; then
    VERSION="7"
elif grep -q -s -i "release 6" /etc/redhat-release ; then
    VERSION="6"
else
    echo "This script is written for RHEL & CentOS 6/7 only, sorry";
    exit 9;
fi

yum install -y mailx

groupadd -g 6999 pika ;
useradd -u 6999 -g 6999 pika ;

if [ "$VERSION" -eq "7" ] ; then
    curl https://raw.githubusercontent.com/runwuf/pikaO/master/pikaO7.sh > /home/pika/pikaO.sh
elif [ "$VERSION" -eq "6" ] ; then
    curl https://raw.githubusercontent.com/runwuf/pikaO/master/pikaO6.sh > /home/pika/pikaO.sh
fi

chmod 700 /home/pika/pikaO.sh
chown pika: /home/pika/pikaO.sh

#if ! ping -q -c 1 -W 1 www.google.com > /dev/null ; then
#    echo "This machine cannot reach internet, using internal SMTP server..."
#    sed -i s/"SMTP=''"/"SMTP=\'-S smtp=smtp.talusfield.home\'"/g /home/pika/pika.sh
#fi

cat > /var/spool/cron/pika << EOF
*/10 * * * * /home/pika/pikaO.sh
EOF

chmod 600 /var/spool/cron/pika
chown pika: /var/spool/cron/pika

su pika -c "/home/pika/pikaO.sh -v"
su pika -c "crontab -l"
echo "pikaO is installed! remember to edit /home/pika/pikaO.sh to change the email address and calling threshold as you like!";
