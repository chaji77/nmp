<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="org.apache.commons.fileupload.*,org.apache.commons.fileupload.disk.*,org.apache.commons.fileupload.servlet.*"%>
<%@ page import="java.util.*,java.io.*"%>
<%@ page import="kr.co.funology.fw.util.tax.*" %>
<%@ page import="kr.co.mp.trade.TaxVO" %>
<%@ page import="kr.co.mp.trade.TaxBean" %>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%
String strXml = "";
int intTotalCnt = 1;
int intDuplicatedCnt = 0;
String strErrorMsg = "";

try {
    DiskFileItemFactory factory = new DiskFileItemFactory();
    ServletFileUpload upload = new ServletFileUpload(factory);
    List<FileItem> formItems = upload.parseRequest(request);

    System.out.println("=== File Upload 디버깅 시작 ===");
    System.out.println("폼 항목 개수: " + formItems.size());

    for (FileItem item : formItems) {
        System.out.println("필드 이름: " + item.getFieldName());
        System.out.println("파일 여부: " + !item.isFormField());
        System.out.println("파일명: " + item.getName());
        System.out.println("파일 크기: " + item.getSize());
    }
    
    if (formItems != null && !formItems.isEmpty()) {
        for (FileItem item : formItems) {
            if (!item.isFormField()) {
                InputStream inputStream = item.getInputStream();
                StringBuilder fileContent = new StringBuilder();

                try (BufferedReader reader = new BufferedReader(
                        new InputStreamReader(inputStream, "UTF-8"))) {
                    String line;
                    while ((line = reader.readLine()) != null) {
                        fileContent.append(line).append("\n"); // 줄바꿈 추가
                    }
                }

                strXml = fileContent.toString().trim();

                if (strXml.isEmpty()) {
                    throw new Exception("업로드한 파일이 비어 있습니다.");
                }

                System.out.println("업로드된 XML:\n" + strXml);
            }
        }
    }
} catch (Exception ex) {
    out.println("업로드 오류: " + ex.getMessage());
}
System.out.println(strXml);
try {
  if (strXml==null && !strXml.equals("")) {}
  else {
    TaxInvoiceVO vo = TaxUtil.parseTaxInvoice(strXml);
    // System.out.println(vo.toString());
    int intSeq = new TaxBean().CT_BILL_ADD_PROC(vo, Integer.parseInt((String)pageContext.getAttribute("CPY_ID")));
    if (intSeq==0) intDuplicatedCnt++;
  }
} catch (Exception e) {
  intTotalCnt = 0;
  intDuplicatedCnt = 0;
  strErrorMsg = "세금계산서 첨부에 실패했습니다. 고객센터에 문의바랍니다.";
}
%>
<script>
parent.savedXmlFile(<%=intTotalCnt %>, <%=intDuplicatedCnt %>, "<%=strErrorMsg %>");
</script>