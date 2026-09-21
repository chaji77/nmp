<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.mp.c.CustomerBean" %>
<%@ page import="kr.co.mp.c.CompanyVO" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
int intCpyId = Integer.parseInt(StrUtil.nvl(request.getParameter("cpy_id"), "0"));
if (intCpyId==0) { out.print(-1); return; }

CustomerBean bean = new CustomerBean();

CompanyVO cvo = new CompanyVO();
cvo.CPY_ID            = intCpyId;
cvo.CPY_CREDIT_GRADE   = StrUtil.nvl(request.getParameter("credit_grade"));
cvo.CPY_INDUSTRY_CODE = StrUtil.nvl(request.getParameter("industry_code"));
cvo.INDUSTRY_DETAIL   = StrUtil.nvl(request.getParameter("industry_detail"));

// 드롭다운 '-' 선택(빈 값)은 NULL로 저장, 'Y'/'N'은 그대로 저장
String strExportYn  = StrUtil.nvl(request.getParameter("export_yn"));
String strPatentYn  = StrUtil.nvl(request.getParameter("patent_yn"));
String strMainbizYn = StrUtil.nvl(request.getParameter("mainbiz_yn"));
String strInnobizYn = StrUtil.nvl(request.getParameter("innobiz_yn"));
String strLabYn     = StrUtil.nvl(request.getParameter("lab_yn"));
cvo.EXPORT_YN  = strExportYn.equals("")  ? null : strExportYn;
cvo.PATENT_YN  = strPatentYn.equals("")  ? null : strPatentYn;
cvo.MAINBIZ_YN = strMainbizYn.equals("") ? null : strMainbizYn;
cvo.INNOBIZ_YN = strInnobizYn.equals("") ? null : strInnobizYn;
cvo.LAB_YN     = strLabYn.equals("")     ? null : strLabYn;

// 값 없으면 NULL로 저장
String strSalesYear   = StrUtil.nvl(request.getParameter("sales_year"));
String strSalesAmount = StrUtil.nvl(request.getParameter("sales_amount"));
cvo.SALES_YEAR   = strSalesYear.equals("")   ? null : strSalesYear;
cvo.SALES_AMOUNT = strSalesAmount.equals("") ? null : strSalesAmount;

String strCpyScale = StrUtil.nvl(request.getParameter("cpy_scale"));
cvo.CPY_SCALE = strCpyScale.equals("") ? null : strCpyScale;
String strEmployeeCount = StrUtil.nvl(request.getParameter("employee_count"));
cvo.EMPLOYEE_COUNT = strEmployeeCount.equals("") ? null : strEmployeeCount;

int intResult = bean.COMPANY_MOREINFO_MOD_PROC(cvo);
out.print(intResult);
%>