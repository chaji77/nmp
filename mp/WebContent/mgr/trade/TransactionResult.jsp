<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.trade.TransactionResultVO" %>
<%@ page import="kr.co.mp.trade.TransactionBean" %>
<%!
String getDocName(String strDocNum) {
  //return (strDocNum.equals("B311")) ? "매매계약" : "결제통보";
  return strDocNum;
}
String getResponseName(String strCode) {
  return (strCode.equals("0000")) ? "정상" : strCode;
}
String formatResponseMsg(String strMsg) {
  String[] labels = {
    "구매기업 휴폐업 여부", "판매기업 휴폐업 여부",
    "구매기업 기준 관계기업 여부", "판매기업 기준 관계기업 여부",
    "구매기업 신용불량 여부", "구매기업 중점관리기업 여부",
    "구매기업 단기연체 여부", "보증서 발급전 거래 여부",
    "기타 오류 여부", "예외처리 여부"
  };
  String[] parts = strMsg.split("\\|");
  if (parts.length != 11) return strMsg;
  StringBuilder sb = new StringBuilder();
  for (int i = 0; i < 10; i++) {
    if ("Y".equals(parts[i].trim())) {
      if (sb.length() > 0) sb.append("<br/>");
      sb.append(labels[i]);
    }
  }
  if (sb.length() > 0) sb.append("<br/>");
  if (!parts[10].trim().equals("000")) {
    sb.append("기타 오류 코드 : ").append(parts[10].trim());
  }
  return sb.toString();
}
%>
<%
request.setCharacterEncoding("utf-8");
int intCtId = Integer.parseInt(StrUtil.nvl(request.getParameter("seq")));
ArrayList<TransactionResultVO> arr = TransactionBean.SEND_XML_B311_LIST_BY_CTID_PROC(intCtId);
String strOrderNo = "";
if (arr!=null && arr.size()>0) strOrderNo = arr.get(0).ORDERNO;
%>
<script>
function syncTransaction(encid, seqno) {
  $.ajax({
    url:strContextPath + "/web/transaction/A181.jsp", 
    type: 'post',
    data:{'ctid':encid,'seqno':seqno}, 
    async: true,
    success: function(data) {
      var json = JSON.parse(data);
      if (json.is) {
        showAlert(json.msg, function() {
          showTransactionResult(<%=intCtId%>);
        });
      } else showAlert("조회하지 못했습니다. 사유는 아래와 같습니다.<br/><br/>" + json.msg);
    },
    beforeSend: function() {
      showSpinner("조회중입니다.<br/>보증기관 및 은행과의 통신에<br/>다소 시간이 걸릴 수 있습니다.");
    },
    complete: function() {
      hideSpinner();
    }
  });
}
</script>

  <h3><%=strOrderNo %> 전송결과</h3>
  
  <table class='detail'>
    <thead>
      <tr>
        <th class='left'>전문</th>
        <th class='left'>기금</th>
        <th class='left'>전송일</th>
        <th class='left'>전송시간</th>
        <th class='left'>결과</th>
        <th class='left'>내용</th>
        <th class='left'>명령</th>
      </tr>
    </thead>
    <tbody>
    <%
    if (arr!=null && arr.size()>0) {
      for (TransactionResultVO v : arr) {
       out.println("<tr>");
       out.print("<td>" + getDocName(v.DOCNUM) + "</td>");
       out.print("<td>" + v.FUND            + "</td>");
       out.print("<td>" + FormatUtil.addSeparatorDate(v.TRANSACTIONDATE, "/") + "</td>");
       out.print("<td>" + v.TRANSACTIONTIME + "</td>");
       out.print("<td>" + getResponseName(v.RESRESPONSECODE) + "</td>");
       out.print("<td>" + formatResponseMsg(v.RESRESPONSEMSG)  + "</td>");
       out.print("<td><a onclick='syncTransaction(\""+IntegerCryptoUtil.crypt(intCtId)+"\",\"" + v.SEQNO  + "\");' class='btn'>A181</a>");
       /* out.print("<td>");
       if (!v.RESRESPONSECODE.equals("0000")) {
         out.print("<a onclick='syncTransaction(\""+IntegerCryptoUtil.crypt(intCtId)+"\",\"" + v.SEQNO  + "\");' class='btn'>A181</a>");
       } */
       out.print("</td>");
       out.println("</tr>");
      }
    }
    %>
    </tbody>
  </table>


  <!-- close -->
  <i class="fa-solid fa-xmark bpopup-close-btn" onclick='closePopup();'></i>