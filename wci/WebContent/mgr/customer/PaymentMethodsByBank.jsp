<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.trade.PayMethodVO" %>
<%@ page import="kr.co.mp.trade.GuaranteeBean" %>
<%
request.setCharacterEncoding("utf-8");
String strGuarGubun = StrUtil.nvl(request.getParameter("guar_gubun"));
String strBankCode  = StrUtil.nvl(request.getParameter("bnk_cd"));
String strChoosenPayId = StrUtil.nvl(request.getParameter("pay_id"));
ArrayList<PayMethodVO> arr = new GuaranteeBean().BANK_PAYMENT_LIST_BY_GUAR_AND_BANK_PROC(strGuarGubun, strBankCode);
if (arr!=null && arr.size()>0) {
  for (PayMethodVO v : arr) {
    out.print("<option value='"+v.PAY_ID+"'"+((v.PAY_ID.equals(strChoosenPayId))?" selected":"")+">"+v.PAY_SDESC+"</option>");
  }
}
%>