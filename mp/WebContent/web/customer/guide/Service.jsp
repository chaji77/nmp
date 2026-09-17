<%@ page contentType="text/html;charset=utf-8"%>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", false);
%>
<%@ include file="../../includes/LoginCheck.jsp" %>
<%@ include file="../../includes/Header.jsp" %>
<title>서비스 소개</title>
<style>
.service {text-align:center;}
ul.bar {display:flex;flex-flow:row wrap;justify-content:center;border-radius:5px;padding:20px 0;}
ul.bar>li {line-height:1.4em;text-align:center;width:29%;padding:10px;margin:3px;border-right:1px solid #357dfc;animation: fadeInUp 1s ease-out;}
ul.bar>li:first-child {animation: fadeInUp 0.5s ease-out;}
ul.bar>li:last-child {border:0;animation: fadeInUp 1.5s ease-out;}
ul.bar>li p {text-align:left;}
ul.bar.benefit>li {width:45%;}
div.heap {border-radius:10px;}
/*
div.heap h1 {animation: fadeInDown 1s ease-out;}
div.heap p {animation: fadeInUp 1.5s ease-out;}
*/
ul.bar>li:hover {
  transform: translateY(-5px);
}
.fade-in-up {
  opacity: 0;
  transform: translateY(30px);
  transition: all 0.6s ease-out;
}
.fade-in-down {
  opacity: 0;
  transform: translateY(-30px);
  transition: all 0.6s ease-out;
}
.visible {
  opacity: 1;
  transform: translateY(0);
}
@keyframes fadeInDown {
  from {opacity: 0; transform: translateY(-30px);}
  to {opacity: 1; transform: translateY(0);}
}
@keyframes fadeInUp {
  from {opacity: 0; transform: translateY(30px);}
  to {opacity: 1; transform: translateY(0);}
}
@media only screen and (max-width:767px) {
  div.heap h1 {font-size:1.8em;}
  ul.bar {padding:0;background-color:transparent;}
  ul.bar>li, ul.bar>li:last-child, ul.bar.benefit>li {border:1px solid #ddd;padding: 10px;width:100%;}
  .service img {width:100%;}
}
@media print {
.fade-in-up, .fade-in-down {opacity: 1;transform: translateY(0);}
}
</style>
<script>
document.addEventListener("DOMContentLoaded", () => {
  const elements = document.querySelectorAll('.fade-in-up, .fade-in-down');

  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        observer.unobserve(entry.target);
      }
    });
  }, {
    threshold: 0.5 // 요소가 10%만 보여도 트리거
  });

  elements.forEach(el => observer.observe(el));
});
</script>
<%@ include file="../../includes/Navigation.jsp" %>

  <div class='page-title-block'>
    <span class='title'>서비스 소개</span>
    <span class='more'><a onclick='self.print();' class='btn'>인쇄</a></span>
  </div>

  <div class='heap' style='background-color:#246CEB;color:white;padding:40px;text-align:center;'>
    <h1 class='fade-in-down'>B2B 전자상거래 대출보증</h1>
    <p>&nbsp;</p>
    <p>&nbsp;</p>
    <p class='fade-in-up'>안전하고 효율적인 B2B 거래를 위한 금융 솔루션. 구매대금 지급 보증으로 비즈니스 파트너 간 신뢰를 구축하세요.</p>
  </div>

  <ul class='bar'>
    <li>
      <h3><i class="fa-solid fa-shield-halved"></i> 보증의 의미</h3>
      <p>보증기관이 전자상거래에서 발생한 구매대금을 판매기업에게 지급하기 위해 금융기관에서 전자방식으로 차입하는 대출금에 대해 보증해주는 제도입니다.</p>
    </li>
    <li>
      <h3><i class="fa-solid fa-handshake-simple"></i> 기업 간 신뢰 구축</h3>
      <p>판매기업은 대금 회수 위험을 줄이고, 구매기업은 유동성을 확보하며 안정적인 거래 관계를 형성할 수 있습니다.</p>
    </li>
    <li>
      <h3><i class="fa-solid fa-arrow-up-right-dots"></i> 디지털 트랜스포메이션</h3>
      <p>전통적인 어음 결제 방식에서 벗어나 전자방식으로 진행되어 업무 효율성이 크게 향상됩니다.</p>
    </li>
  </ul>

  <h3 style='text-align:center;color:#8ce;font-size:1.4em;'>프로세스</h3>
  <div class='service'>
    <img src='http://image.mp1.co.kr/mp/service/ISG_img_0201.jpg'><br/>
  </div>

  <h3 class='fade-in-down' style='text-align:center;color:#8ce;font-size:1.4em;'>이용혜택</h3>
  
  <ul class='bar benefit'>
    <li>
      <h3><i class="fa-solid fa-building"></i> 구매기업</h3>
      <ul class='fade-in-up'>
        <li>기업의 신용만으로 구매자금 확보</li>
        <li>구매대금 결제의 유연성 확보</li>
        <li>간접비용절감 (여신심사생략, 은행업무비용 등)</li>
        <li>보증수수료 0.1% 감면혜택</li>
      </ul>
    </li>
    <li>
      <h3><i class="fa-solid fa-building"></i> 판매기업</h3>
      <ul class='fade-in-up'>
        <li>채권확보에 따른 매출증대효과</li>
        <li>채권관리 및 수금 비용의 회기적인 절감</li>
        <li>거래와 동시에 실시간 판매대금 회수(NO RISK)</li>
        <li>어음거래 등으로 인한 연체도산 방지</li>
      </ul>
    </li>
  </ul>

  <div class='heap' style='background-color:#EB6C24;color:white;padding:40px;text-align:center;margin:80px 0 50px 0;'>
    <h1 class='fade-in-down'>B2B 전자상거래 담보보증</h1>
    <p>&nbsp;</p>
    <p>&nbsp;</p>
    <p class='fade-in-up'>고정거래처와 외상방식의 전자상거래를 하는 경우, 보증기관이 판매사에 대한 외상대금 지급채무를 보증해주는 제도로 부동산 담보, 은행 지급보증서 등을 대체할 수 있습니다.</p>
  </div>

  <div class='service fade-in-up'>
    <img src='http://image.mp1.co.kr/mp/service/ISG_img_0202.jpg'><br/>
  </div>

  <div class='heap fade-in-up' style='padding:60px 0 30px 0;text-align:center;'>
    <h1>상담 준비서류</h1>
  </div>

  <table class='detail'>
  <thead style="background-color: #f2f2f2;">
    <tr>
      <th class='left'>구분</th>
      <th class='left'>법인사업자</th>
      <th class='left'>개인사업자</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>제출서류</strong></td>
      <td style='vertical-align:top;'>
        <ul>
          <li>사업자등록증명원</li>
          <li>납세증명서</li>
          <li>납세사실증명서</li>
          <li>부가가치세 과세표준 확인원</li>
          <li>법인등기부등본</li>
          <li>재무제표</li>
        </ul>
      </td>
      <td style='vertical-align:top;'>
        <ul>
          <li>사업자등록증명원</li>
          <li>납세증명서</li>
          <li>납세사실증명서</li>
          <li>부가가치세 과세표준 확인원</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td><strong>발급처</strong></td>
      <td colspan="2">
        <ul>
          <li>담당 세무 또는 회계 사무소에 발급요청 (FAX / 원본)</li>
          <li>인터넷 국세청 홈택스 서비스를 이용한 발급</li>
          <li>법인등기부등본 → 등기소</li>
        </ul>
      </td>
    </tr>
    <tr>
      <td><strong>공통사항</strong></td>
      <td colspan="2">최근 3개년도 분</td>
    </tr>
  </tbody>
</table>
  
  <div class='heap' style='padding:60px 0 30px 0;text-align:center;'>
    <h1><a href='/mp/web/customer/guide/Sales.jsp'><i class="fa-solid fa-link"></i> 문의</a></h1>
  </div>

  
  
  
<%@ include file="../../includes/Footer.jsp" %>