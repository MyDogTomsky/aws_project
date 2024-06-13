#!/bin/bash

# Using EC2, Flyway for migration from S3 Bucket Object to RDS

# Input needed Variables
# File PATH // RDS location, name // RDS master id,pwd
S3_URI=s3://cc-migration-bucket/V1__shopwise.sql
RDS_ENDPOINT=shopwisedb.cnm6gioeyk8n.eu-west-1.rds.amazonaws.com
RDS_DB_NAME=shopwisedb
RDS_DB_USERNAME=dbadmin
RDS_DB_PASSWORD=data7006!

# Preparation the environment(Update & Flyway)
sudo dnf update -y
sudo $ wget -qO- https://download.red-gate.com/maven/release/com/redgate/flyway/flyway-commandline/10.13.0/flyway-commandline-10.13.0-linux-x64.tar.gz | tar -xvz

# Flyway Symbolic link to access globally 
sudo ln -s `pwd`/flyway-10.13.0/flyway /usr/local/bin 

# Create 'migration' Directory for Copy Object from S3
sudo mkdir migration
sudo aws s3 cp "$S3_URI" migration/

# ~/. ==> Flyway Directory and migration Directory are located.
# Flyway migration from 'migration' Directory to AWS RDS
flyway -url=jdbc:mysql://"$RDS_ENDPOINT":3306/"$RDS_DB_NAME" \
  -user="$RDS_DB_USERNAME" \
  -password="$RDS_DB_PASSWORD" \
  -locations=filesystem:migration \
  migrate