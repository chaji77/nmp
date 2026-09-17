<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.maven.fw.GlobalEnv" %>
<%@ page import="kr.co.funology.maven.fw.mgr.ConfigurationMgr" %>
<%@ page import="jnditest.*" %>
<%@ page import="rcftp.*" %>
<html>
<body>
<h2>Hello World!</h2>
</body>
</html>
<ul>
  <li><%=GlobalEnv.getWebRootDir()%></li>
  <li><%=ConfigurationMgr.getInstance().getString("HELLO") %></li>
<%
ArrayList<CodeVO> arr = CodeBean.C_CODE_LIST_PROC();
if (!arr.isEmpty()) {
  for (CodeVO v : arr) {
    out.print("<li>"+v.CODE_CD+":"+v.CODE_NM+"</li>");
  }
}
%>
</ul>
<%
new ContractReceiver("D:/WorkSpace/FUNOLB20240819103000.txt");
%>