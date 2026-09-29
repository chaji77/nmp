<%@ page contentType="text/html;charset=utf-8"%>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", false);
pageContext.setAttribute("GUIDE_TAB", "2");
%>
<%@ include file="../../includes/LoginCheck.jsp" %>
<%@ include file="../../includes/Header.jsp" %>
<title>싸이클론 업무 흐름도</title>
<%@ include file="../../includes/Navigation.jsp" %>

  <div class='page-title-block'>
    <span class='title'>싸이클론 이용안내</span>
    <span class='more'><a onclick='self.print();' class='btn'>인쇄</a></span>
  </div>

<%@ include file="cyclnGuideTab.jsp" %>

  <div class='guide-section'>
    <p>
      기업은행과 협약을 체결한 MP(전자상거래시장)에서 매매계약을 체결한 경우 물품 등의 판매 시에는 계약과 동시에, <br>
      물품 등을 구매하는 경우에는 대금결제 시에 필요자금을 지원해 드리는 <strong style='color:#EB6C24;'>한도거래방식 대출상품</strong>입니다.
    </p>

    <div class='guide-diagram'>
      <img src='<%=request.getContextPath() %>/static/images/guide/guide_02_img01.gif' alt='싸이클론 업무 흐름도'>
    </div>

    <table class='detail'>
    <tbody>
      <tr>
        <td style='width:34%;'><strong>&#9312; Cycle Loan 약정</strong></td>
        <td style='width:66%;'>가까운 기업은행 지점에서 싸이클론(Cycle Loan) 약정을 합니다. (여신거래약정서)</td>
      </tr>
      <tr>
        <td><strong>&#9313; MP 회원가입</strong></td>
        <td><a href='http://mp1.co.kr' target='_blank'>mp1.co.kr</a>에 회원가입을 합니다.</td>
      </tr>
      <tr>
        <td><strong>&#9314; 매매계약전송</strong></td>
        <td>
          <strong>싸이클론 -> 발주계약서</strong>에서 발주계약서 작성(구매)/납품확정(판매)
          단계로 거래를 진행하면 매매계약서(신규/변경/취소)가 기업은행으로 전송됩니다.
        </td>
      </tr>
      <tr>
        <td><strong>&#9315; 대출실행(판매자금/생산자금)</strong></td>
        <td>판매기업에 대출이 실행됩니다. (판매자금/생산자금)</td>
      </tr>
      <tr>
        <td><strong>&#9316; 물품배송</strong></td>
        <td>구매기업으로 물품을 배송합니다.</td>
      </tr>
      <tr>
        <td><strong>&#9317; 물품수령 및 결제금액/대금결제일 확인</strong></td>
        <td>판매기업으로부터 배송된 물품을 수령한 후 결제금액 및 결제일을 입력합니다.</td>
      </tr>
      <tr>
        <td><strong>&#9318; 대금청구내역전송</strong></td>
        <td>기업은행으로 대금청구내역 전문이 전송됩니다.</td>
      </tr>
      <tr>
        <td><strong>&#9319; 대출실행(구매자금/대출상환)</strong></td>
        <td>구매기업으로 대출이 실행됩니다. (구매자금 또는 판매기업 대출금 상환)</td>
      </tr>
    </tbody>
    </table>
  </div>

<%@ include file="../../includes/Footer.jsp" %>
