<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.c.regreq.RegReqVO" %>
<%@ page import="kr.co.mp.c.regreq.RegReqBean" %>
<%
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../../includes/LoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
int intCpyId = Integer.parseInt((String)pageContext.getAttribute("CPY_ID"));

RegReqVO vo = new RegReqVO();
vo.BUY_CPY_ID           = intCpyId;
vo.SELL_CPY_NAME        = StrUtil.nvl(request.getParameter("sellCpyName"));
vo.SELL_PHONE           = StrUtil.nvl(request.getParameter("sellPhone"));
vo.SELL_PRS_NAME        = StrUtil.nvl(request.getParameter("sellPrsName"));
vo.SELL_FAX             = StrUtil.nvl(request.getParameter("sellFax"));
vo.SELL_EMAIL           = StrUtil.nvl(request.getParameter("sellEmail"));
vo.SELL_CPY_BUSINESS_NO = StrUtil.nvl(request.getParameter("sellCpyBusinessNo")).replaceAll("-", "");
vo.TRADE_DATE           = StrUtil.nvl(request.getParameter("tradeDate"));
String strFeePay        = StrUtil.nvl(request.getParameter("feePay"));
vo.FEE_PAY              = (!strFeePay.isEmpty() && StrUtil.isOnlyNumeric(strFeePay)) ? Integer.parseInt(strFeePay) : 0;
vo.MEMO                 = StrUtil.nvl(request.getParameter("memo"));
vo.REQ_STATUS           = 1;

out.println(new RegReqBean().COMPANY_REG_REQ_ADD_PROC(vo));
%>