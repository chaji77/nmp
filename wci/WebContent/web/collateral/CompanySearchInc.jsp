<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap"%>
<%@ page import="java.util.Map"%>
<%@ page import="kr.co.funology.fw.util.StrUtil"%>
<%@ page import="kr.co.funology.fw.util.FormatUtil"%>
<%@ page import="legacy.EnumData"%>
<%@ page import="legacy.LegacyQuery"%>
<%
request.setCharacterEncoding("utf-8");

String strPath  = ((String)pageContext.getServletContext().getRealPath("/"))+"web/collateral/sql.xml";
String strName  = StrUtil.nvl(request.getParameter("nm"));
String strPage  = StrUtil.nvl(request.getParameter("page"));
int intTotalCnt = 0;

LegacyQuery q   = new LegacyQuery(strPath);
String[] params = new String[3];
int i = 0;
params[i++] = strName;
params[i++] = strPage;
params[i++] = strPage;
ArrayList<Map<String, String>> arr = null;
if (!strName.equals("")) {
  arr = q.select("Grt_Company_SearchVO", params);
}
%>
<table class="detail clickable-tr">
<thead>
<tr>
  <th class='left'>회사명</th>
  <th class='left'>대표자명</th>
  <th class='left'>사업자번호</th>
  <th class='left'>주소</th>
</tr>
</thead>
<tbody>
<%
  if (arr!=null && arr.size()>0) {
    String str = "";
    Map<String, String> col = arr.remove(0); // COLUMN NAMES
    for (Map<String, String> vo : arr) {
      intTotalCnt = Integer.parseInt(vo.get("TOTAL_CNT"));
  %>
  <tr onclick='chooseThis(<%=vo.get("CPY_ID")%>, "<%=vo.get("ADR_ZIPCODE") %>", this);'>
    <td class='left'><%=vo.get("CPY_NAME") %></td>
    <td class='left'><%=vo.get("CPY_CEO_NAME") %></td>
    <td class='left'><%=vo.get("CPY_BUSINESS_NO") %></td>
    <td class='left'><%=vo.get("ADR_DESC") %></td>
  </tr>
  <%
    }
  }
%>
</tbody>
</table>

  <!-- 페이징 -->
  <div id="my-paging">
  <script>
  setPaging('#my-paging', 'goPage','<%=strPage%>', '<%=intTotalCnt%>', '10', 5, '');
  </script>
  </div>

