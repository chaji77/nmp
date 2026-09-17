#!/bin/bash

cd /home/mp/WEB-INF/classes
java -classpath .:/usr/local/tomcat/lib/sqljdbc4.jar:/home/mp/WEB-INF/lib/barobill-api-sdk-java8.jar:/home/mp/WEB-INF/lib/mp-sdk.jar batch.BillStatus MPONE /home/mp/WEB-INF/configuration.properties

today=`date`
echo "run BillStatusReceiver in " $today >> /home/logs/BillStatusReceiver.log
