<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.trade.PayMethodVO" %>
<%@ page import="kr.co.mp.trade.GuaranteeBean" %>
<%!
String getGuarLocGubunName(String guarLocGubun) {
  switch (guarLocGubun) {
	case "KR":
	  return "보증재단연합회";
	case "CG":
	  return "신보";
	case "KG":
	  return "기보";
	case "GG":
	  return "전문공제조합";
	case "BB":
	  return "비보증";
	case "SG":
	  return "서보";
	default :
	  return "";
  }
}
%>
<%
request.setCharacterEncoding("utf-8");
kr.co.mp.trade.PayMethodVO pvo  = new kr.co.mp.trade.PayMethodVO();
String strPage = (StrUtil.nvl(request.getParameter("page"), "1"));
if (StrUtil.isOnlyNumeric(strPage)) pvo.PAGE = Integer.parseInt(strPage);
else pvo.PAGE = 1;

pvo.ROW_CNT = 10;
pvo.GUAR_LOC_DESC = StrUtil.nvl(request.getParameter("branch"));
ArrayList<kr.co.mp.trade.PayMethodVO> arr = new GuaranteeBean().GUARANTEE_LOCATION_SEARCH_PROC(pvo);
int intTotalCnt = 0;
%>
<ul>
<%
if (arr!=null && arr.size()>0) {
  for (int i = 0; i < arr.size();) {
	  kr.co.mp.trade.PayMethodVO v = arr.remove(i);
    intTotalCnt = v.TOTAL_CNT;
%>
<li onclick='choiceBranch(this);' gid='<%=v.GUAR_LOC %>'><%=v.GUAR_LOC_DESC %> [<%=getGuarLocGubunName(v.GUAR_LOC_GUBUN) %>] </li>
<%
  }
}
%>
</ul>
<%
if (intTotalCnt > (pvo.PAGE*pvo.ROW_CNT)) {
  out.print("<div style='text-align:center;margin-top:20px;'><a onclick='goBranchSearchPageForPopup("+(pvo.PAGE+1)+")' class='btn'>더보기</a></div>");
}
%>
