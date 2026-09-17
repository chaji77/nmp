<%@ page contentType="text/html;charset=utf-8"%>
<%@ page import="java.sql.Connection"%>
<%@ page import="java.sql.ResultSet"%>
<%@ page import="org.apache.log4j.Logger"%>
<%@ page import="kr.co.funology.fw.mgr.ConnectionMgr"%>
<%@ page import="kr.co.funology.fw.util.StrUtil"%>
<%@ page import="kr.co.funology.fw.util.WrapPreparedStatementUtil"%>
<%@ page import="kr.co.funology.fw.mgr.ConfigurationMgr" %>
<%
Logger logger = Logger.getLogger(this.getClass());

String SENDER_KEY      = StrUtil.nvl(ConfigurationMgr.getInstance().getString("ETAX_SENDER_CODE"));
String OWNER_BIZ_NO    = StrUtil.nvl(ConfigurationMgr.getInstance().getString("OWNER_BIZ_NO")).replaceAll("-", "");
String OWNER_ADDR      = StrUtil.nvl(ConfigurationMgr.getInstance().getString("OWNER_ADDR"));
String OWNER_TEL       = StrUtil.nvl(ConfigurationMgr.getInstance().getString("OWNER_TEL"));
String OWNER_HP        = StrUtil.nvl(ConfigurationMgr.getInstance().getString(""));
String OWNER_EMAIL     = StrUtil.nvl(ConfigurationMgr.getInstance().getString("ETAX_MGR_EMAIL"));
String OWNER_BIZ_TYPE  = StrUtil.nvl(ConfigurationMgr.getInstance().getString("BIZ_TYPE"));
String OWNER_BIZ_CLASS = StrUtil.nvl(ConfigurationMgr.getInstance().getString("BIZ_CLASS"));
String BILL_NO_PREFIX  = "EMT01"; // CYCLELOAN UNIQUE PREFIX
String YMD             = "";
try {
  Connection conn = ConnectionMgr.getInstance().getConnetion();
  WrapPreparedStatementUtil ps = new WrapPreparedStatementUtil(conn, "EXEC MP.DBO.BAT_LOAD_CYCLYLOAN_BILL_PROC ?, ?, ?, ?, ?, ?, ?, ?, ?, ?;");
  int i = 0;
  ps.setString(++i, SENDER_KEY     );
  ps.setString(++i, OWNER_BIZ_NO   );
  ps.setString(++i, OWNER_ADDR     );
  ps.setString(++i, OWNER_TEL      );
  ps.setString(++i, OWNER_HP       );
  ps.setString(++i, OWNER_EMAIL    );
  ps.setString(++i, OWNER_BIZ_TYPE );
  ps.setString(++i, OWNER_BIZ_CLASS);
  ps.setString(++i, BILL_NO_PREFIX );
  ps.setString(++i, YMD            );
  logger.debug(ps.getQueryString());
  ResultSet rs = ps.executeQuery();
  if (rs!=null && rs.next()) out.print(rs.getInt("CNT")); 
} catch (Exception e) {
  out.print(e.toString());
}
%>