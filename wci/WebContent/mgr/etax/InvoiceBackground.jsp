<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.mptax.InvoiceUtil" %>
<%@ page import="kr.co.mp.mptax.InvoiceVO" %>
<%@ page import="kr.co.mp.mptax.InvoiceDAO" %>
<%@ page import="com.baroservice.ws.ArrayOfString" %>
<%@ page import="kr.co.mp.mptax.Tax" %>
<%
request.setCharacterEncoding("utf-8");
String strSenderKey = StrUtil.nvl(request.getParameter("senderKey"), ConfigurationMgr.getInstance().getString("ETAX_SENDER_CODE"));

InvoiceDAO dao = new InvoiceDAO();
ArrayList<InvoiceVO> arr = dao.T_BILL_STATUS_PROC(strSenderKey);
if (arr!=null && arr.size()>0) {
  ArrayOfString mgtKeyList = new ArrayOfString();
  for (InvoiceVO v : arr) {
    if (v.BILL_STATUS>0 && v.BILL_STATUS!=4 && v.BILL_STATUS!=5) mgtKeyList.getString().add(v.BILL_SENDER_KEY + v.BILL_SEQ);
  }
  ArrayList<String[]> status = new Tax().getStatus(mgtKeyList);
  if (status!=null && status.size()>0) {
    for (String[] s : status) {
      dao.T_BILL_UPDATE_STATUS_PROC(Integer.parseInt(s[1].substring(5)), Integer.parseInt(s[0]), s[2]);
    }
  }
}
%>