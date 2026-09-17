<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.maven.fw.GlobalEnv" %>
<%@ page import="kr.co.funology.maven.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.maven.fw.util.StrUtil" %>
<%@ page import="jnditest.*" %>
<%@ page import="rcftp.*" %>
<%
Logger logger = Logger.getLogger("RCFTP");

String strSellerCode = StrUtil.nvl(request.getParameter("sc"), "FUNOL");
String strFilePath   = StrUtil.nvl(ConfigurationMgr.getInstance().getString("FILE_PATH")) + strSellerCode +"/";
String strTargetFileName = null;

logger.debug("******************** RCFTP [" + strSellerCode + "] START ********************");

out.println("<li>실행목표경로 : " + strFilePath + "</li>");

// STEP-1. CONTRACT DATA
strTargetFileName = FileSelector.findOldestFileName(strFilePath, strSellerCode + "B");
out.println("<li>매매정보 실행대상파일 : " + strTargetFileName + "</li>");
if (strTargetFileName!=null) new ContractReceiver(strFilePath + strTargetFileName);

// STEP-2. SETTLEMENT DATA
strTargetFileName = FileSelector.findOldestFileName(strFilePath, strSellerCode + "K");
out.println("<li>결제정보 실행대상파일 : " + strTargetFileName + "</li>");
if (strTargetFileName!=null) new SettleReceiver(strFilePath + strTargetFileName);

// STEP-3. DELETE EMPTY FILES
FileSelector.deleteEmptyFiles(strFilePath);

// STEP-4. LEFT FILE COUNT REPORT
int intLeftFileCnt = FileSelector.countFilesWithPrefix(strFilePath);


out.println("<li>미처리파일수 : " + intLeftFileCnt + "</li>");
%>