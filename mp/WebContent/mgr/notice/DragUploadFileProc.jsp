<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.io.File" %>
<%@ page import="java.io.FileWriter" %>
<%@ page import="java.io.BufferedWriter" %>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="org.apache.log4j.Logger" %>
<%@ page import="kr.co.funology.fw.util.StrUtil"%>
<%@ page import="kr.co.funology.fw.util.UploadUtil"%>
<%@ page import="kr.co.funology.fw.util.DateTimeUtil" %>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%
/***************************************************************************
 *
 * upload file. save to default-path / thisyear / this month / this date
 * @callback parent.callbackAddedFile(file_path, file_size)
 *
 **************************************************************************/

//request.setCharacterEncoding("utf-8");

String[] arrDate   = DateTimeUtil.getCurrentDate("@").split("@");
String strFolder   = "";
String strFilePath = "";
String strFileSize = "";

String PIMS_UPLOAD_DEFAULT_PATH = ConfigurationMgr.getInstance().getString("UPLOAD_FILE_PATH") + "notice/";
String PIMS_DOWNLOAD_URL        = ConfigurationMgr.getInstance().getString("UPLOAD_FILE_URL") + "notice/";

try {
  for (int i=0; i<arrDate.length-1; i++) {
    strFolder += arrDate[i] + "/";
    File f = new File(PIMS_UPLOAD_DEFAULT_PATH + strFolder);
    if (!f.exists()) f.mkdirs();
  }

  UploadUtil upload = new UploadUtil();
  upload.setUploadFilePath(PIMS_UPLOAD_DEFAULT_PATH + strFolder); 		  // 첨부파일의 경로
  upload.uploadFile(request, "utf-8");

  ArrayList<String>         arrFileList = upload.getUploadedFileList();     // 파일명칭목록
  ArrayList<Long>           arrFileSize = upload.getUploadedFileSizes();    // 파일사이즈목록

  if (arrFileList!=null && arrFileList.size()>0) {
    strFilePath = strFolder + arrFileList.get(0);
    Long lngSize = arrFileSize.get(0);
    DecimalFormat df = new DecimalFormat("###.0");
    String strUnit = "B";
    strFileSize = String.valueOf(lngSize);
  }

} catch (Exception e) {
  Logger logger = Logger.getLogger(this.getClass());
  logger.error("공지사항관리에서 파일업로드에 실패하였습니다. @see /c/notice/DragUploadFileProc.jsp");
  logger.error(e.toString());
}

String json      = "";
String jsonArray = "";


if(!"".equals(strFilePath)){
  json += "{";
  json += "\"FILE_PATH\":\"" + PIMS_DOWNLOAD_URL + strFilePath + "\"";
  json += ", \"FILE_SIZE\":\"" + strFileSize + "\"";
  json += "},";

  json = json.substring(0,json.length()-1);
  jsonArray = "[" + json + "]";
  out.println(jsonArray);
}else{
  json += "{";
  json += "\"FILE_PATH\":\"" + "" + "\"";
  json += ", \"FILE_SIZE\":\"" + "" + "\"";
  json += "}";
  out.println("[" + json + "]");
}

%>
