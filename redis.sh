#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2...$R FALIURE $N"
        exit1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access."
    exit1 # manually exit if error comes.
else
    echo "You are super user."
fi

dnf install redis -y &>>$LOGFILE
VALIDATE $? "Installing redis"

sed -i 's/127.0.0.0/0.0.0.0/g' /etc/redis/redis.conf &>>$LOGFILE
VALIDATE $? "Remote server access"

systemctl enable redis &>>$LOGFILE
VALIDATE $? "Enabling redis"

systemctl start redis &>>$LOGFILE
VALIDATE $? "Starting redis"