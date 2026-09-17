<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="java.io.File" %>
<%@ page import="java.io.FileWriter" %>
<%@ page import="java.io.BufferedWriter" %>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil"%>
<%@ page import="kr.co.funology.fw.util.UploadUtil"%>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%
String[] arrDate   = DateTimeUtil.getCurrentDate("@").split("@");
String strFileName = "";
String strFolder   = "";
String strFilePath = "";
String strFileSize = "";
String UPLOAD_DEFAULT_PATH = ConfigurationMgr.getInstance().getString("UPLOAD_FILE_PATH") + "editor/";

try {
  for (int i=0; i<arrDate.length-1; i++) {
    strFolder += arrDate[i] + "/";
    File f = new File(UPLOAD_DEFAULT_PATH + strFolder);
    if (!f.exists()) f.mkdirs();
  }

  UploadUtil upload = new UploadUtil();
  upload.setUploadFilePath(UPLOAD_DEFAULT_PATH + strFolder); 			  // 첨부파일의 경로
  upload.uploadFile(request, "utf-8");                                     // 언어셋처리

  ArrayList<String>         arrFileList = upload.getUploadedFileList();     // 파일명칭목록
  ArrayList<Long>           arrFileSize = upload.getUploadedFileSizes();    // 파일사이즈목록
  HashMap<String, String>   hmParameter = upload.getParameters();

  if (arrFileList!=null && arrFileList.size()>0) {
    strFileName = arrFileList.get(0);
    strFilePath = UPLOAD_DEFAULT_PATH + strFolder + strFileName;
    Long lngSize = arrFileSize.get(0);
    DecimalFormat df = new DecimalFormat("###.0");
    String strUnit = "B";
    strFileSize = String.valueOf(lngSize);

    String callbackFileName = ConfigurationMgr.getInstance().getString("UPLOAD_FILE_URL") + "editor/" + strFolder + strFileName;
    String callback = StrUtil.nvl(request.getParameter("CKEditorFuncNum"));
    if (!callback.equals("")) {
      // System.out.println(callbackFileName);
      out.print("<script>parent.CKEDITOR.tools.callFunction("+callback+", '"+callbackFileName+"', '');</script>");
    } else {
      out.print("{\"fileName\":\""+strFilePath+"\",\"uploaded\":1,\"url\":\""+callbackFileName+"\"}");
    }
  }

} catch (Exception e) {
  Logger logger = Logger.getLogger(this.getClass());
  logger.error("에디터에서 파일업로드에 실패하였습니다. @see /UploadForCKEditor.jsp");
  logger.error(e.toString());
}
%>