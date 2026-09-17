<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.trade.CtHeaderVO" %>
<%@ page import="kr.co.mp.trade.TradeBean" %>
<%
request.setCharacterEncoding("utf-8");

int intCpyId       = Integer.parseInt(StrUtil.nvl(request.getParameter("cpy_id"), "0"));
int intPrsId       = Integer.parseInt(StrUtil.nvl(request.getParameter("prs_id"), "0"));
String strCpyNm    = StrUtil.nvl(request.getParameter("cpy_nm"), "");
String strPageCode = StrUtil.nvl(request.getParameter("page_code"));
String strPageTitle= "거래관리";
String strDetail   = StrUtil.nvl(request.getParameter("detail_page"), "Contract.jsp");
String strTempYn   = "N";

CtHeaderVO pvo     = new CtHeaderVO();
pvo.PAGE           = Integer.parseInt(StrUtil.nvl(request.getParameter("page"), "1"));
pvo.ROW_CNT        = 3000;
pvo.STATUS         = StrUtil.nvl(request.getParameter("status"), "");
pvo.CTNO           = StrUtil.nvl(request.getParameter("ctno"), "");
pvo.SBDATE         = StrUtil.nvl(request.getParameter("sbdate"), "R");
String strStartYmd = StrUtil.nvl(request.getParameter("start_ymd"), DateTimeUtil.diff(DateTimeUtil.getCurrentDate("-"), 31, "-"));
String strEndYmd   = StrUtil.nvl(request.getParameter("end_ymd"), DateTimeUtil.getCurrentDate("-"));


TradeBean bean = new TradeBean();
ArrayList<CtHeaderVO> arr = null;
try {
  arr = bean.CT_HEADER_LIST_PROC(pvo, intCpyId, strStartYmd, strEndYmd, 0, "A", 0);
  if (arr != null && arr.size() > 0) {
      String strCtIds = "";
      String strCtNos = "";
      for (CtHeaderVO v : arr) {
          strCtIds += "," + v.CTID;
          strCtNos += "," + v.CTNO;
      }
  }
} catch(Exception e) {
  arr = null;
}
%>
<!DOCTYPE HTML>
<html>
<head>
<meta charset="utf-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Cache-Control" content="no-cache">
<%
  response.setHeader("Content-Type", "application/vnd.ms-xls");
  String fn = strPageTitle + "("+strStartYmd.replaceAll("-", "")+"-"+strEndYmd.replaceAll("-", "")+").xls";
  fn = new String(fn.getBytes("utf-8"), "8859_1");
  response.setHeader("Content-Disposition", "inline; filename="+fn);
%>
</head>
<body>
<table id='excel'>
  <thead>
    <tr>
      <th>계약번호</th>
      <th>계약일</th>
      <th>거래일</th>
      <th>만기일</th>
      <th>은행/결제수단</th>
      <th>구매기업</th>
      <th>구매사업자등록번호</th>
      <th>판매기업</th>
      <th>판매사업자등록번호</th>
      <th>결제금액</th>
      <th>수수료부담</th>
      <th>수수료</th>
      <th>결제일</th>
      <th>진행상태</th>
    </tr>
  </thead>
  <tbody>
<%
if (arr!=null && arr.size()>0) {
  for (CtHeaderVO vo : arr) {
    String strReplacedStatusName = vo.CODE_NM;
    String strFeePayerNm = "";
    if (StrUtil.nvl(vo.MPPAYCPY).equals("1")) {
      strFeePayerNm = "판매"; 
    } else if (StrUtil.nvl(vo.MPPAYCPY).equals("2")) {
      strFeePayerNm = "구매";  
    }
    
%>
    <tr>
      <td><%=StrUtil.nvl(vo.CTNO) %></td>
      <td><%=FormatUtil.addSeparatorDate(vo.CONTRACTDATE) %></td>
      <td><%=FormatUtil.addSeparatorDate(vo.REGDATE) %></td>
      <td><%=FormatUtil.addSeparatorDate(vo.MTYDATE) %></td>
      <td><%=vo.BNK_NAME %> <%=vo.PAY_SDESC %></td>
      <td><%=vo.BUYER_NM %></td>
      <td><%=StrUtil.nvl(vo.BUYER_BIZ_NO) %></td>
      <td><%=vo.SELLER_NM %></td>
      <td><%=StrUtil.nvl(vo.SELLER_BIZ_NO) %></td>
      <td><%=StrUtil.addComma(vo.TOTALCONTRACTAMT) %></td>
      <td><%=strFeePayerNm %></td>
      <td><%=vo.MPFEE_TOTALAMT%></td>
      <td><%=FormatUtil.addSeparatorDate(StrUtil.nvl(vo.SETTLEDATE)) %></td>
      <td><%=strReplacedStatusName %></td>
    </tr>
<%
  }
} else out.println("<tr><td colspan='13'>검색조건에 맞는 계약서가 없습니다.</td></tr>");
%>
  </tbody>
</table>
</body>
</html>
