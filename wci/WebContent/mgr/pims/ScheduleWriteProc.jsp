<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.pims.ScheduleCtrl" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
  request.setCharacterEncoding("utf-8");
  String strDateSeparator = ConfigurationMgr.getInstance().getString("DEFAULT_DATE_SEPARATOR");
  String plan_id          = StrUtil.nvl(request.getParameter("plan_id"), "0");
  String plan_section_cd  = StrUtil.nvl(request.getParameter("section"));
  String title            = StrUtil.xss(StrUtil.getParameter(request.getParameter("title"), "", 200));
  String startymd         = StrUtil.nvl(request.getParameter("startymd")).replaceAll("[^0-9]", "");
  String start_h          = StrUtil.nvl(request.getParameter("start_h")).replaceAll("[^0-9]", "");
  String start_m          = StrUtil.nvl(request.getParameter("start_m")).replaceAll("[^0-9]", "");
  String endymd           = StrUtil.nvl(request.getParameter("endymd")).replaceAll("[^0-9]", "");
  String end_h            = StrUtil.nvl(request.getParameter("end_h")).replaceAll("[^0-9]", "");
  String end_m            = StrUtil.nvl(request.getParameter("end_m")).replaceAll("[^0-9]", "");
  String editor           = StrUtil.xss(request.getParameter("note"));
  String strRegId         = IntegerCryptoUtil.crypt((String)session.getAttribute("SESS_MAN_ID"));

  int intPlanId = (StrUtil.isOnlyNumeric(plan_id)) ? Integer.parseInt(plan_id) : 0;
  
  if (intPlanId==0) new ScheduleCtrl().P_PLAN_ADD_PROC(plan_section_cd, title, startymd, endymd, start_h+start_m, end_h+end_m, strRegId, editor);
  else new ScheduleCtrl().P_PLAN_MOD_PROC(intPlanId, plan_section_cd, title, startymd, endymd, start_h+start_m, end_h+end_m, strRegId, editor);
%>