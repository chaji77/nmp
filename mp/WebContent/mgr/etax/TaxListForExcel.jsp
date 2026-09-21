<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.mptax.InvoiceUtil" %>
<%@ page import="kr.co.mp.mptax.InvoiceVO" %>
<%@ page import="kr.co.mp.mptax.InvoiceDAO" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");

String strSenderKey = StrUtil.nvl(request.getParameter("senderKey"), ConfigurationMgr.getInstance().getString("ETAX_SENDER_CODE"));
String startDate = StrUtil.nvl(request.getParameter("start_dt"), "").replaceAll("/", "");
String endDate   = StrUtil.nvl(request.getParameter("end_dt"), "").replaceAll("/", "");
String strInvoiceeCorpNum = StrUtil.nvl(request.getParameter("cn"), "").replaceAll("-", "");
String strCorpName = StrUtil.nvl(request.getParameter("strCorpNm"), "");
int intStatus = 1;
String strEmpId = "0";

InvoiceDAO dao = new InvoiceDAO();
int intPage = 1;
ArrayList<InvoiceVO> arr = dao.T_BILL_EXCEL_LIST_PROC(strSenderKey, intPage, startDate, endDate, strInvoiceeCorpNum, intStatus, strEmpId, strCorpName);

String strPageTitle= "세금계산서관리";
if ((startDate != null && !startDate.isEmpty()) || (endDate != null && !endDate.isEmpty())) {
    strPageTitle += "("+startDate+"-"+endDate+")";
}
if (strCorpName != null && !strCorpName.isEmpty()) {
    strPageTitle += " [" + strCorpName + "]";
}
%>
<!DOCTYPE HTML>
<html>
<head>
<meta charset="utf-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Cache-Control" content="no-cache">
<%
  response.setHeader("Content-Type", "application/vnd.ms-xls");
  String fn = new String((strPageTitle + ".xls").getBytes("utf-8"), "8859_1");
  response.setHeader("Content-Disposition", "inline; filename="+fn);
%>
</head>
<body>
<table id='excel'>
  <thead>
    <tr>
      <th>발행번호</th>
      <th>내역</th>
      <th>진행상태</th>
      <th>작성일</th>
      <th>계산서종류</th>
      <th>과세구분</th>
      <th>청구/영수</th>
      <th>공급받는자</th>
      <th>사업자번호</th>
      <th>공급가액</th>
      <th>세액</th>
      <th>합계금액</th>
    </tr>
  </thead>
  <tbody>
<%
if (arr != null && arr.size() > 0) {
  for (InvoiceVO vo : arr) {
%>
    <tr>
      <td><%=vo.BILL_SENDER_KEY %><%=vo.BILL_SEQ %></td>
      <td><%=StrUtil.nvl(vo.ITEM_NM) %></td>
      <td><%=InvoiceUtil.getStatus(vo) %></td>
      <td><%=FormatUtil.addSeparatorDate(vo.strWriteDate) %></td>
      <td><%=InvoiceUtil.getInvoiceType(vo) %></td>
      <td><%=InvoiceUtil.getChargeType(vo) %></td>
      <td><%=InvoiceUtil.getPurposeType(vo) %></td>
      <td><%=vo.strToCorpNm %></td>
      <td style="mso-number-format:'\@';">
        <%=InvoiceUtil.getBizNo(vo.strToBizNo) %>
      </td>
      <td class="right"><%=StrUtil.addComma(vo.strAmountTotal) %></td>
      <td class="right"><%=StrUtil.addComma(vo.strTaxTotal) %></td>
      <td class="right"><%=StrUtil.addComma(vo.strTotalAmount) %></td>
    </tr>
<%
  }
} else {
%>
    <tr>
      <td colspan="12">조회된 데이터가 없습니다.</td>
    </tr>
<%
}
%>
  </tbody>
</table>
</body>
</html>
