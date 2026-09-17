<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.c.CompanyVO" %>
<%@ page import="kr.co.mp.c.CustomerBean" %>
<%
request.setCharacterEncoding("utf-8");
pageContext.setAttribute("SESS_NEED_LOGIN_PAGE", true);
%>
<%@ include file="../includes/LoginCheck.jsp" %>
<%
String strTargetCpyId = StrUtil.nvl(request.getParameter("cid"), "0");
int intTargetCpyId = 0;
if (StrUtil.isOnlyNumeric(strTargetCpyId) && !strTargetCpyId.equals("0")) {
  intTargetCpyId = Integer.parseInt(strTargetCpyId);
}
if (intTargetCpyId>0) {
  try {
    int intCpyId = Integer.parseInt((String)pageContext.getAttribute("CPY_ID"));
    ArrayList<CompanyVO> arr = new CustomerBean().CT_MYCOMPANY_ADD_PROC(intCpyId, intTargetCpyId);
    if (arr!=null && arr.size()>0) {
      for (CompanyVO v : arr) {
        out.print("<option value='"+v.CPY_ID+"____"+v.CPY_BUSINESS_NO+"____"+v.CU_USE_YN+"'");
        if (v.CPY_ID==intTargetCpyId) out.print(" selected");
        out.print(">"+v.CPY_NAME + " ("+v.CPY_CEO_NAME+")</option>");
      }
    }
  } catch (Exception e) {
    e.printStackTrace();
  }
}
%>