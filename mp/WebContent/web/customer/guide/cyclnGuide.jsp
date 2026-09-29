<%@ page contentType="text/html;charset=utf-8"%>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", false);
pageContext.setAttribute("GUIDE_TAB", "1");
%>
<%@ include file="../../includes/LoginCheck.jsp" %>
<%@ include file="../../includes/Header.jsp" %>
<title>싸이클론 이용안내</title>
<%@ include file="../../includes/Navigation.jsp" %>

  <div class='page-title-block'>
    <span class='title'>싸이클론 이용안내</span>
    <span class='more'><a onclick='self.print();' class='btn'>인쇄</a></span>
  </div>

<%@ include file="cyclnGuideTab.jsp" %>

  <div class='guide-section'>
    <h2><i class="fa-solid fa-caret-right"></i> 1. 싸이클론(Cycle Loan)이란?</h2>
    <p>기업과 기업이 전자상거래시장(MP)를 통해 매매계약을 체결한 경우 거래진행단계에 따라 판매기업과 구매기업을 함께 지원하는 대출 상품입니다.</p>
  </div>

  <div class='guide-section'>
    <h2><i class="fa-solid fa-caret-right"></i> 2. 이런 점이 좋습니다.</h2>
    <ul>
      <li>판매/구매 동시 지원으로 안정적인 물품공급 및 조달이 가능</li>
      <li>포괄금융방식과 인터넷대출로 여신거래가 편리</li>
      <li>대출한도 확대로 자금난 해소 및 효율적 자금운용이 가능</li>
      <li>물품판매대금 현금결제로 금융비용부담 경감</li>
      <li>보증기금 연계지원으로 담보부족 해소</li>
    </ul>
  </div>

  <div class='guide-section'>
    <h2><i class="fa-solid fa-caret-right"></i> 3. 융자 대상자</h2>
    <p>기업은행과 &ldquo;기업구매자금결제이용약정(구 : 판매기업용)&rdquo;을 체결한 법인(비영리법인 제외) 또는 개인사업자</p>
  </div>

  <div class='guide-section'>
    <h2><i class="fa-solid fa-caret-right"></i> 4. 융자 조건</h2>

    <h3><i class="fa-solid fa-circle" style='font-size:0.5em;vertical-align:middle;'></i> 약정한도</h3>
    <p>
      아래의 여신금액을 제외한 모든 운전자금대출 및 운전자금 담보 지급보증금액을 포함하여 연간매출액(또는 직전년도 매출액.
      단, 설립 후 1년 이내의 신설기업인 경우에는 추정매출액)을 초과하지 않는 범위 내
    </p>
    <ul>
      <li>상업어음할인</li>
      <li>외상매출채권담보대출</li>
      <li>일시당좌대출 및 특별(긴급)지원자금</li>
      <li>재정/기금대출</li>
      <li>기타여신으로서 본인 명의의 예&middot;적&middot;부금, 양도성예금증서, 중소기업금융채권, 환매조건부채권, 표지어음, 금전 신탁수익권 담보 해당액</li>
    </ul>

    <h3><i class="fa-solid fa-circle" style='font-size:0.5em;vertical-align:middle;'></i> 대출의 시행 및 상환</h3>
    <p>MP에 의해 은행에 전자적으로 등록된 본인의 &ldquo;판매계약정보&rdquo; 또는 &ldquo;구매계약정보&rdquo;에 의해 다음과 같이 대출실행 및 상환</p>

    <table class='detail'>
    <thead style="background-color: #f2f2f2;">
      <tr>
        <th class='left' style='width:16%;'>구분</th>
        <th class='left' style='width:52%;'>판매계약정보에 의한 대출</th>
        <th class='left' style='width:32%;'>구매계약정보에 의한 대출</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><strong>대출금액</strong></td>
        <td>매매계약금액의 80% 범위 내</td>
        <td>매매계약금액의 범위내에서 본인이 신청한 금액</td>
      </tr>
      <tr>
        <td><strong>실행시기</strong></td>
        <td>납품기한일 3개월 전 ~ 납품기한일</td>
        <td>본인이 지정한 대금 결제일</td>
      </tr>
      <tr>
        <td><strong>대출만기일</strong></td>
        <td>납품기한일 +2개월</td>
        <td>대출실행일 +5개월</td>
      </tr>
      <tr>
        <td><strong>대출금 지급</strong></td>
        <td>본인 통장으로 지급</td>
        <td>판매기업 통장으로 지급</td>
      </tr>
      <tr>
        <td><strong>대출금 상환</strong></td>
        <td>만기일에 일시 상환<br>(단, 만기일전 계약물품의 납품대금을 구매기업으로부터 결제 받는 경우 만기일에 관계없이 동 결제대금으로 대출금을 자동 상환)</td>
        <td>만기일에 일시 상환</td>
      </tr>
    </tbody>
    </table>

    <h3><i class="fa-solid fa-circle" style='font-size:0.5em;vertical-align:middle;'></i> 대출금리</h3>
    <p>다음과 같이 여신기간별 고시금리 또는 변동금리 중 택일</p>
    <div class='guide-diagram'>
      <img src='<%=request.getContextPath() %>/static/images/guide/guide_img01.gif' alt='여신기간별 금리'>
    </div>

    <h3><i class="fa-solid fa-circle" style='font-size:0.5em;vertical-align:middle;'></i> 싸이클론 주요 특징</h3>
    <table class='detail'>
    <thead style="background-color: #f2f2f2;">
      <tr>
        <th class='left' colspan="3">구매사</th>
        <th class='left'>거래 process</th>
        <th class='left' colspan="3">판매사(납품사)</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td rowspan="5">협력사 지원</td>
        <td colspan="2" rowspan="5">생산자금 선결제 효과</td>
        <td rowspan="5">구매사 : b2b주문(mp) &rArr;<br>판매사 : 주문확정(mp)</td>
        <td rowspan="5">생산자금대출<br>(CYCLE-LOAN)</td>
        <td>대출한도</td>
        <td>한도범위내 주문계약서의 80%까지</td>
      </tr>
      <tr>
        <td>대출금리</td>
        <td>우대금리<br>구매자금보다 저렴</td>
      </tr>
      <tr>
        <td>만기</td>
        <td>&nbsp;</td>
      </tr>
      <tr>
        <td>중개수수료</td>
        <td>대출액의 0.1%<br>대출발생시점<br>납품사 부담</td>
      </tr>
      <tr>
        <td>상환</td>
        <td>조기상환 가능<br>(조기상환수수료 없음)</td>
      </tr>
      <tr>
        <td colspan="3">&nbsp;</td>
        <td>
          판매사 : 원자재 조달 &rArr; 생산 &rArr; 납품<br>
          구매사 : 물품수령확인 &rArr; 대금결제
        </td>
        <td colspan="3">&nbsp;</td>
      </tr>
      <tr>
        <td>자기자금 결제</td>
        <td colspan="2">수수료 없음</td>
        <td rowspan="3">기업전용<br>인터넷뱅킹</td>
        <td rowspan="3">구매사<br>결제대금</td>
        <td colspan="2" rowspan="3">자동상환처리</td>
      </tr>
      <tr>
        <td>b2b구매자금대출결제</td>
        <td>대출한도범위 내<br>금리 : 구매자금 금리<br>만기 : 최장 6개월<br>중개수수료 : 약정</td>
        <td>구매사 부담</td>
      </tr>
      <tr>
        <td>싸이클론 대출 결제</td>
        <td>대출한도범위내<br>금리 : 우대금리<br>만기 :<br>중개수수료 : 약정</td>
        <td>구매사 부담</td>
      </tr>
    </tbody>
    </table>
  </div>

<%@ include file="../../includes/Footer.jsp" %>
