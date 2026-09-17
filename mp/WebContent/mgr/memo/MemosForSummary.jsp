<%@ page contentType="text/xml;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.funology.fw.util.HtmlWhiteListUtil" %>
<%@ page import="kr.co.mp.common.CodeVO" %>
<%@ page import="kr.co.mp.common.CodeBean" %>
<%@ page import="kr.co.mp.mgr.memo.MemoVO" %>
<%@ page import="kr.co.mp.mgr.memo.MemoBean" %>
<%
request.setCharacterEncoding("utf-8");

int intTotalCnt = 0;
String strMyYn  = "N";
MemoVO pvo      = new MemoVO();
pvo.PAGE        = Integer.parseInt(StrUtil.nvl(request.getParameter("page"), "1"));
pvo.ROW_CNT     = 86*20;
pvo.CPY_ID      = 0;
pvo.TO_USER_ID  = "";
String strCpyNm = "";

ArrayList<CodeVO> arrCodes = CodeBean.C_CODE_PROC("ACTIVE_MANAGEMENT.ACTIVE_KIND");
ArrayList<MemoVO> arr = new MemoBean().ACTIVE_MANAGEMENT_LIST_PER_CPY_ID_PROC(pvo);
%>
<?xml version="1.0" encoding="UTF-8"?>
<root>
<%
if (arr!=null && arr.size()>0) {
  String strCodeName = "";
  for (MemoVO t : arr) {
    intTotalCnt = t.TOTAL_CNT;
    if (arrCodes!=null && arrCodes.size()>0) {
      for (CodeVO c : arrCodes) {
        if (c.CODE_CD.trim().equals(t.ACTIVE_KIND.trim())) strCodeName = c.CODE_NM;
      }
    }
    String strDesc = HtmlWhiteListUtil.filter(t.ACTIVE_DESC).replaceAll("&quot;", "");
    String toUser  = StrUtil.nvl(t.TO_USER_NM, "");
    if (!toUser.equals("")) toUser = "<span class='to'><i class='fa-solid fa-location-dot'></i> "+toUser+"</span> ";
%>
    <node>
    
      <class><%=strCodeName %></class>
      <company><%=t.CPY_NAME.replaceAll("&", "&amp;") %></company>
      <bizno><%=FormatUtil.addDashBizNo(t.CPY_BUSINESS_NO) %></bizno>
      <content><![CDATA[<%=strDesc %>]]></content>
      <writer><%=t.USER_NM  %></writer>
      <datetime><%=t.WRITE_DATE.substring(0, 16) %></datetime>
    </node>
<%
  }
}
%>
</root>

