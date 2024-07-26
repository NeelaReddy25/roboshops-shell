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

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling Nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabling Nodejs"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing Nodejs"

id roboshop &>>$LOGFILE
if [ $? -ne 0 ]
then
    useradd roboshop &>>$LOGFILE
    VALIDATE $? "Creating roboshop user"
else
    echo -e "Roboshop user already created...$Y SKIPPING $N"
fi

rm -rf /app &>>$LOGFILE
VALIDATE $? "clean up existing directory"

mkdir -p /app &>>$LOGFILE
VALIDATE $? "Creating directory"

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>>$LOGFILE
VALIDATE $? "Downloading cart files"

cd /app  &>>$LOGFILE
VALIDATE $? "Moving to app directory"

unzip /tmp/cart.zip &>>$LOGFILE
VALIDATE $? "Extracting cart code"

npm install &>>$LOGFILE
VALIDATE $? "Installing Nodejs dependencies"

cp /home/ec2-user/roboshops-shell/cart.service /etc/systemd/system/cart.service &>>$LOGFILE
VALIDATE $? "Copied cart service "

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Daemon Reload"

systemctl enable cart &>>$LOGFILE
VALIDATE $? "Enabling cart"

systemctl start cart &>>$LOGFILE
VALIDATE $? "Starting cart"