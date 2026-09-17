<%@ page contentType="text/html;charset=utf-8" trimDirectiveWhitespaces="true"%>
<%@ page import="kr.co.funology.fw.util.StrUtil" %>
<%@ page import="kr.co.funology.fw.util.IntegerCryptoUtil" %>
<%@ page import="kr.co.mp.trade.PayMethodVO" %>
<%@ page import="kr.co.mp.trade.GuaranteeBean" %>
<%@ include file="../ManagerLoginCheck.jsp" %>
<%
request.setCharacterEncoding("utf-8");
String strCpyId = request.getParameter("cid");
strCpyId = (IntegerCryptoUtil.isEncrypted(strCpyId)) ? strCpyId : null;
int intCpyId = 0;
if (strCpyId!=null) intCpyId = Integer.parseInt(IntegerCryptoUtil.crypt(request.getParameter("cid")));
else return;

PayMethodVO pvo    = new PayMethodVO();
pvo.CPY_ID         = intCpyId;
pvo.BNK_CD         = StrUtil.nvl(request.getParameter("bnk_cd"));
pvo.PAY_ID         = StrUtil.nvl(request.getParameter("pay_id"));
pvo.GUAR_LOC       = Integer.parseInt(StrUtil.nvl(request.getParameter("guar_loc"), "0"));
pvo.GUAR_STATUS    = StrUtil.nvl(request.getParameter("guar_status"));
pvo.GUAR_CRA_DATE  = StrUtil.nvl(request.getParameter("cra_date"));
pvo.GUAR_EXP_DATE  = StrUtil.nvl(request.getParameter("exp_date"));
pvo.GUAR_VAL_DATE  = StrUtil.nvl(request.getParameter("val_date"));
pvo.GUAR_TOTAL_AMT = StrUtil.nvl(request.getParameter("amt"));
pvo.MEMO           = StrUtil.nvl(request.getParameter("memo"));
pvo.WRITE_ID       = (String)session.getAttribute("SESS_LOGIN_ID");
pvo.CPY_GUAR_SEQ   = Integer.parseInt(StrUtil.nvl(request.getParameter("seq"), "0"));

if (pvo.CPY_GUAR_SEQ==0) out.println(new GuaranteeBean().GUARANTEE_MASTER_INFO_ADD_PROC(pvo));
else out.println(new GuaranteeBean().GUARANTEE_MASTER_INFO_MOD_PROC(pvo));

%>