<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.SessionCountUtil" %>
<%
response.setHeader("Access-Control-Allow-Origin", "*");

boolean isRunTomcat = false;
String  strMemoryStatus = "";
Map<String, String> map = new HashMap<String, String>();
try {
  String s = "";
  String[] cmd = {"/bin/sh", "-c", "top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\\([0-9.]*\\)%* id.*/\\1/' | awk '{print 100 - $1}' && df -h --output=avail /home | tail -n 1 && ps -ef|grep tomcat"};
  Process p = Runtime.getRuntime().exec(cmd);
  BufferedReader br = new BufferedReader(new InputStreamReader(p.getInputStream()));
  int i = 0;
  while ((s = br.readLine())!=null) {
	  if (i==0) map.put("CPU", s + "%");
	  if (i==1) map.put("Disk", s);
    if (s.contains("org.apache.catalina.startup")) isRunTomcat = true;
    i++;
  }
  p.waitFor();
  p.exitValue();
  p.destroy();
  
  // map.put("Tomcat", ((isRunTomcat)?"RUNNING":"SHUTDOWN"));
  
  if (request.getParameter("gc") !=null && request.getParameter("gc").equals("y")) {
    Runtime.getRuntime().gc();
  }
  
  long totalMemory  = Runtime.getRuntime().maxMemory()/1024/1024;
  long freeMemory   = Runtime.getRuntime().freeMemory()/1024/1024;
  double rateMemory = (freeMemory*100) / totalMemory;
  map.put("Memory", String.format("%10dM (%11.1f%% Left)", freeMemory, rateMemory));
  // map.put("Memory", String.format("%10dMB / %10dMB", freeMemory, totalMemory));
} catch (Exception e) {}


if (map.containsKey("CPU")) out.println("<li><label>CPU USAGE</label>" + map.get("CPU") + "</li>");
if (map.containsKey("Memory")) out.println("<li><label>VM AVAIL</label>" + map.get("Memory") + "</li>");
if (map.containsKey("Disk")) out.println("<li><label>DISK AVAIL</label>" + map.get("Disk") + "</li>");
out.println("<li><label>SESSIONS</label>" + StrUtil.addComma(SessionCountUtil.getActiveSessions()) + "</li>");
// if (map.containsKey("Tomcat")) out.println("<li><label>TOMCAT</label>" + map.get("Tomcat") + "</li>");

%>
