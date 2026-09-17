<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="com.baroservice.ws.ArrayOfString" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.firstbill.*" %>
<%
request.setCharacterEncoding("utf-8");
String strBillSeq = StrUtil.nvl(request.getParameter("seq"), "0");

if (!StrUtil.isOnlyNumeric(strBillSeq)) return;

int intBillSeq = Integer.parseInt(strBillSeq);
InvoiceVO vo = InvoiceDAO.BILL_DETAIL_PROC(intBillSeq);

String strUserSeq = StrUtil.nvl((String)session.getAttribute("SESS_BILL_USER_SEQ"), "0");
if (strUserSeq.equals("0")) {
  response.sendRedirect("index.jsp");
  return;
}
BillUserVO user   = BillUserDAO.BILL_USER_DETAIL_PROC(Integer.parseInt(strUserSeq));
String strUrl     = new BaroBill(user).GetTaxInvoicePopUpURL(vo.strSerialNum);
out.println(strUrl);
%>