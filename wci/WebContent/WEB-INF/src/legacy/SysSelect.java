package legacy;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.Map;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class SysSelect {
  public static Map<String, String> GetSysSelect(String strSelectId) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("NOTIFICATE_PROC");
    ResultSet rs = null;
    Map<String, String> vo = new HashMap<String, String>();
    try {
      String query  = "SELECT QUERY, DEF \n";
             query += "  FROM [DOB2B-SERVER].[DoB2B].[dbo].[SYS_SELECT] WITH (NOLOCK) \n";
             query += " WHERE SELECT_ID = ?;";
      ps = new WrapPreparedStatementUtil(conn, query);
      ps.setString(1, strSelectId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while(rs.next()) {
          vo.put("QUERY", StrUtil.nvl(rs.getString("QUERY")));
          vo.put("DEF",   StrUtil.nvl(rs.getString("DEF")));
        }
      }
    } catch(Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    } 
    return vo;
  }
}
