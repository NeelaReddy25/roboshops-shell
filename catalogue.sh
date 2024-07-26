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
VALIDATE $? "Disabling current nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabling nodejs:20"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing Nodejs"

id roboshop &>>$LOGFILE
if [ $? -ne 0 ]
then
    useradd roboshop &>>$LOGFILE
    VALIDATE $? "Adding roboshop user"
else
    echo -e "Roboshop user already created...$Y SKIPPING $N"
fi
rm -rf /app &>>$LOGFILE
VALIDATE $? "clean up existing directory"

mkdir -p /app &>>$LOGFILE
VALIDATE $? "Creating directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>>$LOGFILE
VALIDATE $? "Downloading catalogue files"

cd /app  &>>$LOGFILE
VALIDATE $? "Moving to app directory"

unzip /tmp/catalogue.zip &>>$LOGFILE
VALIDATE $? "Extracting catalogue code"

npm install &>>$LOGFILE
VALIDATE $? "Installing Nodejs dependencies"

cp /home/ec2-user/roboshops-shell/catalogue.service /etc/systemd/system/catalogue.service &>>$LOGFILE
VALIDATE $? "Copied catalogue service "

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Daemon Reload"

systemctl enable catalogue &>>$LOGFILE
VALIDATE $? "Enabling catalogue"

systemctl start catalogue &>>$LOGFILE
VALIDATE $? "Starting catalogue"

cp /home/ec2-user/roboshops-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE
VALIDATE $? "Coping mongo repo"

dnf install -y mongodb-mongosh &>>$LOGFILE
VALIDATE $? "Installing MongoDB client"

SCHEMA_EXISTS=$(mongosh --host $MONGODB_HOST --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')") &>> $LOGFILE

if [ $SCHEMA_EXISTS -lt 0 ]
then
    echo "Schema does not exists ... LOADING"
    mongosh --host $MONGODB_HOST </app/schema/catalogue.js &>> $LOGFILE
    VALIDATE $? "Loading catalogue data"
else
    echo -e "schema already exists... $Y SKIPPING $N"
fi