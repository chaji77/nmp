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

int intCpyId       = Integer.parseInt(StrUtil.nvl(request.getParameter("cpy_id")));
int intPrsId       = Integer.parseInt(StrUtil.nvl(request.getParameter("prs_id")));
String strPageCode = StrUtil.nvl(request.getParameter("page_code"));
String strPageTitle= (strPageCode.equals("R")) ? "받은 계약서" : "보낸 계약서";
strPageTitle       = (strPageCode.equals("M")) ? "만기미도래 계약서" : strPageTitle;
String strDetail   = StrUtil.nvl(request.getParameter("detail_page"), "Contract.jsp");
String strTempYn   = "N";

CtHeaderVO pvo     = new CtHeaderVO();
pvo.PAGE           = Integer.parseInt(StrUtil.nvl(request.getParameter("page"), "1"));
pvo.ROW_CNT        = 10000;
pvo.STATUS         = StrUtil.nvl(request.getParameter("status"), "");
pvo.CTNO           = StrUtil.nvl(request.getParameter("ctno"), "");
pvo.SBDATE         = StrUtil.nvl(request.getParameter("sbdate"), "R");
String strStartYmd = StrUtil.nvl(request.getParameter("start_ymd"), DateTimeUtil.diff(DateTimeUtil.getCurrentDate("-"), 31, "-"));
String strEndYmd   = StrUtil.nvl(request.getParameter("end_ymd"), DateTimeUtil.getCurrentDate("-"));
int intTargetCpyId = Integer.parseInt(StrUtil.nvl(request.getParameter("tc"), "0"));
int intTotalCnt    = 0;

TradeBean bean = new TradeBean();
ArrayList<CtHeaderVO> arr;
try {
  if (strPageCode.equals("M")) arr = bean.CT_HEADER_COMING_LIST_PROC(pvo, intCpyId, strStartYmd, strEndYmd);
  else arr = bean.CT_HEADER_LIST_PROC(pvo, intCpyId, strStartYmd, strEndYmd, intTargetCpyId, strPageCode, intPrsId);
  intTotalCnt = (arr.get(0)).TOTAL_CNT;
} catch (Exception e) {
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
      <th>판매기업</th>
      <th>결제금액</th>
      <th>진행상태</th>
    </tr>
  </thead>
  <tbody>
<%
if (arr!=null && arr.size()>0) {
  for (CtHeaderVO vo : arr) {
    String strReplacedStatusName = vo.CODE_NM;
%>
    <tr>
      <td><%=StrUtil.nvl(vo.CTNO) %></td>
      <td><%=FormatUtil.addSeparatorDate(vo.CONTRACTDATE) %></td>
      <td><%=FormatUtil.addSeparatorDate(vo.REGDATE) %>
      <td><%=FormatUtil.addSeparatorDate(vo.MTYDATE) %></td>
      <td><%=vo.BNK_NAME %> <%=vo.PAY_SDESC %></td>
      <td><%=vo.BUYER_NM %></td>
      <td><%=vo.SELLER_NM %></td>
      <td><%=StrUtil.addComma(vo.TOTALCONTRACTAMT) %></td>
      <td><%=strReplacedStatusName %></td>
    </tr>
<%
  }
} else out.println("<tr><td colspan='9'>검색조건에 맞는 계약서가 없습니다.</td></tr>");
%>
  </tbody>
</table>
</body>
</html>
