<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.mgr.manager.ManagerVO" %>
<%@ page import="kr.co.mp.mgr.manager.ManagerBean" %>
<%
request.setCharacterEncoding("utf-8");
String csrf_token = StrUtil.nvl(request.getParameter("csrf-token"));
String rtn = "";
ManagerVO vo = new ManagerVO();
vo.LOGIN_ID  = StrUtil.nvl(request.getParameter("login_id"));
vo.LOGIN_PW  = StrUtil.nvl(request.getParameter("login_pw"));
if (!csrf_token.equals("") && ((String)session.getAttribute("csrf_token")).equals(csrf_token)) {
  ManagerVO r = new ManagerBean().M_MANAGER_LOGIN_PROC(vo);
  if (r.MAN_ID==-1) rtn = "\"isSuccess\":false,\"msg\":\"아이디를 확인하십시오.\"";
  else if (r.MAN_ID==-2) rtn = "\"isSuccess\":false,\"msg\":\"비밀번호를 확인하십시오.\"";
  else {
    session.setAttribute("SESS_LOGIN_ID", vo.LOGIN_ID);
    session.setAttribute("SESS_MAN_ID",   IntegerCryptoUtil.crypt(r.MAN_ID));
    session.setAttribute("SESS_USER_NM",  r.USER_NM);
    rtn = "\"isSuccess\":true";
  }
} else {
  rtn = "\"isSuccess\":false,\"msg\":\"잘못된 접근입니다.\"";
}
out.println("{" + rtn + "}");
%>