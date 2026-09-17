<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.io.File" %>
<%@ page import="java.io.FileWriter" %>
<%@ page import="java.io.BufferedWriter" %>
<%@ page import="com.baroservice.ws.KakaotalkTemplate" %>
<%@ page import="kr.co.mp.kakaotalk.TalkCtrl" %>
<%
String filePath = application.getRealPath("/WEB-INF/kakaotemplates.xml");
File file = new File(filePath);
BufferedWriter writer = new BufferedWriter(new FileWriter(file));
writer.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<rows>\n");
TalkCtrl t = TalkCtrl.getInstance();
List<KakaotalkTemplate> arr = t.getTemplates();
for (KakaotalkTemplate c : arr) {
  String row = "<row><id>"+c.getTemplateName()+"</id><title><![CDATA["+c.getTemplateTitle()+"]]></title><body><![CDATA["+c.getTemplateContent()+"]]></body></row>\n";
  writer.write(row);
}
writer.write("</rows>");
writer.close();
%>
