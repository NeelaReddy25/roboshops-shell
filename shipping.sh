# #!/bin/bash

# USERID=$(id -u)
# TIMESTAMP=$(date +%F-%H-%M-%S)
# SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
# LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
# R="\e[31m"
# G="\e[32m"
# Y="\e[33m"
# N="\e[0m"
# MYSQL_HOST="mysql.neelareddy.store"

# # echo "Please enter DB Password:"
# # read -s mysql_root_password


# VALIDATE(){
#     if [ $1 -ne 0 ]
#     then
#         echo -e "$2...$R FAILURE $N"
#         exit1
#     else
#         echo -e "$2...$G SUCCESS $N"
#     fi
# }

# if [ $USERID -ne 0 ]
# then
#     echo "Please run this script with root access."
#     exit1 # manually exit if error comes.
# else
#     echo "You are super user."
# fi

# dnf install maven -y &>>$LOGFILE
# VALIDATE  $? "Installing Maven"

# id roboshop &>>$LOGFILE
# if [ $? -ne 0 ]
# then
#     useradd roboshop &>>$LOGFILE
#     VALIDATE $? "Creating roboshop user"
# else
#     echo -e "Roboshop user already created...$Y SKIPPING $N"
# fi

# rm -rf /app/* &>>$LOGFILE
# VALIDATE $? "clean up existing directory"

# mkdir -p /app &>>$LOGFILE
# VALIDATE $? "Creating directory"

# curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>>$LOGFILE
# VALIDATE $? "Downloading shipping code"

# cd /app  &>>$LOGFILE
# VALIDATE $? "Moving to app directory"


# unzip /tmp/shipping.zip &>>$LOGFILE
# VALIDATE $? "Extracting the shipping code"

# mvn clean package &>>$LOGFILE
# VALIDATE $? "Cleaning the packages"

# mv target/shipping-1.0.jar shipping.jar &>>$LOGFILE
# VALIDATE $? "Shipping jar file"

# cp /home/ec2-user/roboshops-shell/shipping.service /etc/systemd/system/shipping.service &>>$LOGFILE
# VALIDATE $? "Copied shipping service"

# systemctl daemon-reload &>>$LOGFILE
# VALIDATE $? "Daemon Reload"

# systemctl enable shipping &>>$LOGFILE
# VALIDATE $? "Enabling shipping"

# systemctl start shipping &>>$LOGFILE
# VALIDATE $? "Starting shipping"

# dnf install mysql -y &>>$LOGFILE
# VALIDATE $? "Installing MySQL server"

# # cp /home/ec2-user/roboshops-shell/shipping.sql /app/schema/shipping.sql &>>$LOGFILE
# # VALIDATE $? "Copied shipping sql"

# # mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/schema/shipping.sql  &>>$LOGFILE
# # VALIDATE $? "Schema loading"

# mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e "use cities" &>> $LOGFILE
# if [ $? -ne 0 ]
# then
#     echo "Schema is ... LOADING"
#     mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE
#     VALIDATE $? "Loading schema"
# else
#     echo -e "Schema already exists... $Y SKIPPING $N"
# fi

# systemctl restart shipping &>>$LOGFILE
# VALIDATE $? "Restarting shipping"

#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MYSQL_HOST="mysql.neelareddy.store"

VALIDATE(){
   if [ $1 -ne 0 ]
   then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access."
    exit 1 # manually exit if error comes.
else
    echo "You are super user."
fi


dnf install maven -y &>> $LOGFILE
VALIDATE $? "Installing Maven"

id roboshop &>> $LOGFILE
if [ $? -ne 0 ]
then
    useradd roboshop &>> $LOGFILE
    VALIDATE $? "Adding roboshop user"
else
    echo -e "roboshop user already exist...$Y SKIPPING $N"
fi

rm -rf /app &>> $LOGFILE
VALIDATE $? "clean up existing directory"

mkdir -p /app &>> $LOGFILE
VALIDATE $? "Creating app directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? "Downloading shipping application"

cd /app  &>> $LOGFILE
VALIDATE $? "Moving to app directory"

unzip /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "Extracting shipping application"

mvn clean package &>> $LOGFILE
VALIDATE $? "Packaging shipping"

mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
VALIDATE $? "Renaming the artifact"

cp /home/ec2-user/roboshops-shell/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "Copying service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Daemon reload"

systemctl enable shipping  &>> $LOGFILE
VALIDATE $? "Enabling shipping"

systemctl start shipping &>> $LOGFILE
VALIDATE $? "Starting shipping"

dnf install mysql -y &>> $LOGFILE
VALIDATE $? "Installing MySQL"

# cp /home/ec2-user/roboshops-shell/shipping.sql /app/schema/shipping.sql &>>$LOGFILE
# VALIDATE $? "Copied shipping sql"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/schema/shipping.sql  &>>$LOGFILE
VALIDATE $? "Schema loading"

# mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e "use cities" &>> $LOGFILE
# if [ $? -ne 0 ]
# then
#     echo "Schema is ... LOADING"
#     mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE
#     VALIDATE $? "Loading schema"
# else
#     echo -e "Schema already exists... $Y SKIPPING $N"
# fi

systemctl restart shipping &>> $LOGFILE
VALIDATE $? "Restarted Shipping"