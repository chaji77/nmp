<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.CryptoDESUtil" %>
<%@ page import="kr.co.mp.c.PersonVO" %>
<%@ page import="kr.co.mp.c.CustomerBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
Logger logger = Logger.getLogger("ManagerRegProc.jsp");

String strPrsId    = StrUtil.nvl(request.getParameter("pid"));
int intPrsId = 0;
if (!StrUtil.isOnlyNumeric(strPrsId)) return;

boolean isError = false;
String strErrorMsg = "";

int intResult = -1;

PersonVO pvo = new PersonVO();
int intCpyId = Integer.parseInt(StrUtil.nvl(request.getParameter("cid"), "0"));
pvo.PRS_ID = strPrsId;
pvo.PRS_NAME = StrUtil.xss(request.getParameter("prs_name"));
pvo.PRS_TEL = StrUtil.xss(request.getParameter("tel"));
pvo.PRS_PASSWD = CryptoDESUtil.encrypt(StrUtil.nvl(request.getParameter("login_pw")));
pvo.PRS_EMAIL = StrUtil.xss(request.getParameter("email"));
pvo.PRS_MOBILE_NO = StrUtil.xss(request.getParameter("cell_tel"));
pvo.PRS_SMS = StrUtil.nvl(request.getParameter("sms_yn"), "0");

intResult = new CustomerBean().PERSON_MOD_PROC(intCpyId, pvo);
out.print(intResult);
%>