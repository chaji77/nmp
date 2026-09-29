<%@ page contentType="text/html;charset=utf-8"%>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", false);
pageContext.setAttribute("GUIDE_TAB", "3");
%>
<%@ include file="../../includes/LoginCheck.jsp" %>
<%@ include file="../../includes/Header.jsp" %>
<title>싸이클론 프로세스 단계별 상세설명</title>
<%@ include file="../../includes/Navigation.jsp" %>

  <div class='page-title-block'>
    <span class='title'>싸이클론 이용안내</span>
    <span class='more'><a onclick='self.print();' class='btn'>인쇄</a></span>
  </div>

<%@ include file="cyclnGuideTab.jsp" %>

  <div class='guide-section'>

    <div class='guide-diagram'>
      <img src='<%=request.getContextPath() %>/static/images/guide/guide_03_img01.gif' alt='싸이클론 프로세스'>
    </div>

    <!-- STEP 01 ------------------------------------------------------------ -->
    <div class='guide-step'>
      <div class='guide-step-head'><span class='guide-step-no'>STEP 01</span> Cycle Loan 약정</div>
      <div class='guide-step-cont'>
        <div class='guide-step-img'>
          <img src='<%=request.getContextPath() %>/static/images/guide/guide_03_step01.gif' alt='Step 01. Cycle Loan 약정'>
        </div>
        <div class='guide-step-body'>
          <div class='guide-desc'><span class='guide-tag buy'>구매</span> 싸이클론 약정 체결</div>
          <div class='guide-desc'><span class='guide-tag sell'>판매</span> 싸이클론 약정 체결</div>
        </div>
      </div>
    </div>

    <!-- STEP 02 ------------------------------------------------------------ -->
    <div class='guide-step'>
      <div class='guide-step-head'><span class='guide-step-no'>STEP 02</span> 회원가입</div>
      <div class='guide-step-cont'>
        <div class='guide-step-img'>
          <img src='<%=request.getContextPath() %>/static/images/guide/guide_03_step02.gif' alt='Step 02. 회원가입'>
        </div>
        <div class='guide-step-body'>
          <div class='guide-desc'>
            <span class='guide-tag buy'>구매</span>
            <a href='http://mp1.co.kr' target='_blank'>mp1.co.kr</a>에 회원가입 (사업자등록증 사본 Fax 송부 : 02-715-7650)
          </div>
          <div class='guide-desc'>
            <span class='guide-tag sell'>판매</span>
            <a href='http://mp1.co.kr' target='_blank'>mp1.co.kr</a>에 회원가입 (사업자등록증 사본 Fax 송부 : 02-715-7650)
          </div>
        </div>
      </div>
    </div>

    <!-- STEP 03 ------------------------------------------------------------ -->
    <div class='guide-step'>
      <div class='guide-step-head'><span class='guide-step-no'>STEP 03</span> 발주계약서 작성</div>
      <div class='guide-step-cont'>
        <div class='guide-step-img'>
          <img src='<%=request.getContextPath() %>/static/images/guide/guide_03_step03.gif' alt='Step 03. 발주계약서작성 / Step 04. 납품확정'>
        </div>
        <div class='guide-step-body'>
          <div class='guide-desc'>
            <span class='guide-tag buy'>구매</span>
            구매기업은 MP에서 제공하는 사이트를 통해 발주계약서를 작성하여 판매기업에 발송합니다. (수량/단가 등)
          </div>
          <div class='guide-path'>구매서비스 &gt; 발주계약서작성</div>
          <div class='guide-desc'>주문확정 이후에도 판매기업에 변경요청 및 승인이 가능합니다.</div>
        </div>
      </div>
    </div>

    <!-- STEP 04 ------------------------------------------------------------ -->
    <div class='guide-step'>
      <div class='guide-step-head'><span class='guide-step-no'>STEP 04</span> 납품확정 및 판매자금/생산자금 대출</div>
      <div class='guide-step-cont'>
        <div class='guide-step-img'></div>
        <div class='guide-step-body'>
          <div class='guide-desc'>
            <span class='guide-tag sell'>판매</span>
            발주계약서 내용을 확인한 후 <strong style='color:#EB6C24;'>납품확정</strong>을 합니다. 이때 매매계약서가 기업은행으로 전송됩니다.
          </div>
          <div class='guide-desc'>(단, 취소/변경사항 발생 시 구매사&middot;판매사 모두 변경요청이 가능하며 변경승인 후 변경/취소 매매계약서 전송)</div>
          <div class='guide-path'>판매서비스 &gt; 납품확정내역 &gt; 납품확정</div>

          <div class='guide-desc'>
            <span class='guide-tag ibk'>IBK</span>
            <strong style='color:#246CEB;'>판매 : 판매자금/생산자금 대출 (기업은행 &rarr; 판매기업)</strong>
          </div>
          <div class='guide-desc'>
            a. MP로부터 접수한 매매계약정보에 근거하여 본부에서 판매자금대출을 지원받을 수 있는 &ldquo;판매계약정보&rdquo;를
            등록하고, 판매기업은 동 &ldquo;판매계약정보&rdquo;에 의해 인터넷으로 대출을 실행하고 대출금을 수령합니다.
          </div>
          <div class='guide-desc'>
            b. 대출실행은 납품기한 3개월 전부터 납품기한 일까지 가능하며, 계약금액의 80% 범위 내에서 분할 대출이 가능합니다.
          </div>
          <div class='guide-desc'>
            c. 대출실행 시 본인이 입금계좌를 지정하는 경우 대출금을 해당계좌로 연동 입금처리 하고,
            입금계좌를 지정하지 않는 경우에는 &ldquo;기업구매자금결제이용약정서(판매기업용)&rdquo;에 신고한 예금계좌로 연동입금 처리 합니다.
          </div>
        </div>
      </div>
    </div>

    <!-- STEP 05 ------------------------------------------------------------ -->
    <div class='guide-step'>
      <div class='guide-step-head'><span class='guide-step-no'>STEP 05</span> 물품배송</div>
      <div class='guide-step-cont'>
        <div class='guide-step-img'>
          <img src='<%=request.getContextPath() %>/static/images/guide/guide_03_step05.gif' alt='Step 05. 물품배송'>
        </div>
        <div class='guide-step-body'>
          <div class='guide-desc'>
            <span class='guide-tag sell'>판매</span>
            발주계약서(매매계약)에서 지정된 납품기한까지 판매기업이 구매기업에 물품을 배송합니다.
          </div>
        </div>
      </div>
    </div>

    <!-- STEP 06 ------------------------------------------------------------ -->
    <div class='guide-step'>
      <div class='guide-step-head'><span class='guide-step-no'>STEP 06</span> 물품수령 및 대금결제금액/결제일 확인</div>
      <div class='guide-step-cont'>
        <div class='guide-step-img'>
          <img src='<%=request.getContextPath() %>/static/images/guide/guide_03_step06.gif' alt='Step 06. 물품수령 및 대금결제금액/결제일 확인'>
        </div>
        <div class='guide-step-body'>
          <div class='guide-desc'>
            <span class='guide-tag buy'>구매</span>
            물품을 배송받은 구매기업이 MP를 통해 물품수령을 확인(등록)하고
          </div>
          <div class='guide-path'>구매서비스 &gt; 물품수령관리 &gt; 수령정보입력</div>
          <div class='guide-desc'>대금결제예정일을 지정하여 물품대금 지급을 승인합니다.</div>
          <div class='guide-path'>구매서비스 &gt; 결제정보관리 &gt; 결제하기</div>

          <div class='guide-desc'>
            <span class='guide-tag ibk'>IBK</span>
            <strong style='color:#246CEB;'>구매 : 구매자금/판매기업 대출상환 대출 (기업은행 &rarr; 구매기업 or 판매기업 대출상환)</strong>
          </div>
          <div class='guide-desc'>
            MP로부터 접수한 대금청구내역에 근거하여 본부에서 구매자금대출을 지원받을 수 있는 &ldquo;구매계약정보&rdquo;를 등록하고
            해당 매매계약에서의 구매기업은 동 &ldquo;구매계약정보&rdquo;에 의해 인터넷으로 대출을 실행하여 구매대금을 결제합니다.
          </div>
        </div>
      </div>
    </div>

  </div>

<%@ include file="../../includes/Footer.jsp" %>
