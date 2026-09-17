package kr.co.mp.c.qna;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class QnaDAO {
  
  protected int C_QNA_ADD_PROC(QnaVO vo) {
      Connection conn = ConnectionMgr.getInstance().getConnetion();
      WrapPreparedStatementUtil ps = null;
      Logger logger = Logger.getLogger(this.getClass());
      ResultSet rs = null;
      int intSeq = 0;

      try {
          ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.C_QNA_ADD_PROC ?, ?, ?, ?;");
          int i = 0;
          ps.setInt(   ++i, vo.SEQ);
          ps.setInt(++i,vo.MGR_ID);  
          ps.setString(++i, StrUtil.xss(vo.A_CONTENTS)); 
          ps.setString(++i, StrUtil.xss(vo.ANS_YN));
          rs = ps.executeQuery();
          if (rs != null && rs.next()) {
              intSeq = rs.getInt("SEQ");
          }
      } catch (Exception e) {
          logger.error(ps.getQueryString());
          logger.error(e.toString());
      } finally {
          ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
      }
      return intSeq;
  }
  protected int C_QNA_MOD_PROC(QnaVO vo) {
      Connection conn = ConnectionMgr.getInstance().getConnetion();
      WrapPreparedStatementUtil ps = null;
      Logger logger = Logger.getLogger(this.getClass());
      int intResult = 0;

      try {
          ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.C_QNA_MOD_PROC ?, ?, ?, ?;");
          int i = 0;
          ps.setInt(++i, vo.SEQ);  
          ps.setInt(++i, vo.MGR_ID);   
          ps.setString(++i, StrUtil.xss(vo.A_CONTENTS));
          ps.setString(++i, StrUtil.xss(vo.ANS_YN));

          logger.debug(ps.getQueryString());
          intResult = ps.executeUpdate();  
      } catch (Exception e) {
          logger.error(ps.getQueryString());
          logger.error(e.toString());
      } finally {
          ConnectionMgr.getInstance().closeConnection(conn, ps);
      }
      return intResult;
  }
  protected int C_QNA_DROP_PROC(QnaVO vo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    int intResult = 0;
    try {
    ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.C_QNA_DROP_PROC ?");
    int i = 0;
    ps.setInt   (++i, vo.SEQ);
        logger.debug(ps.getQueryString());
        intResult = ps.executeUpdate();
    } catch (Exception e) {
        logger.error(ps.getQueryString());
        logger.error(e.toString());
        intResult = -1;        
      } finally {
        ConnectionMgr.getInstance().closeConnection(conn, ps);
      }
      return intResult;
  }
  protected QnaVO C_QNA_DETAIL_PROC (int intSeq) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    QnaVO vo = new QnaVO();
    try {
    ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.C_QNA_DETAIL_PROC ?;");
    int i = 0;
    ps.setInt(++i, intSeq);
    logger.debug(ps.getQueryString());
    rs = ps.executeQuery();
    if (rs!=null && rs.next()) {
      vo.SEQ        = intSeq;
          vo.Q_TITLE    = StrUtil.nvl(rs.getString("Q_TITLE"));
          vo.CPY_ID     = rs.getInt("CPY_ID");
          vo.REG_NM     = StrUtil.nvl(rs.getString("REG_NM"));
          vo.MGR_ID     = rs.getInt("MGR_ID");
          vo.REG_DT     = StrUtil.nvl(rs.getString("REG_DT"));
          vo.ANS_YN     = StrUtil.nvl(rs.getString("ANS_YN"));
          vo.Q_CONTENTS = StrUtil.nvl(rs.getString("Q_CONTENTS"));
          vo.A_CONTENTS = StrUtil.nvl(rs.getString("A_CONTENTS"));
          vo.CPY_NAME   = StrUtil.nvl(rs.getString("CPY_NAME"));
    }
    } catch (Exception e) {
        logger.error(ps.getQueryString());
        logger.error(e.toString());
      } finally {
        ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
      }
      return vo;
  }
  protected ArrayList<QnaVO> C_QNA_LIST_PROC(QnaVO vo) {
     Connection conn = ConnectionMgr.getInstance().getConnetion();
     WrapPreparedStatementUtil ps = null;
     Logger logger = Logger.getLogger(this.getClass());
     ResultSet rs = null;
     ArrayList<QnaVO> arr = new ArrayList<>();
     try {
       ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.C_QNA_LIST_PROC ?, ?, ?, ?, ?;");
       int i = 0;
       ps.setInt   (++i, vo.SEQ);
       ps.setInt   (++i, vo.CPY_ID);
       ps.setInt   (++i, vo.PAGE);
       ps.setInt   (++i, vo.ROW_CNT);
       ps.setString(++i, vo.ANS_YN);
       
       logger.debug(ps.getQueryString());
       rs = ps.executeQuery();
      if (rs!=null) {
        while (rs.next()) {
          QnaVO v  = new QnaVO();
          v.RN        = rs.getInt("RN");
          v.TOTAL_CNT = rs.getInt("TOTAL_CNT");
          v.SEQ     = rs.getInt("SEQ");
          v.Q_TITLE   = StrUtil.nvl(rs.getString("Q_TITLE"));
          v.REG_NM    = StrUtil.nvl(rs.getString("REG_NM"));
          v.MGR_ID    = rs.getInt("MGR_ID");
          v.Q_CONTENTS= StrUtil.nvl(rs.getString("Q_CONTENTS"));
          v.A_CONTENTS= StrUtil.nvl(rs.getString("A_CONTENTS"));
          v.ANS_YN    = rs.getString("ANS_YN");
          v.REG_DT    = StrUtil.nvl(rs.getString("REG_DT"));
          v.CPY_NAME  = StrUtil.nvl(rs.getString("CPY_NAME"));
          arr.add(v);
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
    
  protected int C_QNA_CUSTOMER_ADD_PROC(QnaVO vo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    int intSeq = 0;

    try {
        ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.C_QNA_CUSTOMER_ADD_PROC ?, ?, ?, ?;");
        int i = 0;
        ps.setString(++i, StrUtil.xss(vo.Q_TITLE));
        ps.setInt(++i,vo.CPY_ID);
        ps.setString(++i, StrUtil.xss(vo.REG_NM));
        ps.setString(++i, StrUtil.xss(StrUtil.nvl(vo.Q_CONTENTS).replace("\r\n", "<br>"))); 
        logger.debug(ps.getQueryString());
        rs = ps.executeQuery();
        if (rs != null && rs.next()) {
            intSeq = rs.getInt("SEQ");
        }
    } catch (Exception e) {
        logger.error(ps.getQueryString());
        logger.error(e.toString());
    } finally {
        ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intSeq;
  }
  protected int C_QNA_CUSTOMER_MOD_PROC(QnaVO vo) {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    int intSeq = 0;

    try {
        ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.C_QNA_CUSTOMER_MOD_PROC ?, ?, ?;");
        int i = 0;
        ps.setInt(++i,vo.SEQ);
        ps.setString(++i, StrUtil.xss(vo.Q_TITLE));
        ps.setString(++i, StrUtil.xss(StrUtil.nvl(vo.Q_CONTENTS).replace("\r\n", "<br>"))); 
        rs = ps.executeQuery();
        if (rs != null && rs.next()) {
            intSeq = rs.getInt("SEQ");
        }
    } catch (Exception e) {
        logger.error(ps.getQueryString());
        logger.error(e.toString());
    } finally {
        ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intSeq;
  }
}