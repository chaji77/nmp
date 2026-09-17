<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Map"%>
<%@ page import="kr.co.funology.fw.util.StrUtil"%>
<%@ page import="kr.co.funology.fw.util.FormatUtil"%>
<%@ page import="legacy.EnumData"%>
<%@ page import="legacy.LegacyQuery"%>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../../includes/LoginCheck.jsp" %>
<%
//String strCpyId = "8063"; // TEST MODE
String strCpyId = (String)pageContext.getAttribute("CPY_ID");
String strPath       = ((String)pageContext.getServletContext().getRealPath("/"))+"web/collateral/kibo/sql.xml";
String strQueryId    = "Grt_Application_ListVO";
String strBuyerName  = "";
String strSellerName = "";
String strStartYmd   = "19900101";
String strEndYmd     = "20991231";
String strStatus     = StrUtil.nvl(request.getParameter("seStatus"));

LegacyQuery q = new LegacyQuery(strPath);
String[] params = new String[9];
int i = 0;
params[i++] = strBuyerName;
params[i++] = strSellerName;
params[i++] = strCpyId;
params[i++] = strCpyId;
params[i++] = strStartYmd;
params[i++] = strEndYmd;
params[i++] = strStatus;
params[i++] = strStatus;
params[i++] = strStatus;

ArrayList<Map<String, String>> arr = q.select(strQueryId, params);
%>
<%@ include file="../../includes/Header.jsp" %>
<!-- page head block -->
<title>보증신청현황</title>
<script>
function view(no) {
  document.frmSearch.applNO.value = no;
  document.frmSearch.action = "IssueView.jsp";
  document.frmSearch.submit();
}
function goPage() {
  document.frmSearch.action = "index.jsp";
  document.frmSearch.submit();
}
</script>
<!-- // page head block -->
<%@ include file="../../includes/Navigation.jsp" %>
<%@ include file="tab.jsp" %>

<div class='page-title-block'>
  <span class='title'>보증신청현황</span>
  <span class='more'>
    <a href='Registration.jsp' class='btn darkred' style='padding:14px 20px;font-weight:bold;'>보증신청</a>
  </span>
</div>

<form name='frmSearch' method='post'>
<input type='hidden' name='applNO' value=''>
<table class='searchbox mobile_hide'>
<tbody>
  <tr>
    <td>
      <ul>
        <li>
          <label>보증상태</label>
          <select name="seStatus">
            <option value="" selected>전체</option>
            <option value="010" <%=(strStatus.equals("010"))?"selected":""%>>MP신청</option>
            <option value="020" <%=(strStatus.equals("020"))?"selected":""%>>기금신청</option>
            <option value="030" <%=(strStatus.equals("030"))?"selected":""%>>접수</option>
            <option value="040" <%=(strStatus.equals("040"))?"selected":""%>>승인</option>
            <option value="050" <%=(strStatus.equals("050"))?"selected":""%>>발급</option>
            <option value="080" <%=(strStatus.equals("080"))?"selected":""%>>해지</option>
            <option value="090" <%=(strStatus.equals("090"))?"selected":""%>>취소</option>
          </select>
        </li>
        <li>
          <label>판매기업</label>
          <input type="search" name="txt_cpyName" maxlength='20' placeholder='판매기업명'>
        </li>
      </ul>
    </td>
    <td class='fill'></td>
    <td class='btn'><a onclick='goPage();' class='btn' style='padding-top:10px;'>검색</a></td>
  </tr>
</tbody>
</table>
</form>

<table class='detail'>
  <thead>
    <tr>
      <th class='left'>보증신청번호</th>
      <th class='left'>보증번호</th>
      <th class='left'>판매기업</th>
      <th class='center'>신청일자</th>
      <th class='right'>신청금액</th>
      <th class='right'>처리금액</th>
      <th class='center'>상태</th>
      <th class='left'>최종처리일시</th>
      <th class='center'>명령</th>
    </tr>
  </thead>
  <tbody>
<%
if (arr!=null && arr.size()>0) {
  Map<String, String> col = arr.remove(0); // COLUMN NAMES
  for (Map<String, String> vo : arr) {
    out.print("<tr>");
    out.print("<td>"+vo.get("APPLNO")+"</td>");
    out.print("<td>"+vo.get("GRTNO")+"</td>");
    out.print("<td>"+vo.get("SELLNAME")+"</td>");
    out.print("<td class='center'>"+FormatUtil.addSeparatorDate(vo.get("MP_APPLYMD"),".")+"</td>");
    out.print("<td class='right'>"+StrUtil.addComma(vo.get("MP_APPLAMT"))+"</td>");
    out.print("<td class='right'>"+StrUtil.addComma(vo.get("KCGF_AMT"))+"</td>");
    out.print("<td class='center'>"+(EnumData.getStatusDesc()).get(vo.get("STATUS"))+"</td>");
    out.print("<td>"+FormatUtil.addSeparatorDateTime(vo.get("STATUS_YMDHMS"), ".")+"</td>");
    out.print("<td class='center'>");
    if(vo.get("STATUS").equals(EnumData.MP_APPLICATION_STATUS)) {
      out.print("<a onclick=\"modify('"+vo.get("APPLNO")+"');\" class='btn'>변경신청</a>");
      out.print("<a onclick=\"cancel('"+vo.get("APPLNO")+"');\" class='btn'>취소</a>");
    } else if(vo.get("STATUS").equals(EnumData.ISSUE_STATUS)) {
      out.print("<a onclick=\"view('"+vo.get("APPLNO")+"');\" class='btn'>발급내역</a>");
    }
    out.print("</td>");
    /*
    for (i=1; i<=Integer.parseInt(col.get("COL_CNT")); i++) {
      out.println("<td>"+vo.get(col.get(Integer.toString(i)))+"</td>");
    }
    */
    out.println("</tr>");
  }
}
%>
  </tbody>
</table>

<%@ include file="../../includes/Footer.jsp" %>