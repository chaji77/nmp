<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="com.baroservice.ws.KakaotalkTemplate" %>
<%@ page import="kr.co.mp.kakaotalk.TalkCtrl" %>
<!DOCTYPE HTML>
<html>
  <head>
    <meta charset="utf-8">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Cache-Control" content="no-cache">
    <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1, maximum-scale=1">
    <link rel="stylesheet" type="text/css" href="/mp/static/css/style.css" />
  </head>
  <body>
    <main>
      <div class='wrapper'>
        <table class='detail'>
        <%
        TalkCtrl t = TalkCtrl.getInstance();
        List<KakaotalkTemplate> arr = t.getTemplates();
        for (KakaotalkTemplate c : arr) {
          out.println("<tr><td>"+c.getTemplateName()+"</td><td>"+c.getTemplateTitle()+"</td><td><pre>"+c.getTemplateContent()+"</pre></td></tr>");
        }
        %>
        </table>
      </div>
    </main>
  </body>
</html>
