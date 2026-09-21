#!/bin/bash

RESULT=`curl -sS -L -w "\nHTTP_STATUS:%{http_code}" "http://localhost:8080/mp/mgr/etax/TaxAutoPublishTrigger.jsp?token=BILL_AUTO_SEND_MP1" 2>&1`

today=`date`
echo "run TaxAutoPublish in " $today " : " $RESULT >> /home/logs/TaxAutoPublish.log
