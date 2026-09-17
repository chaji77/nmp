<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.mgr.sales.MpFeeCalcurator" %>
<%
int intCtId = Integer.parseInt(StrUtil.nvl(request.getParameter("ctid"), "0"));
if (intCtId!=0) {
	MpFeeCalcurator c = new MpFeeCalcurator();
	c.execute(intCtId);
	out.print("{\"payer\":\""+c.getPayCpy()+"\",");
	out.print("\"method\":\""+c.getMethod()+"\",");
	out.print("\"rate\":\""+c.getRate()+"\",");
	out.print("\"sum\":\""+StrUtil.convertNumberFormat("0", c.getAmt())+"\",");
	out.print("\"supply\":\""+StrUtil.convertNumberFormat("0", c.getSupplyAmt())+"\",");
	out.print("\"tax\":\""+StrUtil.convertNumberFormat("0", c.getTaxAmt())+"\"}");
}
%>