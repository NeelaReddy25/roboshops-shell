#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST="mongodb.neelareddy.store"

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

mkdir -p /app &>>$LOGFILE
VALIDATE $? "Creating directory"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>>$LOGFILE
VALIDATE $? "Downloading user files"

cd /app 
rm -rf /app/*
unzip /tmp/user.zip &>>$LOGFILE
VALIDATE $? "Extracting user code"

npm install &>>$LOGFILE
VALIDATE $? "Installing Nodejs dependencies"

cp /home/ec2-user/roboshops-shell/user.service /etc/systemd/system/user.service &>>$LOGFILE
VALIDATE $? "Copied user service "

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Daemon Reload"

systemctl enable user &>>$LOGFILE
VALIDATE $? "Enabling user"

systemctl start user &>>$LOGFILE
VALIDATE $? "Starting user"

cp /home/ec2-user/roboshops-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE
VALIDATE $? "Coping mongo repo"

dnf install -y mongodb-mongosh &>>$LOGFILE
VALIDATE $? "Installing MongoDB client"

mongosh --host $MONGODB_HOST </app/schema/user.js &>>$LOGFILE
VALIDATE $? "Loading user data into MongoDB"