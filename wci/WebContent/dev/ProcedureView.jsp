<%@ page contentType="text/html;charset=utf-8" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.mgr.ConnectionMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.WrapPreparedStatementUtil" %>
<%@ include file="../web/includes/Header.jsp" %>
<%!
ArrayList<String> getProcedure(String strProcedureName) {
    ArrayList<String> arr = new ArrayList<>();
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    ResultSet rs = null;
    try {
      String query = "EXEC SP_HELPTEXT ?;";
      ps = new WrapPreparedStatementUtil(conn, query);
      int i = 1;
      ps.setString(i++, strProcedureName);
      rs = ps.executeQuery();
      while(rs.next()) {
        arr.add(rs.getString("Text"));
      }
    } catch (Exception e) {
      System.out.println(ps.getQueryString());
      System.out.println(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return arr;
}
%>
<%
String strProcedureName = StrUtil.nvl(request.getParameter("sp"));
%>
<!-- page head block -->
<title>기초매뉴얼</title>
</head>
<body style='padding:30px;color:#000;'>
<h3><%=strProcedureName %></h3>
<hr/>
<pre>
<%
if (!strProcedureName.equals("")) {
  ArrayList<String> arr = getProcedure(strProcedureName);
  if (arr!=null && arr.size()>0) {
    for (String s : arr) {
      out.print(s);
    }
  }
}
%>
</pre>
</body>
</html>