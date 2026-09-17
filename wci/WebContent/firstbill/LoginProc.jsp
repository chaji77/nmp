<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.CryptoDESUtil" %>
<%@ page import="kr.co.mp.firstbill.*" %>
<%
request.setCharacterEncoding("utf-8");
Logger logger = Logger.getLogger("RegistProc.jsp");

int intResult = -1;
BillUserVO cvo = new BillUserVO();
try {
  cvo.CPY_ID = 0;
  cvo.ID  = StrUtil.xss(request.getParameter("login_id"));
  cvo.PWD = StrUtil.nvl(request.getParameter("login_pw"));
  cvo = BillUserDAO.BILL_USER_LOGIN_PROC(cvo.ID, cvo.PWD);
  if (cvo.CPY_ID>0) {
    session.setAttribute("SESS_BILL_USER_SEQ", cvo.USER_SEQ);
    session.setAttribute("SESS_USER_ID",       cvo.ID);
    session.setAttribute("SESS_BILL_CPY_ID",   Integer.toString(cvo.CPY_ID));
    session.setAttribute("SESS_BILL_CPY_NM",   cvo.CORPNAME);
    session.setAttribute("SESS_BILL_USER_NM",  cvo.MEMBERNAME);
    session.removeAttribute("csrf_token");
    intResult = 1;
  } else intResult = 0;
} catch (Exception e) {
  intResult = -1;
}

out.print(intResult);
%>
