<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="kr.co.mp.mgr.customer.MgrCustomerBean" %>
<%@ page import="kr.co.mp.c.*" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");

if (request.getHeader("referer").indexOf("customer/Company.jsp")<0) {
    response.sendRedirect(request.getContextPath());
}

int intCpyId = Integer.parseInt(StrUtil.nvl(request.getParameter("cid"), "0"));
String strMemo = StrUtil.nvl(request.getParameter("txt"), "");

if (intCpyId == 0 || strMemo.isEmpty()) {
    out.print("0");
    return;
} 

CompanyVO cvo = new CompanyVO();
MgrCustomerBean mgrCustomerBean = new MgrCustomerBean();

cvo.CPY_ID = intCpyId ;
cvo.CPY_MEMO = strMemo;
int result = mgrCustomerBean.M_COMPANY_MEMO_MOD_PROC(cvo);

if (result >= 0) {
    out.print("1"); 
} else {
	System.out.println("M_COMPANY_MEMO_MOD_PROC" + strMemo);
    out.print("0"); 
}

%>