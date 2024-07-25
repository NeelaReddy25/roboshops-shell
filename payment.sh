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
        echo -e "$2...$R FAILURE $N"
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

dnf install python36 gcc python3-devel -y &>>$LOGFILE
VALIDATE $? "Installing python"

id roboshop &>>$LOGFILE
if [ $? -ne 0 ]
then
    useradd roboshop &>>$LOGFILE
    VALIDATE $? "Creating roboshop user"
else
    echo -e "Roboshop user already created...$Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGFILE
VALIDATE $? "Creating app directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>>$LOGFILE
VALIDATE $? "Downloading payment code"

cd /app 
rm -rf /app/*
unzip /tmp/payment.zip &>>$LOGFILE
VALIDATE $? "Extracting the payment code"

pip3.6 install -r requirements.txt &>>$LOGFILE
VALIDATE $? "Installing python requirements"

cp /home/ec2-user/roboshop-shell/api-tier/payment.service /etc/systemd/system/payment.service &>>$LOGFILE
VALIDATE $? "Copied payment service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Daemon Reload"

systemctl enable payment &>>$LOGFILE
VALIDATE $? "Enabling payment"

systemctl start payment &>>$LOGFILE
VALIDATE $? "Starting payment"
