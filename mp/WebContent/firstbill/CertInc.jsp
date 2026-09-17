<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.mp.firstbill.*" %>
<%
request.setCharacterEncoding("utf-8");
String strUserSeq = StrUtil.nvl((String)session.getAttribute("SESS_BILL_USER_SEQ"), "0");
if (strUserSeq.equals("0")) {
  response.sendRedirect("index.jsp");
  return;
}
BillUserVO user   = BillUserDAO.BILL_USER_DETAIL_PROC(Integer.parseInt(strUserSeq));
FirstBillCtrl tax = new FirstBillCtrl(user);
String strExpDate = tax.GetCertificateExpireDate();
String strRegUrl  = tax.GetCertificateRegistURL();
String strInfo    = tax.getRegistedInformation();
%>
      <li>
        <label>인증서만료일</label>
        <%
        if (strExpDate.length()==10 && strExpDate.lastIndexOf("-")==7) {
          out.print(strExpDate + " (");
          out.print(DateTimeUtil.diff(DateTimeUtil.getCurrentDate("-"), strExpDate, "-"));
          out.print("일 남음)");
        } else {
          out.print("조회오류 : <strong>인증서를 등록하십시오.</strong>");
        }
        %>
      </li>
      <li>
        <label>인증서관리</label>
        <a href='<%=strRegUrl%>' class='btn' target="_new">이동</a> (30초 이내에 접속해야 합니다.)
      </li>
