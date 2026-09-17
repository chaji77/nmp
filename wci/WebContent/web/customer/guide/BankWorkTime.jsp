<%@ page contentType="text/html;charset=utf-8"%>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", false);
%>
<%@ include file="../../includes/LoginCheck.jsp" %>
<%@ include file="../../includes/Header.jsp" %>
<title>은행B2B결제시간</title>
<%@ include file="../../includes/Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>은행B2B결제시간</span>
  <span class='more'><a onclick='self.print();' class='btn'>인쇄</a></span>
</div>

<p><i class="fa-solid fa-triangle-exclamation"></i> 주말 및 공휴일은 B2B결제가 불가능합니다.</p>
<p>&nbsp;</p>

<!-- 은행 결제가능시간 STR -->
<table class='detail'>
<tr>
	<th class='left'>은행</th>
	<th class='left'>구매자금</th>
	<th class='left'>구매카드(론)</th>
	<th class='left'>할인</th>
	<th class='left'>일반자금</th>
</tr>
<tr>
	<td>기업은행</td>
	<td>08:00~22:00</td>
	<td>08:00~22:00</td>
	<td>08:00~22:00</td>
	<td>시간제한없음</td>
</tr>
<tr>
	<td>KEB 하나은행</td>
	<td>09:00~22:00</td>
	<td>09:00~22:00</td>
	<td>09:30~19:00</td>
	<td>09:00~22:00</td>
</tr>
<tr>
	<td>국민은행</td>
	<td>09:00~19:00(추심포함)</td>
	<td>09:00~19:00</td>
	<td>09:00~19:00</td>
	<td>&nbsp;</td>
</tr>
<tr>
	<td>신한은행</td>
	<td>09:00~20:00</td>
	<td>09:00~22:00</td>
	<td>09:00~22:00</td>
	<td>09:00~22:00</td>
</tr>
<tr>
	<td>우리은행</td>
	<td>09:00~20:00</td>
	<td>09:00~20:00</td>
	<td>09:00~20:00</td>
	<td>&nbsp;</td>
</tr>
<tr>
	<td>씨티은행</td>
	<td>09:00~18:00</td>
	<td>09:00~18:00</td>
	<td>09:00~18:00</td>
	<td>&nbsp;</td>
</tr>
<tr>
	<td>대구은행</td>
	<td>09:00~19:30</td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
</tr>
<tr>
	<td>농협</td>
	<td>09:00~22:00(추심포함)</td>
	<td>08:00~22:00</td>
	<td>09:00~22:00</td>
	<td>&nbsp;</td>
</tr>
<tr>
	<td>SC제일은행</td>
	<td>09:00~22:00</td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
</tr>
<tr>
	<td>경남은행</td>
	<td>09:00~영업점마감시간<br />평일 : 16~18시<br />말일 18~20시</td>
	<td>09:00~영업점마감시간<br />평일 : 16~18시<br />말일 18~20시</td>
	<td>09:00~영업점마감시간<br />평일 : 16~18시<br />말일 18~20시</td>
	<td>&nbsp;</td>
</tr>
<tr>
	<td>광주은행</td>
	<td>09:00~22:00</td>
	<td>09:00~23:00</td>
	<td>09:00~23:00</td>
	<td>&nbsp;</td>
</tr>
<tr>
	<td>부산은행</td>
	<td>09:00~22:00</td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
</tr>
<tr>
	<td>수협</td>
	<td>09:00~18:00(추심포함)</td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
</tr>
<tr>
	<td>전북은행</td>
	<td>09:00~22:00</td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
</tr>
</table>
<!-- 은행 결제가능시간 END -->

<%@ include file="../../includes/Footer.jsp" %>