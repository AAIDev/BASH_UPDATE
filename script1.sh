#!/bin/bash

SERVER_NAME=$1

while /root/Scripts/start.sh $SERVER_NAME
do
true
done
