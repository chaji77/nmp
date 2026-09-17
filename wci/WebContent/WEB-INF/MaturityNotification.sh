#!/bin/bash

cd /home/mp/WEB-INF/classes
java -classpath .:/home/mp/WEB-INF/lib/mp-sdk.jar batch.MaturityNotification M004 /home/mp/WEB-INF/configuration.properties
java -classpath .:/home/mp/WEB-INF/lib/mp-sdk.jar batch.MaturityNotification M005 /home/mp/WEB-INF/configuration.properties
