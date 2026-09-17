<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ include file="../web/includes/Header.jsp" %>
<!-- page head block -->
<title>기초매뉴얼</title>
</head>
<body style='padding:30px;color:#000;'>

<%@ include file='tab.jsp' %>

<h1>기초매뉴얼</h1>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p><strong><span style="font-size:12pt">1. 서버설정</span></strong></p>
<p>&nbsp;</p>
<p>- 웹 서버는 nginx, 어플리케이션 서버는 tomcat으로 구성.</p>
<p>&nbsp; &nbsp;&nbsp;<span style="color:#e74c3c"><strong>[★★★ 주의 : 톰캣 실행/종료/재시작 방법 변경됨]</strong> </span>systemctl start|stop|restart tomcat</p>
<p>&nbsp;</p>
<p>(1) 톰캣</p>
<p>&nbsp; &nbsp; &nbsp;설치 버전 : 9.0.102.0</p>
<p>&nbsp; &nbsp; &nbsp;server.xml 중 데이터베이스 연결설정 (주요 및 변경 사항만)</p>
<p>&nbsp; &nbsp; &nbsp;</p>
<p>&nbsp; &nbsp; &nbsp;- 192.168.1.57로 연결</p>
<p>&nbsp; &nbsp; &nbsp;- 보안추가 : encrypt=true;trustServerCertificate=true;</p>
<p>&nbsp;</p>
<p style='margin-left:12px;border:1px solid #aaa;padding:20px;'>url=&quot;jdbc:sqlserver://<strong><span style="color:#e74c3c">192.168.1.57</span></strong>:1433;databaseName=MP;<strong><span style="color:#e74c3c">encrypt=true;trustServerCertificate=true;</span></strong>&quot;</p>
<p>&nbsp;</p>
<p>&nbsp; &nbsp; &nbsp;- 톰캣 메모리 추가설정 (/usr/local/tomcat/bin/setenv.sh) 및 실행권한 추가</p>
<p>&nbsp;</p>
<p style='margin-left:12px;border:1px solid #aaa;padding:20px;'>export CATALINA_OPTS=&quot;-Xms4096m -Xmx6144m -XX:MetaspaceSize=512m -XX:MaxMetaspaceSize=1024m&quot;</p>
<p>&nbsp;</p>
<p>(2) MSSQL-JDBC 드라이버 : /usr/local/tomcat/lib/mssql-jdbc-12.8.1.jre8.jar (예전 드라이버 사용할 수 없음)</p>
<p>&nbsp;</p>
<p>(3) 내부 네트워크 설정 확인 후 설정되어 있지 않으면 추가</p>
<p>&nbsp; &nbsp; &nbsp;vi /etc/netplan/00-installer-config.yaml</p>
<p>&nbsp;</p>
<pre style='margin-left:12px;border:1px solid #aaa;padding:20px;'>
  enp3s0f1:
          dhcp4: no
  addresses:
          - 192.168.1.68/24
</pre>
<p>&nbsp; &nbsp; &nbsp;재시작 : netplan apply</p>
<p>&nbsp; &nbsp; &nbsp;권한문제가 있는 경우 권한 수정 : chmod 600 /etc/netplan/00-installer-config.yaml</p>
<p>&nbsp; &nbsp; &nbsp;리부팅후 192.168.1.68가 설정되었는지 확인할 필요 있음. 안되어 있으면 임시로 ip addr add 192.168.1.68/24 dev enp3s0f1 적용</p>
<p>&nbsp;</p>
<p>(4) nginx 설치 및 설정 (/etc/nginx/conf.d/default.conf 참조)</p>
<p>&nbsp; &nbsp;&nbsp;<span style="color:#e74c3c"><strong>[주의]</strong> </span>전문통신을 위해 http도 유지되어야 함</p>
<p>&nbsp; &nbsp;&nbsp;<span style="color:#e74c3c"><strong>[주의]</strong> </span>담보 대기업 데이터 수신을 위해 7077포트도 유지되어야 함</p>
<p>&nbsp; &nbsp;&nbsp;레거시 시스템 사용자의 즐겨찾기에 대응하기 위해 /guarantee_sys, /guarantee_sys2 경로에 대한 예외처리 부분 확인 필요</p>
<p>&nbsp; &nbsp;&nbsp;systemctl enable nginx (리부팅시 자동실행 설정)</p>
<p>&nbsp;</p>
<p>(5) tomcat 서비스 데몬 등록</p>
<p>&nbsp; &nbsp;&nbsp;vi /etc/systemd/system/tomcat.service 참조</p>
<p>&nbsp; &nbsp;&nbsp;systemctl daemon-reexec</p>
<p>&nbsp; &nbsp;&nbsp;systemctl daemon-reload</p>
<p>&nbsp; &nbsp;&nbsp;systemctl enable tomcat (리부팅시 자동실행 설정)</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p><strong><span style="font-size:12pt">2. SSH 및 FTP 접속</span></strong></p>
<p>&nbsp;</p>
<p>(1) SSH접속계정 djemals 추가(비번 동일)</p>
<p>&nbsp; &nbsp; &nbsp;root 대신 sudo su로 접근할 것 (비번은 djemals과 동일)</p>
<p>(2) 소스업로드 (/home/mp)</p>
<p>&nbsp; &nbsp; &nbsp;소유주는 djemals</p>
<p>&nbsp; &nbsp; &nbsp;FTP접속방법 : SFTP로 접속(djemals)</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p><strong><span style="font-size:12pt">3. 전문 송수신</span></strong></p>
<p>&nbsp;</p>
<p>- 신보(210.112.124.64)와 기보(210.112.124.45) 게이트웨이는 별도로 구성</p>
<p>- 결제전문 등 수신은 웹서버로 전송되도록 설정됨</p>
<p>&nbsp;</p>
<p>(1) 설정 등은 WEB-INF/environment.properties 참고</p>
<p>(2) 전문 수신 리시버 설정 (WEB-INF/web.xml)</p>
<p>&nbsp;</p>
<pre style='margin-left:12px;border:1px solid #aaa;padding:20px;'>
  &lt;servlet&gt;
    &lt;servlet-name&gt;ResponseTransaction&lt;/servlet-name&gt;
    &lt;servlet-class&gt;kr.co.soap.kodit.ResponseTransaction&lt;/servlet-class&gt;
  &lt;/servlet&gt;
  &lt;servlet-mapping&gt;
    &lt;servlet-name&gt;ResponseTransaction&lt;/servlet-name&gt;
    &lt;url-pattern&gt;/ResponseTransaction&lt;/url-pattern&gt;
  &lt;/servlet-mapping&gt;
</pre>
<p>&nbsp;</p>
<p>(3) 전문 탬플릿은 WEB-INF/xmltemplate 참조</p>
<p>(4) 전문 전송은 web/transaction 폴더의 jsp 파일을 통해 이루어짐</p>
<p>&nbsp;</p>
<p><span style="font-size:12pt"><strong>4. 서버별 설정 및 하드코딩</strong></span></p>
<p>&nbsp;</p>
<p>(1) WEB-INF 밑에 configuration.properties, environment.properties 등을 서버환경에 맞게 수정해야 함</p>
<p>(2) 전자서명관련부분 수정(/home/mp/static/programs/SecuKitNXS/KICA/config/nx_config.js, 테스트라이센스인지 리얼라이센스인지 확인 필요)</p>
<p>(3) 거래와 관련한 하드코딩은&nbsp;web/trade/ContractReg.js에 모두 있음</p>
<p>&nbsp; &nbsp; &nbsp;- 신보일반자금상품 이용시 세금계산서 첨부 예외 판매사의 회원아이디</p>
<p>&nbsp; &nbsp; &nbsp;- 세금계산서 31일 제한 상품코드 (구매자금)</p>
<p>&nbsp; &nbsp; &nbsp;- 신보일반자금상품코드</p>
<p>&nbsp; &nbsp; &nbsp;- 비보증상품코드 (세금계산서첨부예외)</p>
<p>&nbsp; &nbsp; &nbsp;- 비보증상품 중 세금계산서첨부가 의무인 은행 및 상품 코드</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p><strong><span style="font-size:12pt">5. 카카오톡</span></strong></p>
<p>&nbsp;</p>
<p>(1) configuration.properties의 ETAX_RELEASE_YN, ETAX_KEY, KAKAO_CHANNEL_ID, KAKAO_SEND_PAGE 확인</p>
<p>(2) 탬플릿 호출에 소요되는 시간이 적지 않아 탬플릿을 서버내에 보관함</p>
<p>&nbsp; &nbsp; &nbsp;-&nbsp;<span style="color:#e74c3c">탬플릿이 변경되면</span>? 웹에서 서버의 common/kakaotalk/MakeTemplates.jsp를 실행한 후 카카오톡 탬플릿이 /home/mp/WEB-INF/kakaotemplates.xml에 저장되는지 확인</p>
<p>(3) 모든 카톡메시지는 common/kakaotalk/Send.jsp를 통해 송출</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p><strong><span style="font-size:12pt">6. 프로세스 메일</span></strong></p>
<p>&nbsp;</p>
<p>(1) 그룹웨어의 mailadmin@mp1.co.kr 계정을 사용</p>
<p>(2)&nbsp;카톡과 함께 프로세스메일이 전송됨 (common/kakaotalk/Send.jsp 참조)</p>
<p>(3) 탬플릿은 static/template/mail 폴더 참조</p>
<p>(4) 카카오톡과 동시에 전송할 프로세스 메일은&nbsp;common/kakaotalk/Send.jsp의&nbsp;mailTemplates 변수에 정의</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p><strong><span style="font-size:12pt">7. cron 작업</span></strong></p>
<p>&nbsp;</p>
<p>(1) vi /etc/crontab으로 아래 내용 추가</p>
<p>
  <pre style='margin-left:12px;border:1px solid #aaa;padding:20px;'>
  0 5 * * * root /home/djemals/daily-server-report.sh
  */10 * * * * root /home/mp/WEB-INF/BillStatusReceiver.sh (68번 전용)
  30 9 * * * root /home/mp/WEB-INF/MaturityNotification.sh (68번 전용)
  */10 *  * * *   root    curl https://w2.mp1.co.kr/mp/firstbill/UpdateBillStatus.jsp (68번 전용)
  </pre>
</p>
<p>&nbsp;</p>
<p>(2) daily-server-report.sh : 일별 서버현황 보고, 로그파일정리, 디비백업 등을 실행. <span style="color:#e74c3c"><strong>[주의]</strong></span> 다른 웹서버에서는 데이터베이스 백업 부분을 주석처리해야 함.</p>
<p>(3) BillStatusReceiver.sh : 바로빌로 전송된 세금계산서의 발행상태를 업데이트. <span style="color:#e74c3c"><strong>[주의]</strong></span> 하나의 웹서버에서만 구동되어야 함</p>
<p>(4) MaturityNotification.sh : 만기일 자동 알림. <span style="color:#e74c3c"><strong>[주의]</strong></span> 하나의 웹서버에서만 구동되어야 함</p>
<p>(5) UpdateBillStatus.jsp : 포스코용 바로빌 발행상태 업데이트. <span style="color:#e74c3c"><strong>[주의]</strong></span> 하나의 웹서버에서만 구동되어야 함</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p><strong><span style="font-size:12pt">8. 도메인 관련 [실제 운영시 변경 필요]</span></strong></p>
<p>&nbsp;</p>
<p>(1) https로 변경해서 이동하도록 수정해야 함 (/usr/local/tomcat/webapps/ROOT/index.jsp)</p>
<p>(2) 로그자동정리 : /home/djemals/daily-server-report.sh 가 cron에 의해 실행되면 불필요해진 로그를 정리함. 내용 확인 후 로그 정리 주기 등을 수정</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p><strong><span style="font-size:12pt">9. configuration.properties 관련 주요 설명</span></strong></p>
<p>&nbsp;</p>
<p style="margin-left:40px">- RESOURCE_VERSION=css나 js 등 캐시를 타는 정적 파일을 수정한 경우 버전을 수정</p>
<p style="margin-left:40px">- SYSTEM_CONSTRUCTION_YN=웹을 공사중 상태로 돌리려면 Y로 변경</p>
<p style="margin-left:40px">- BILL_SCRAP_FAIL_YN=세금계산서 스크래핑에 문제가 있는 경우 Y로 변경하면 XML업로드 허용</p>
<p style="margin-left:40px">- DOMAIN_URL=웹에서 참조하는 도메인. 서버의 분산을 위해 w1, w2 등으로 처리해야 함 (예, https://n.mp1.co.kr)</p>
<p style="margin-left:40px">- UPLOAD_FILE_URL=웹에서 참조하는 업로드 파일의 경로. 파일을 분산하기 위해 w1, w2 등으로 처리해야 함 (예, https://n.mp1.co.kr/mp/uploadfiles/)</p>
<p style="margin-left:40px">- CRYPTO_KEY=로그인 등에 사용하는 암호화키. 변경하면 안됨.</p>
<p style="margin-left:40px">- OWNER_CPO=개인정보보호책임자</p>
<p style="margin-left:40px">- OWNER_MPCODE=전문전송을 위한 엠피코드</p>
<p style="margin-left:40px">- REMOTE_SUPPORT_URL=원격지원주소</p>
<p style="margin-left:40px">- USE_INSURANCE_YN=보증보험사용여부</p>
<p style="margin-left:40px">- USE_GLOBAL_YN=글로벌구매카드사용여부</p>
<p style="margin-left:40px">- TRADE_BLOCK_ITEM_NM=거래제한 키워드</p>
<p style="margin-left:40px">- BANK_31DAY_ADD_DATE_WHEN_HOLIDAY=세금계산서 31일 체크시 휴일인 경우 따로 처리되는 은행코드</p>
<p style="margin-left:40px">- ETAX_RELEASE_YN=MP세금계산서 및 카카오톡 리얼 사용여부</p>
<p style="margin-left:40px">- ETAX_KEY=바로빌에서 제공하는 키</p>
<p style="margin-left:40px">- ETAX_DB_URL=세금계산서 상태변경을 위한 데이터베이스 주소</p>
<p style="margin-left:40px">- ETAX_SENDER_CODE=세금계산서 발행자 코드(임의)</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p><strong><span style="font-size:12pt">10. SMS</span></strong></p>
<p>&nbsp;</p>
<p>(1) 192.168.1.7번 DOB2B의 SC_TRAN 테이블을 활용함</p>
<p>(2) 전송은 구 백오피스에서 실행됨</p>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p><strong><span style="font-size:12pt">11. 매매계약서</span></strong><span style="font-size:12pt"> (CT_HEADER, CT_ITEM 테이블 참조)</span><strong><span style="font-size:12pt"> 관련 참고사항</span></strong></p>
<p>&nbsp;</p>
<p>(1) 거래대상</p>
<p style="margin-left:40px">- 내거래처로 등록된 회원사 (CT_MYCOMPANY 테이블 참조)</p>
<p style="margin-left:40px">- 약정(보증서)이 된 구매사 (GUARANTEE_MASTER_INFO 테이블 참조)</p>
<p style="margin-left:40px">- 구매사 또는 판매사가&nbsp; MP수수료 등록되어 있어야 함 (INFO_COMMISSION 테이블 참조)</p>
<p style="margin-left:40px">- 거래불가업체 또는 휴폐업자는 거래대상에서 제외 (COMPANY_NO_TRADE, COMPANY 테이블 참조)</p>
<p style="margin-left:40px">- 구매사 및 관계회사, 판매사의 관계회사 포함 (관계사 별도 관리, RELATION_COMPANY 테이블 참조)</p>
<p>(2) 대출상품의 종류</p>
<p style="margin-left:40px">- 구매자금,&nbsp;구매카드,&nbsp;일반자금,&nbsp;비보증 (PAYMEMT 테이블 참조)</p>
<p style="margin-left:40px">- 은행마다 취급상품이 다름 (BANK, BANK_PRODUCT 테이블 참조)</p>
<p>(3) 보증기관</p>
<p style="margin-left:40px">- 신용보증기금 (신보게이트웨이를 이용)</p>
<p style="margin-left:40px">- 기술보증기금 및 보증재단 (기보게이트웨이를 이용)</p>
<p>(4) 약정=결제수단 (GUARANTEE_MASTER_INFO 테이블 참조)</p>
<p style="margin-left:40px">- 보증기관, 은행, 대출상품으로 구성</p>
<p style="margin-left:40px">- 보증기관, 은행, 대출상품별로 운용 기준이 다름</p>
<p>(5) 세금계산서 (CT_BILL_MASTER, CT_BILL_ITEM 참조)</p>
<p style="margin-left:40px">- 기본적으로 세금계산서 첨부 의무</p>
<p style="margin-left:40px">-&nbsp;세금계산서는 스크래핑 및 XML 업로드를 통해 수집. 스크래핑은 알디스금융시스템의 프로그램을 사용</p>
<p style="margin-left:40px">- 비보증, 기보 개인판매사의 경우 세금계산서 미첨부 허용 (수기작성기능 사용 허용). 단, 일부 은행의 비보증 상품은 첨부 필수</p>
<p style="margin-left:40px">- 일반자금 중 일부 판매사(대기업)는 세금계산서 첨부 필수 아님 (수기작성기능 사용 허용)</p>
<p style="margin-left:40px">-&nbsp;구매사 및 관계사, 판매사 및 관계사의 세금계산서 사용 가능 (관계사는 별도로 관리, RELATION_COMPANY 테이블 참조)&nbsp;</p>
<p style="margin-left:40px">- 구매자금은 31일 이내 작성일의 세금계산서만 사용 가능. 단, 은행마다 31일 기준은 다름 (은행별 31일 기준 산출 로직 필요, HOLIDAY 테이블 참조)</p>
<p style="margin-left:40px">- 구매카드는 31일 제한이 없음</p>
<p style="margin-left:40px">- 스크랩 거래의 세금계산서 거래유형은 일반으로 고정</p>
<p>(6) 거래금액</p>
<p style="margin-left:40px">- 품목별 합계금액의 합계가 거래금액</p>
<p style="margin-left:40px">- 세금계산서의 총액을 초과한 거래는 불가함</p>
<p style="margin-left:40px">- 세금계산서는 총액 범위내에서 분할 사용 가능함</p>
<p style="margin-left:40px">- 분할 사용을 위해 첨부된 세금계산서의 품목 및 금액을 수정할 수 있어야 함</p>
<p style="margin-left:40px">- 스크랩 거래는 공급가액=총액. 스크랩 거래 업체는 별도 관리(COMPANY 테이블 참조)</p>
<p style="margin-left:40px">- 일반/면세/영세/스크랩거래에 따른 세액 및 공급가액 계산 로직이 있어야 함</p>
<p>(7) MP 수수료</p>
<p style="margin-left:40px">- 판매사를 선택하면, 수수료부담주체가 기본 설정되어야 함</p>
<p style="margin-left:40px">- 변경 가능</p>
<p style="margin-left:40px">- 수수료 체계는 별도 문서 참조</p>
<p style="margin-left:40px">- 매매계약서를 수정할 경우, 기선택된 부담주체를 기본값으로 해야 함</p>
<p>(8) 이상거래 모니터링</p>
<p style="margin-left:40px">- 신보 및 기보의 이상거래 필터링 기준이 다름 (abnormal.properties 참조)</p>
<p style="margin-left:40px">- 이상거래로 판단된 경우, 작성단계를 임시저장으로 변경</p>
<p style="margin-left:40px">- 건별로 관리자가 확인 후 해제시 거래 진행되도록 구현되어야 함</p>
<p style="margin-left:40px">- 동일 아이피인 경우, 쌍방의 전자서명 후 거래 진행 가능</p>
<p style="margin-left:40px">- 동일 사업장의 경우, 한 번 예외처리한 경우 이후 거래건 모두 거래 가능</p>
<p style="margin-left:40px">- 판매사 검증 예외처리된 판매사의 경우, 이상거래 예외 처리 (A211, A411 전문 및 COMPANY 테이블 참조)</p>
<p>(9) 전자서명 (프로그램 및 설정은 static/programs/SecuKitNXS 폴더 참조)</p>
<p style="margin-left:40px">- 구매사/판매사 쌍방의 전자서명이 필수</p>
<p style="margin-left:40px">- 단, 서명예외 사업자, 모바일 승인 사업자의 경우 모바일 환경에서 서명 제외</p>
<p>(10) 작성상태</p>
<p style="margin-left:40px">- 010 임시저장</p>
<p style="margin-left:40px">- 020 작성(판매사/구매사 승인대기)</p>
<p style="margin-left:40px">- 025 승인완료, 확인결제시 구매사 확인대기</p>
<p style="margin-left:40px">- 707 전송대기 (신규도입, 전송을 위한 모든 준비가 끝난 상태, 구판매사가 할 일이 없으며, 주로 게이트웨이에서 타임아웃이 된 경우 이 상태를 유지)</p>
<p style="margin-left:40px">- 030 전송실패</p>
<p style="margin-left:40px">- 040 전송완료(인터넷 뱅킹 대기)</p>
<p style="margin-left:40px">- 050 추심완료</p>
<p style="margin-left:40px">- 060 결제완료</p>
<p style="margin-left:40px">- 080 전송취소</p>
<p style="margin-left:40px">- 090 삭제</p>
<p>(11) 작성방식</p>
<p style="margin-left:40px">- 일반 : 구매사가 매매계약서 작성(020) &gt; 판매사 승인(025 -&gt; 707) &gt; 전송</p>
<p style="margin-left:40px">- 역발주 : 판매사가 매매계약서 작성(020) &gt; 구매사가 세금계산서를 첨부하고 수수료부담주체를 선택(025 -&gt; 707) &gt; 전송 (역발주 가능 회원 여부는&nbsp;COMPANY 테이블 참조)</p>
<p style="margin-left:40px">- 직발주 : 구매사가 매매계약서 작성과 동시에 전송 (직발주 회원은 별도 관리,&nbsp;DIRECT_RELATION 테이블 참조)</p>
<p style="margin-left:40px">- 확인결제 : 구매사가 매매계약서 작성(020) &gt; 판매사 승인(025) &gt; 구매사 확인(707) &gt; 전송 (확인결제 회원 여부는 COMPANY 테이블 참조)</p>
<p>(12) 관련 전문</p>
<p style="margin-left:40px">- B311 (매매계약서, MP&gt;보증기관), 응답전문은 B312</p>
<p style="margin-left:40px">- K311 (결제전문, 보증기관&gt;MP), 응답전문은 K312</p>
<p style="margin-left:40px">- A311 (한도조회, MP&gt;보증기관)</p>
<p style="margin-left:40px">- A211 (판매사 사전승인 여부 조회, MP&gt;보증기관)</p>
<p style="margin-left:40px">- A411 (판매사 사전승인 요청, MP&gt;보증기관)</p>
<p style="margin-left:40px">- 신보와 기보의 전문 내용이 약간 다름(별도 관리 필요)</p>
<p style="margin-left:40px">- <strong>전문전송 로그는 logfiles 폴더 아래에 쌓임. euc-kr로 인코딩되어 있음. 열람하려면&nbsp;:e ++enc=euc-kr&nbsp;</strong></p>
<p style="margin-left:40px">- 매매계약번호는 모두 유니크해야 하며, 매매계약의 전송번호는 일별로 유니크해야 함.</p>
<p>(13) 기타 요청사항</p>
<p style="margin-left:40px">- 한도조회 기능 필요 (한도조회 결과는 거래에 영향을 주지 않음)</p>
<p style="margin-left:40px">- 세금계산서 첨부는 거래대상에 국한하지 않으며, 다중 선택이 가능해야 함</p>
<p style="margin-left:40px">- 매매계약서 작성화면에서 거래대상 외의 세금계산서를 열람할 수 있어야 함</p>
<p style="margin-left:40px">- 세금계산서 검색기준은 오늘로부터 6개월 이전까지가 기본 값</p>
<p style="margin-left:40px">- 날짜 기준 : 세금계산서 작성일=계약일,&nbsp;거래일=당일,&nbsp;결제예정일=은행마다 기준이 다름(BANK_PRODUCT 테이블 참조),&nbsp;만기일=사용자가 선택한 만기일(MP수수료 부과기준이기도 하며, 양편으로 일수를 계산)</p>
<p style="margin-left:40px">- 임시저장된 매매계약서의 일괄 전송 기능</p>
<p style="margin-left:40px">- 확인결제시 판매사 승인된 매매계약서의 일괄 전송 기능</p>
<p style="margin-left:40px">- 임시저장, 판매사 승인 전 단계에서의 삭제 기능</p>
<p style="margin-left:40px">- 이상거래 모니터링에 걸린 매매계약서는 해당 사유를 목록에서 확인할 수 있어야 함</p>
<p>&nbsp;</p>

</body>
</html>