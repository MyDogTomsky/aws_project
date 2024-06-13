# Using Apache, phpMyAdmin to Enable static website to be Dynmaic

### (1) prepare LAMP server 

sudo dnf update -y
sudo dnf install -y httpd 
sudo dnf install -y wget php-fpm php-mysqli php-json php php-devel 
sudo dnf install -y mariadb105-server
sudo systemctl enable httpd mariadb
sudo systemctl start httpd mariadb

## File, Directory Authorisation Configuration 
## usermod(ec2-user) -> chown -> chmod(2775/0664): Read & Write

# ec2-user@ -> Being Granted Authorisation by Being Added to -Group apache.
sudo usermod -a -G apache ec2-user

# Assigning Ownership(access) of /var/www to ec2-user and apache group
sudo chown -R ec2-user:apache /var/www


# Granting the appropriate Permissions to Directory and Files [2775/0664]
sudo chmod 2775 /var/www  
sudo find /var/www -type d -exec chmod 2775 {} \;
sudo find /var/www -type f -exec chmod 0664 {} \;

# Preparation Complete
exit 

### (2) Test the LAMP server & Secure the DB server

# Checking if MySQL-related apps are installed
ssh ec2-user@webserverprivate ip
groups
sudo dnf list installed mariadb105-server php-mysqlnd
sudo mysql_secure_installation


### (3) Install phpMyAdmin

sudo dnf install -y php-mbstring php-xml
sudo systemctl restart httpd php-fpm


## Going to Web Server files Location & installing phpMyAdmin
cd /var/www/html
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
mkdir phpMyAdmin && tar -xvzf phpMyAdmin-latest-all-languages.tar.gz -C phpMyAdmin --strip-components 1
rm phpMyAdmin-latest-all-languages.tar.gz
sudo systemctl start mariadb


### (4) Allowing .httpd.conf file to Override the Configuration 
##              Enabling Dynamic Functionality and applying specific Configuration Changes!
#       Apache configuration Automation: sudo sed -i 'The Change command' /etc/httpd/conf/httpd.conf 
sudo sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf

### (5) Web Files Synchronisation, Authorisaion // Configuring environment variables
## Creating new S3 bucket & Upload Web Zip file  
# Let the server know variable[s3 Name]
S3_BUCKET_NAME=cc-shopwise-web-bucket

# Synchronisation from S3 Bucket to new Directory on Web Server EC2
sudo aws s3 sync s3://"$S3_BUCKET_NAME" /var/www/html

# Deployment: Moving to html to deploy the web files under /var/www/html
cd /var/www/html
sudo unzip shopwise.zip -d shopwise-temp
sudo cp -R shopwise-temp/shopwise/. /var/www/html/
sudo rm -rf shopwise-temp shopwise.zip

## Granting access the storage directory for Data Management & Updating the Authorisation
sudo chmod 2775 /var/www/html/storage  
sudo find /var/www/html -type d -exec chmod 2775 {} \;
sudo find /var/www/html -type f -exec chmod 0664 {} \;

## Configuring Environment Variables  & Checking cat .env
# .env  ==> APP_URL = load balancer / APP_env = production / 
#           DB_HOST = RDS Endpoint  / DB_name & RDS Mater ID,pwd //
sudo vi .env
#--> APP_URL=http://localhost ===> APP_URL=http://LoadBalancer's DNS
#--> DB_CONNECTION=mysql
#--> ** DB_HOST= A IP ADDRESS ===> DB_HOST= RDS'S Endpoint
#--> ** DB_DATABASE=          ===> RDS's configuration > DB name
#--> ** RDS'S Master Name, Pwd

### (6) Apache Updating and new Start!
sudo service httpd restart 