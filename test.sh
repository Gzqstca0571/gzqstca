#!/bin/bash
dir1='/D:/Tomcat6/webapps'
dir2='/D:/Tomcat6_1/webapps'
dir3='/D:/Tomcat7/webapps'
dir4='/D:/Tomcat8_1/webapps'
for i in dir{1..4}
do
ls `eval echo '$'"${i}"`;
done

