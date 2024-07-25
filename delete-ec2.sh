#!/bin/bash

source ./create-ec2.sh

aws ec2 terminate-instances --instance-ids $instance_id