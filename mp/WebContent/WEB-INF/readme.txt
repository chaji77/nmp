주요 서비스 설정 파일
---------------------------------------------------------------------------------------------

1. web.xml

(1) ResponseTransaction은 http로 접속될 수 있어야 함. ssl 인증서에 루트/체인이 없기 때문
(2) DataSource의 jdbc/mp은 kr.co.funology.fw.GlobalEnv의 변수와 맞춰야 함
(3) WEBROOT는 서버환경에 맞게 경로를 수정해야 하며, kr.co.funology.fw.GlobalEnv의 기본값도 맞춰줘야 쉘스크립트가 정상 작동

2. configuration.properties

(1) RESOURCE_VERSION는 js, css 등의 정적파일을 불러올때 캐쉬를 피하기 위한 변수임. 정적파일 수정 후 이 값을 조정해야 함
(2) 메일 : SMTP 이용(현재는 그룹웨어를 이용함)
(3) 세금계산서 : 바로빌의 계정을 이용. 쉘스크립트로 국세청전송여부를 바로빌로부터 받아오기 때문에 데이터베이스 설정값을 맞춰줘야 함
(4) 카카오톡 : KAKAO_SEND_PAGE를 통해 전송. 
(5) 해당파일은 kr.co.funology.fw.GlobalEnv 및 일부 쉘스크립트에서 호출되므로 경로가 참조되는 파일들에 유의할 것
(6) SYSTEM_CONSTRUCTION_YN은 서비스점검이 필요할 때 Y로 변경(/error/construct.htm으로 리다이렉션됨)

3. abnomaltransaction.properties

이상거래와 관련된 설정값들
거래단계별로 확인해야할 이상거래검증을 모듈화함
이상거래검증 이전에 확인해야할 항목들도 같이 정의함

4. environment.properties

전문전송과 관련된 설정값들

5. BillStatusReceiver.sh

바로빌로 전송된 세금계산서의 국세청전송여부를 조회하고 데이터베이스에 업데이트하는 쉘스크립트. 크론을 통해 5분마다 실행됨

6. MaturityNotification.sh

회원사에게 만기7일전, 만기당일 카카오톡으로 알리기 위한 쉘스크립트. 크론을 통해 매일 09:30분 실행됨
 
7. xmltemplate폴더

전문전송에 사용되는 전문스펙들

8. lib/mp-sdk.jar

개발환경에서는 존재하지 않지만, 서버환경에서는 classes 하위의 웹프로젝트 자바 리소스를 해당명칭의 jar파일로 묶어 관리함
필요에 따라 classes에 오버라이딩해서 사용

9. classes/log4j.properties

로그를 위한 설정값들

10. classes/kr/co/funology/fw/GlobalEnv.class

lib/mp_sdk.jre를 통합관리할 때, GlobalEnv 클래스가 각각의 서버에 맞게 변경될 수 있으므로
서버에 맞게 해당경로에 GlobalEnv.class을 업로드한 후 ROOT권한으로 변경(실수로 인한 업로드를 방지하기 위함), 오버라이드되도록 함.

11. 서버환경에 맞게 변경해야할 항목

(1) server.xml, web.xml
(2) configuration.properties, environment.properties, log4j.properties
(3) kr.co.funology.fw.GlobalEnv
(4) /static/js/common.js 의 strContextPath 변수
(5) 로고 등의 이미지 파일

