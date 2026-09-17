<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.mptax.*" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String seq = StrUtil.nvl(request.getParameter("seq"), "0");

if (StrUtil.isOnlyNumeric(seq) && !seq.equals("0")) {
  try {
    int intBillSeq = new InvoiceDAO().T_BILL_READD_PROC(Integer.parseInt(seq));
    if (intBillSeq>0) {
      out.println(intBillSeq);
    }
  } catch (Exception e) {
    System.out.println(e.toString());
    out.println("-1");
  }
} else {
  out.println("-1");
}
%>