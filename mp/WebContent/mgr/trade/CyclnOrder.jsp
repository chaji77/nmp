<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.trade.CyclnBean" %>
<%@ page import="kr.co.mp.trade.CyclnOrderDetailVO" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%!
// 8자리(yyyyMMdd)일 때만 구분자를 넣는다.
String ymd(String s) {
  s = StrUtil.nvl(s).trim();
  return (s.length()==8) ? FormatUtil.addSeparatorDate(s) : s;
}
// 값이 없으면 '-' 로 보인다.
String dash(String s) {
  s = StrUtil.nvl(s).trim();
  return s.equals("") ? "-" : s;
}
// 숫자만 남기고 long 으로. 합계 계산용.
long num(String s) {
  s = StrUtil.nvl(s).replaceAll("[^0-9-]", "");
  if (s.equals("") || s.equals("-")) return 0L;
  try {
    return Long.parseLong(s);
  } catch (NumberFormatException e) {
    return 0L;
  }
}
// 금액 표시. 0으로 채워 넘어오는 값(0000033016500)을 정규화한 뒤 콤마를 찍는다.
String amt(String s) {
  return StrUtil.addComma(Long.toString(num(s)));
}
// 수수료율. 결제금액 대비 수수료 비율을 소수점 3자리까지 '(0.165%)' 형태로 돌려준다.
// 결제금액이 0이면 빈 문자열.
String feeRate(String strFee, String strSetl) {
  long lngSetl = num(strSetl);
  if (lngSetl==0L)         return "";
  if (num(strFee)==0L)     return "(0%)"; // stripTrailingZeros 가 0 을 0E-3 으로 만드는 JDK 를 피한다.
  java.math.BigDecimal b = new java.math.BigDecimal(num(strFee))
      .multiply(new java.math.BigDecimal("100"))
      .divide(new java.math.BigDecimal(lngSetl), 3, java.math.RoundingMode.HALF_UP);
  return "(" + b.stripTrailingZeros().toPlainString() + "%)";
}
// 발주계약서 상태코드. 정의에 없으면 코드를 그대로 보인다.
String orderStatusNm(String s) {
  s = StrUtil.nvl(s).trim();
  if (s.equals("010")) return "발주계약서 작성";
  if (s.equals("050")) return "납품확정";
  if (s.equals("090")) return "발주취소";
  if (s.equals("095")) return "납품취소";
  return s;
}
// 전문 처리상태(CYCLN_QUEUE.STATUS). 전문이 없으면 '-'.
String queueStatusNm(String s) {
  s = StrUtil.nvl(s).trim();
  if (s.equals(""))  return "-";
  if (s.equals("1")) return "처리중";
  if (s.equals("2")) return "완료";
  if (s.equals("9")) return "실패";
  return s;
}
// 거래구분(TRX_CLS). 01-등록, 02-취소.
String trxClsNm(String s) {
  s = StrUtil.nvl(s).trim();
  if (s.equals("01")) return "등록";
  if (s.equals("02")) return "변경";
  if (s.equals("03")) return "취소";
  return dash(s);
}
// 결제통보 거래구분. 01-결제, 02-취소, 03-싸이클론 대출, 04-싸이클론 대출취소.
String trxClsPayNm(String s) {
  s = StrUtil.nvl(s).trim();
  if (s.equals("01")) return "구매자금 결제";
  if (s.equals("02")) return "구매자금 결제취소";
  if (s.equals("03")) return "싸이클론 대출";
  if (s.equals("04")) return "싸이클론 대출취소";
  return dash(s);
}
%>
<%
request.setCharacterEncoding("utf-8");

String strOrderNo = StrUtil.nvl(request.getParameter("orderno"), "");

CyclnOrderDetailVO vo = null;
if (!strOrderNo.equals("")) {
  vo = new CyclnBean().CYCLN_ORDER_DETAIL_PROC(strOrderNo);
}
if (vo==null) {
  out.println("<script>alert('주문 정보를 찾을 수 없습니다.');history.back();</script>");
  return;
}

// 제품 목록 합계
long lngSumPrice = 0L, lngSumTax = 0L, lngSumTotal = 0L;
for (CyclnOrderDetailVO.ItemVO ivo : vo.ITEMS) {
  lngSumPrice += num(ivo.PRICE);
  lngSumTax   += num(ivo.TAXAMT);
  lngSumTotal += num(ivo.TOTALAMT);
}

// 결제통보 합계
long lngSumSfcp = 0L, lngSumLoan = 0L, lngSumFee = 0L;
for (CyclnOrderDetailVO.Cl100VO r : vo.CL100) {
  lngSumSfcp += num(r.SFCP_SETL_PRIC);
  lngSumLoan += num(r.BYCA_LOAN_PRIC);
  lngSumFee  += num(r.FEE_AMT);
}
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>거래 상세관리</title>
<style>
/* 넓은 화면에서만 본문 폭을 60% 로 줄인다. 모바일은 style.css 기본값 유지. */
@media only screen and (min-width:1101px) {
  main {width:60%;margin-left:auto;margin-right:auto;padding-left:0;padding-right:0;}
}
table.detail {font-size:110%;}
table.detail td {line-height:1.7em;vertical-align:top;}
table.detail tr.sum td {font-weight:bold;color:#c00;}
table.summary th {background:#f3f3f3;}
h3 {margin-top:25px;}
</style>
<script>
$(document).ready(function(){
  $("#total_kor").text("(" + numberToKorean(<%=lngSumTotal%>) + "원)");
  $("#fee_kor").text("(" + numberToKorean(<%=lngSumFee%>) + "원)");
});
</script>
<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block'>
  <span class='title'>거래 상세관리</span>
  <span class='more'>
    <a onclick='goHistoryBack()' class='btn'>목록</a>
  </span>
</div>

<table class='detail summary'>
  <tbody>
    <tr>
      <th class='left'>매매계약번호</th>
      <td class='left'><strong><%=vo.ORDERNO%></strong></td>
      <th class='left'>구매기업</th>
      <td class='left'><%=dash(vo.BC_NAME)%></td>
      <th class='left'>판매기업</th>
      <td class='left'><%=dash(vo.SC_NAME)%></td>
    </tr>
  </tbody>
</table>

<h3>발주계약서정보</h3>

<table class='detail'>
  <tbody>
    <tr>
      <th class='left'>발주계약서명</th>
      <td class='left' colspan='3'><%=dash(vo.ORDERNAME)%></td>
    </tr>
    <tr>
      <th class='left'>거래일자</th>
      <td class='left'><%=ymd(vo.TRADEDATE)%></td>
      <th class='left'>요청납기일</th>
      <td class='left'><%=ymd(vo.REQDLVDATE)%></td>
    </tr>
    <tr>
      <th class='left'>발주계약서 상태</th>
      <td class='left'><%=orderStatusNm(vo.STATUS)%></td>
      <th class='left'>도착지</th>
      <td class='left'><%=dash(vo.DLVADDRESS)%></td>
    </tr>
  </tbody>
</table>

<h3>제품정보</h3>

<table class='detail'>
  <thead>
    <tr>
      <th class='left'>제품코드</th>
      <th class='left'>제품명</th>
      <th class='right'>요청수량</th>
      <th class='right'>요청단가</th>
      <th class='right'>납품수량</th>
      <th class='right'>납품단가</th>
      <th class='right'>세액</th>
      <th class='right'>합계금액</th>
    </tr>
  </thead>
  <tbody>
<%
if (vo.ITEMS.size()>0) {
  for (CyclnOrderDetailVO.ItemVO ivo : vo.ITEMS) {
%>
    <tr>
      <td class='left'><%=dash(ivo.PRD_ID)%></td>
      <td class='left'><%=dash(ivo.PRD_TITLE)%></td>
      <td class='right'><%=dash(ivo.REQQTY)%></td>
      <td class='right'><%=amt(ivo.REQPRICE)%></td>
      <td class='right'><%=dash(ivo.QTY)%></td>
      <td class='right'><%=amt(ivo.PRICE)%></td>
      <td class='right'><%=amt(ivo.TAXAMT)%></td>
      <td class='right'><%=amt(ivo.TOTALAMT)%></td>
    </tr>
<%
  }
%>
    <tr class='sum'>
      <td class='right' colspan='5'>합계금액</td>
      <td class='right'><%=amt(Long.toString(lngSumPrice))%></td>
      <td class='right'><%=amt(Long.toString(lngSumTax))%></td>
      <td class='right'><%=amt(Long.toString(lngSumTotal))%><span id='total_kor'></span></td>
    </tr>
<%
} else out.println("<tr><td colspan='8' class='noentry'>제품 정보가 없습니다.</td></tr>");
%>
  </tbody>
</table>

<h3>매매계약정보</h3>

<table class='detail'>
  <thead>
    <tr>
      <th class='left'>전문요청일</th>
      <th class='left'>거래품목</th>
      <th class='left'>납품기한</th>
      <th class='right'>매매금액</th>
      <th class='left'>대출여부</th>
      <th class='left'>거래구분</th>
      <th class='left'>상태</th>
    </tr>
  </thead>
  <tbody>
<%
if (vo.CL080.size()>0) {
  for (CyclnOrderDetailVO.Cl080VO r : vo.CL080) {
%>
    <tr>
      <td class='left'><%=ymd(r.REQ_YMD)%></td>
      <td class='left'><%=dash(r.PURC_ITEM)%></td>
      <td class='left'><%=ymd(r.DLVR_YMD)%></td>
      <td class='right'><%=amt(r.PURC_PRIC)%></td>
      <td class='left'><%=dash(r.LOAN_YN)%></td>
      <td class='left'><%=trxClsNm(r.TRX_CLS)%></td>
      <td class='left'><%=queueStatusNm(r.STATUS)%></td>
    </tr>
<%
  }
} else out.println("<tr><td colspan='7' class='noentry'>조회된 내용이 없습니다.</td></tr>");
%>
  </tbody>
</table>

<h3>결제예정정보</h3>

<table class='detail'>
  <thead>
    <tr>
      <th class='left'>전문요청일</th>
      <th class='right'>매매금액</th>
      <th class='left'>결제예정일</th>
      <th class='right'>결제예정금액</th>
      <th class='left'>세금계산서 발행일</th>
      <th class='left'>거래구분</th>
      <th class='left'>상태</th>
    </tr>
  </thead>
  <tbody>
<%
if (vo.CL090.size()>0) {
  for (CyclnOrderDetailVO.Cl090VO r : vo.CL090) {
%>
    <tr>
      <td class='left'><%=ymd(r.REQ_YMD)%></td>
      <td class='right'><%=amt(r.PURC_PRIC)%></td>
      <td class='left'><%=ymd(r.SETL_PLN_YMD)%></td>
      <td class='right'><%=amt(r.SETL_PLN_PRIC)%></td>
      <td class='left'><%=ymd(r.TAX_ISSU_YMD)%></td>
      <td class='left'><%=trxClsNm(r.TRX_CLS)%></td>
      <td class='left'><%=queueStatusNm(r.STATUS)%></td>
    </tr>
<%
  }
} else out.println("<tr><td colspan='7' class='noentry'>조회된 내용이 없습니다.</td></tr>");
%>
  </tbody>
</table>

<h3>결제통보</h3>

<table class='detail'>
  <thead>
    <tr>
      <th class='left'>전문요청일</th>
      <th class='left'>만기일</th>
      <th class='right'>결제금액</th>
      <th class='right'>자기자금결제금액</th>
      <th class='right'>구매자금대출금액</th>
      <th class='right'>수수료(율)</th>
      <th class='left'>거래구분</th>
      <th class='left'>상태</th>
    </tr>
  </thead>
  <tbody>
<%
if (vo.CL100.size()>0) {
  for (CyclnOrderDetailVO.Cl100VO r : vo.CL100) {
%>
    <tr>
      <td class='left'><%=ymd(r.REQ_YMD)%></td>
      <td class='left'><%=ymd(r.MTR_YMD)%></td>
      <td class='right'><%=amt(r.SETL_PRIC)%></td>
      <td class='right'><%=amt(r.SFCP_SETL_PRIC)%></td>
      <td class='right'><%=amt(r.BYCA_LOAN_PRIC)%></td>
      <td class='right'><%=amt(r.FEE_AMT)%>원<%=feeRate(r.FEE_AMT, r.SETL_PRIC)%></td>
      <td class='left'><%=trxClsPayNm(r.TRX_CLS)%></td>
      <td class='left'><%=queueStatusNm(r.STATUS)%></td>
    </tr>
<%
  }
%>
    <tr class='sum'>
      <td class='right' colspan='3'>합계금액</td>
      <td class='right'><%=amt(Long.toString(lngSumSfcp))%>원</td>
      <td class='right'><%=amt(Long.toString(lngSumLoan))%>원</td>
      <td class='right'><%=amt(Long.toString(lngSumFee))%>원<span id='fee_kor'></span></td>
      <td colspan='2'></td>
    </tr>
<%
} else out.println("<tr><td colspan='8' class='noentry'>조회된 내용이 없습니다.</td></tr>");
%>
  </tbody>
</table>
<%@ include file="../Footer.jsp" %>
