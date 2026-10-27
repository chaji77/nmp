#!/bin/bash
# 싸이클론 대출상환 안내문자 (7일전, 당일)
# crontab : 0 9 * * * /home/mp/WEB-INF/CyclnMaturitySms.sh
# 서버 자신에서 Tomcat 으로 바로 부른다. 포트는 서버의 Tomcat HTTP 포트에 맞춘다.

URL="http://localhost:8080/mp/common/CyclnMaturitySms.jsp"

curl -s "$URL?days=7"
echo
curl -s "$URL?days=0"
echo
