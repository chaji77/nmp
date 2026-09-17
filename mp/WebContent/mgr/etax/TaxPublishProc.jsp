<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.mptax.*" %>
<%@ page import="kr.co.mp.kakaotalk.TalkCtrl" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String[] seqs = request.getParameterValues("billseq");

InvoiceDAO dao = new InvoiceDAO();
Tax tax = new Tax();
int intResult = 0;

for (int i=0; i<seqs.length; i++) {
  if (StrUtil.isOnlyNumeric(seqs[i])) {
    int intBillSeq = Integer.parseInt(seqs[i]);
    System.out.println(intBillSeq);
    InvoiceVO vo = dao.T_BILL_DETAIL_PROC(intBillSeq);
    try {
      System.out.println(vo.toString());
      int intTaxResult = tax.RegistAndIssueTaxInvoice(vo);
      System.out.println(intBillSeq + " >>>>>> " + intTaxResult);
      dao.T_BILL_UPDATE_STATUS_PROC(intBillSeq, intTaxResult, "");
      if (intTaxResult==1) { // SEND MESSAGE VIA KAKAOTALK
        TalkCtrl.sendBySystem("M003", 0, 0, intBillSeq);
      }
    } catch (Exception e) {}
  }
}

%>
<script>
parent.hideSpinner();
parent.toast("완료되었습니다.", 1000, function() {parent.location.reload(); });
</script>
