<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.util.tax.*" %>
<%@ page import="kr.co.mp.trade.TaxVO" %>
<%@ page import="kr.co.mp.trade.TaxBean" %>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%
// System.out.println("BillAddProc.jsp");

String strXml = StrUtil.nvl(request.getParameter("result_string"));
int intTotalCnt = 0;
int intDuplicatedCnt = 0;
String strErrorMsg = "";
try {
  String[] arr = strXml.replaceAll("<LIST>", "").split("</LIST>");
  intTotalCnt = arr.length;
  if (intTotalCnt>0) {
    for (int i=0; i<intTotalCnt; i++) {
      TaxInvoiceVO vo = TaxUtil.parseTaxInvoice(arr[i]);
      // System.out.println(vo.toString());
      int intSeq = new TaxBean().CT_BILL_ADD_PROC(vo, Integer.parseInt((String)pageContext.getAttribute("CPY_ID")));
      if (intSeq==0) intDuplicatedCnt++;
    }
  }
} catch (Exception e) {
  intTotalCnt = 0;
  intDuplicatedCnt = 0;
  strErrorMsg = "세금계산서 첨부에 실패했습니다. 고객센터에 문의바랍니다.";
}
%>
<script>
parent.savedXml(<%=intTotalCnt %>, <%=intDuplicatedCnt %>, "<%=strErrorMsg %>");
</script>