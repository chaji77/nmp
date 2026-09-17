<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.trade.CtHeaderVO" %>
<%@ page import="kr.co.mp.trade.TradeBean" %>
<%
request.setCharacterEncoding("utf-8");
int intCpyId       = Integer.parseInt(StrUtil.nvl(request.getParameter("cpy_id"), "0"));
String strPageCode = "S";

CtHeaderVO pvo     = new CtHeaderVO();
pvo.PAGE           = 1;
pvo.ROW_CNT        = 1;
pvo.STATUS         = "010";
String strStartYmd = DateTimeUtil.diff(DateTimeUtil.getCurrentDate("-"), 31, "-");
String strEndYmd   = DateTimeUtil.getCurrentDate("-");
int intTargetCpyId = 0;
int intTotalCnt    = 0;

try {
  ArrayList<CtHeaderVO> arr = new TradeBean().CT_HEADER_LIST_PROC(pvo, intCpyId, strStartYmd, strEndYmd, intTargetCpyId, strPageCode, 0);
  intTotalCnt = (arr.get(0)).TOTAL_CNT;
} catch (Exception e) {
}
out.print(intTotalCnt);
%>
