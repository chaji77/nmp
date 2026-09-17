<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.mptax.*" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String[] seqs = request.getParameterValues("billseq");
String seq = String.join(",", seqs);
System.out.println(seq);
boolean is = new InvoiceDAO().T_BILL_DROP_PROC(seq, Integer.parseInt(IntegerCryptoUtil.crypt(StrUtil.nvl((String)session.getAttribute("SESS_MAN_ID"), "0"))));
%>
<script>
parent.hideLoading();
<%
if (is) {
%>
parent.showAlert("삭제되었습니다.", function() {
  parent.goPage(1);
});

<%
} else {
%>
parent.toast("삭제하지 못했습니다. 잠시 후 다시 시도하십시오.");
<%
}
%>
</script>

