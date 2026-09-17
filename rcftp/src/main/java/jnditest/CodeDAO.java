package jnditest;
import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.maven.fw.mgr.ConnectionMgr;
import kr.co.funology.maven.fw.util.StrUtil;
import kr.co.funology.maven.fw.util.WrapPreparedStatementUtil;

public class CodeDAO {
  protected static ArrayList<CodeVO> C_CODE_LIST_PROC() {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("CodeDAO");
    ResultSet rs = null;
    ArrayList<CodeVO> arr = new ArrayList<>();
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.C_CODE_LIST_PROC;");
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          CodeVO vo      = new CodeVO();
          vo.CODE_GRP_CD = StrUtil.nvl(rs.getString("CODE_GRP_CD"));
          vo.CODE_CD     = StrUtil.nvl(rs.getString("CODE_CD"));
          vo.CODE_NM     = StrUtil.nvl(rs.getString("CODE_NM"));
          arr.add(vo);
        }
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return arr;
  }
}
