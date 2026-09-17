<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.CryptoDESUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%
request.setCharacterEncoding("utf-8");
////////////////ENCRYPT/DECRYPT ////////////////
String strType   = StrUtil.nvl(request.getParameter("t"), "e");
String strVal    = StrUtil.nvl(request.getParameter("v"), "");
String strResult = "";
if (!strVal.isEmpty()) {
  strResult = (strType.equals("e")) ? CryptoDESUtil.encrypt(strVal) : CryptoDESUtil.decrypt(strVal);
}

String strNumVal    = StrUtil.nvl(request.getParameter("vn"), "");
String strNumResult = "";
if (!strNumVal.isEmpty()) {
  strNumResult = IntegerCryptoUtil.crypt(strNumVal);
}
%>
<%@ include file="../web/includes/Header.jsp" %>
<title>암복호화도구</title>
</head>
<body style='padding:30px;color:#000;'>

<%@ include file='tab.jsp' %>

  <form name='frmEnt' method='post'>
  <input type='hidden' name='gc' value=''>
  <h3>암복호화도구</h3>
  <table class='list detail' style='width:auto;'>
    <tr>
      <th class='left'>TYPE</th>
      <th class='left'>REQUEST</th>
      <th class='left'>RESULT</th>
    </tr>
    <tr>
      <th class='left'>STRING</th>
      <td>
        <select name='t' style='width:100px;'>
          <option value='e' <%=(strType.equals("e"))?" selected":"" %>>암호화</option>
          <option value='d' <%=(strType.equals("d"))?" selected":"" %>>복호화</option>
        </select>
        <input type='text' name='v' value='<%=strVal %>' style='width:200px;'>
        <a class='btn' onclick="document.frmEnt.submit();">제출</a>
      </td>
      <td><% if (!strResult.equals("")) out.print(strResult); %></td>
    </tr>
    <tr>
      <th class='left'>NUMBER</th>
      <td>
        <input type='text' name='vn' value='<%=strNumVal %>' style='width:200px;'>
        <a class='btn' onclick="document.frmEnt.submit();">제출</a>
      </td>
      <td><% if (!strNumResult.equals("")) out.print(strNumResult); %></td>
    </tr>
  </table>
  </form>

</body>
</html>