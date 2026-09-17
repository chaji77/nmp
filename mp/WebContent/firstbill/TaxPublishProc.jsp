<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Enumeration" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.firstbill.*" %>
<%
request.setCharacterEncoding("utf-8");
String strUserSeq = StrUtil.nvl((String)session.getAttribute("SESS_BILL_USER_SEQ"), "0");
String strUserId  = StrUtil.nvl((String)session.getAttribute("SESS_USER_ID"), "");
String[] seqs = request.getParameterValues("billseq");

int intResult = 0;

for (int i=0; i<seqs.length; i++) {
  if (StrUtil.isOnlyNumeric(seqs[i])) {
    int intBillSeq = Integer.parseInt(seqs[i]);
    System.out.println(intBillSeq);
    InvoiceVO vo = InvoiceDAO.BILL_DETAIL_PROC(intBillSeq);
    try {
      BillUserVO v = BillUserDAO.BILL_USER_DETAIL_PROC(Integer.parseInt(strUserSeq));
      FirstBillCtrl c = new FirstBillCtrl(v);
      int intTaxResult = c.RegistAndIssueTaxInvoice(vo, strUserId);
      System.out.println(strUserId + ":" + intBillSeq + ":" + intTaxResult);
      if (intTaxResult == -26001 || intTaxResult == -26002 || intTaxResult == -26003) {
        intResult = -2;
        break;
      } else {
        InvoiceDAO.BILL_UPDATE_STATUS_PROC(intBillSeq, intTaxResult);
      }
    } catch (Exception e) {}
  }
}

%>
<script>
parent.hideSpinner();
<%
if (intResult==-2) {
%>
parent.showAlert("발행에 필요한 공동인증서가 유효하지 않습니다.<br/>인증서관리메뉴를 이용하십시오.", function() {});
<%
} else {
%>
parent.toast("완료되었습니다.", 1000, function() {parent.location.reload(); });
<%
}
%>
</script>
