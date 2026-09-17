프로그램명 : FTP를 이용한 담보데이터 수신기

개발환경 : 자바1.8, 메이븐
배포 : rcftp.war

설정방법 :
  [웹서버]
  rcftp.war를 /usr/local/tomcat/webapps에 저장하고 기다리면 rcftp 폴더가 생성된다.
  rcfpt/WEB-INF/web.xml의 WEBROOT의 값을 /usr/local/tomcat/webapps/rcftp으로 변경한다.
  rcfpt/WEB-INF/rcftp-configuration.properties를 열어 FILE_PATH를 /home으로, DB_NM을 데이터베이스이름으로 변경한다. 
  판매사의 코드로 사용자를 생성한다. 예를 들어, FUNOL이라는 사용자를 생성하면 /home/FUNOL이라는 폴더가 생성된다.
  rcfpt/WEB-INF/classes/log4j.properties를 필요에 맞게 설정한다. 예를 들면, 로그파일이 생성될 위치 등.
  JNDI 설정을 위해 /usr/local/tomcat/conf/server.xml과 context.xml에 jdbc/rcftp를 등록한다.
  톰캣을 재시작한다.
  [데이터베이스]
  DB_NM으로 설정된 데이터베이스에 접속해 "B2B_TRANS_ORDER_판매사코드", "B2B_TRANS_SETTLE_판매사코드" 테이블을 샘플에 맞게 생성한다.
  테이블에 JNDI에서 사용된 사용자에게 CRUD권한을 부여한다.
  판매사별 테이블을 B2B_TRANS_ORDER, B2B_TRANS_SETTLE에 추가하기 위한 별도의 예약 작업이 필요하다.

이용방법 :
  "index.jsp?sc=판매사코드"를 호출하면 실행된다.
  매매데이터는 판매사코드+B로 시작되는 파일이고, 결제데이터는 판매사코드+K로 시작되는 파일이다. 
  서버에서 cron으로 실행하려면, "curl https://도메인/rcftp/?sc=판매사코드"과 같은 방식으로 쉘스크립트를 작성하여 처리한다.
  
관리 :
  실행 후 파일이 삭제되도록 구현되어 있다. 만약 삭제가 안되었다면, 처리에 실패한 경우이다.
  시퀀스에 맞게 실행되어야 하므로 가장 오래된 파일부터 처리하도록 구현되어 있다. 
  만약 오류를 처리하지 않았다면, 같은 실패가 반복되므로 이를 모니터링할 방법을 별도로 구현하여야 한다.

참고 : 
  "담보보증전문매뉴얼.xlsx"는 담보보증데이터의 프로토콜이 정리되어 있다.
  "table_scheme_sample.txt"는 판매사별 테이블 생성을 위한 스키마 예제이다.
  "FUNOLB...", "FUNOLK..." 파일은 판매사가 제공해야할 최종 파일의 예제이다.
