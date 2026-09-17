<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.net.URLDecoder" %>
<%@ page import="java.util.List" %>
<%@ page import="com.baroservice.ws.Contact" %>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.FormatUtil" %>
<%@ page import="kr.co.mp.mptax.Tax" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
/* get parameters and set variables */
request.setCharacterEncoding("utf-8");
%>
<%@ include file="../Header.jsp" %>
<!-- page head block -->
<title>세금계산서연동관리</title>

<!-- // page head block -->
<%@ include file="../Navigation.jsp" %>

<div class='page-title-block memo-page'>
  <span class='title'>세금계산서연동관리</span>
  <span class='more'>
    <a class='btn magnify white mobile_show'></a>
  </span>
</div>

<%
Tax tax = new Tax();
String strUrl     = tax.GetBaroBillURL();
String strExpDate = tax.GetCertificateExpireDate();
String strRegUrl  = tax.GetCertificateRegistURL();
List<Contact> manager = tax.getContacts();
String strInfo    = tax.getRegistedInformation();
%>

  <div style='margin:0px 0px 10px 0px;padding-top:10px;border-top:1px solid #eee;'>관리정보의 변경은 연동테스트 및 계정보안을 위해 지정된 관리자에게 문의하십시오.</div>
  <table class='list detail'>
    <colgroup>
      <col width='100'/>
      <col width='*'/>
    </colgroup>
    <tr>
      <th>관리사이트</th>
      <td><a href='<%=strUrl %>' class='btn' target="_new">이동</a> (30초 이내에 접속해야 합니다.)</td>
    </tr>
    <tr>
      <th>인증서만료일</th>
      <td>
      <%
      if (strExpDate.length()==10 && strExpDate.lastIndexOf("-")==7) {
       out.print(strExpDate + " (");
       out.print(DateTimeUtil.diff(DateTimeUtil.getCurrentDate("-"), strExpDate, "-"));
       out.print(" 남음)");
      } else {
        out.print("조회오류");
      }
      %>
      </td>
    </tr>
    <tr>
      <th>인증서관리</th>
      <td><a href='<%=strRegUrl%>' class='btn' target="_new">이동</a> (30초 이내에 접속해야 합니다.)</td>
    </tr>
    <tr>
      <th>관리담당자</th>
      <td>
        <ul>
      <%
      for (Contact c : manager) {
        out.print("<li>");
        out.print(c.getContactName());
        out.print(" (" + c.getID() + ", ");
        out.print(c.getEmail() + ", ");
        out.print(c.getTEL() + ")");
        out.print("</li>");
      }
      %>
        </ul>
      </td>
    </tr>
    <%=strInfo %>
  </table>

<iframe name="work" id="work" height="800" width="1000" style="display:none;"></iframe>
<%@ include file="../Footer.jsp" %>


