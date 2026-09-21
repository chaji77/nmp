<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.c.LoginUtil" %>
<%@ page import="kr.co.mp.common.CodeVO" %>
<%@ page import="kr.co.mp.common.CodeBean" %>
<%@ page import="kr.co.mp.mgr.sales.MpFixedFeeCalcurator" %>
<%
request.setCharacterEncoding("utf-8");
int intCtId = Integer.parseInt(StrUtil.nvl(request.getParameter("ctid"), "0"));
String strMethod = "";
ArrayList<CodeVO> arrCodes = CodeBean.C_CODE_PROC("INFO_COMMISSION.COMM_METHOD");

MpFixedFeeCalcurator calc = new MpFixedFeeCalcurator();
calc.execute(intCtId);
String strPayCpy = (calc.getPayCpy().equals("B")) ? "구매기업" : "판매기업";
if (arrCodes!=null && arrCodes.size()>0) {
  for (CodeVO v : arrCodes) {
    if (v.CODE_CD.equals(calc.getMethod())) strMethod = v.CODE_NM;
  }
}
%>
<style>
ul.calculated li {padding:10px 0;border-bottom:1px solid #ddd;}
</style>
<ul class='calculated'>
  <li><label>부담주체</label><%=strPayCpy%></li>
  <li><label>수수료체계</label><%=strMethod%></li>
  <li><label>수수료율</label><%=calc.getRate()%></li>
  <li><label>결제금액</label><%=StrUtil.addComma(calc.getSettleAmt().setScale(0).toPlainString())%></li>
  <li><label>만기일</label><%=calc.getDiff()%></li>
  <li><label>수수료</label><%=StrUtil.addComma(String.format("%.0f", calc.getAmt())) %></li>
</ul>