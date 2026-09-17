package kr.co.funology.fw.pims;

import java.sql.Connection;
import java.sql.ResultSet;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.HashMap;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.CalendarUtil;
import kr.co.funology.fw.util.DateTimeUtil;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class ScheduleDAO {

  protected HashMap<String, String> getAdditionalHoliday(String strTargetDate) {
    Connection                conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps   = null;
    ResultSet                 rs   = null;
    Logger logger = Logger.getLogger(this.getClass());
    HashMap<String, String> vo = new HashMap<>();

    try {
      ps = new WrapPreparedStatementUtil(conn, " EXEC DBO.GET_ADDITIONAL_HOLIDAY_PROC ?");
      ps.setString(1, strTargetDate);
        logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      while(rs.next()) {
          vo.put(rs.getString("YMD"), rs.getString("HOLI_NM"));
      }
    } catch (Exception e) {
        logger.error(ps.getQueryString());
        System.out.println("[Error@schedule.ScheduleDAO.getSchedule()");
      System.out.println(e.toString());
    } finally {
        ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return vo;
  }


  protected ArrayList<ScheduleVO> getSchedule(int intYear, int intMonth, String separator) throws ParseException {
    Connection                conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps   = null;
    ResultSet                 rs   = null;
    Logger logger = Logger.getLogger(this.getClass());
    ArrayList<ScheduleVO> vo = new ArrayList<ScheduleVO>();

    String strStartYmd = DateTimeUtil.diff(DateTimeUtil.getFormatDate(intYear, intMonth, 1, "/"), CalendarUtil.getWeekDay(DateTimeUtil.getFormatDate(intYear, intMonth, 1, "/"), "/"), "/").replaceAll("/", "");
    int intStartDate = Integer.parseInt(strStartYmd);

    try {
      ps = new WrapPreparedStatementUtil(conn, " EXEC P_PLAN_LIST_PROC ?, ? ");
      ps.setString(1, String.valueOf(intYear));
      ps.setString(2, ((intMonth<10)?"0"+Integer.toString(intMonth):Integer.toString(intMonth)));

      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      while(rs.next()) {
        ScheduleVO ent = new ScheduleVO();
        ent.START_YMD  = rs.getString("START_YMD");
        ent.END_YMD    = rs.getString("END_YMD");
        if (intStartDate>Integer.parseInt(ent.START_YMD)) {
          ent.START_MM = strStartYmd.substring(4,6);
          ent.START_DD = strStartYmd.substring(6,8);
        } else {
          ent.START_MM = ent.START_YMD.substring(4, 6);
          ent.START_DD = ent.START_YMD.substring(6, 8);
        }
        ent.START_HM = rs.getString("START_HM").substring(0,2) + ":" + rs.getString("START_HM").substring(2,4);
        ent.END_MM   = rs.getString("END_YMD").substring(4, 6);
        ent.END_DD   = rs.getString("END_YMD").substring(6, 8);
        ent.END_HM   = rs.getString("END_HM").substring(0,2) + ":" + rs.getString("END_HM").substring(2,4);
        ent.SCH_NM   = rs.getString("TITLE");
        ent.SCH_LIST_SEQ = String.valueOf(rs.getInt("PLAN_ID"));
        ent.GRP = rs.getString("PLAN_SECTION_CD").substring(4);
        ent.EMP_NM   = rs.getString("EMP_NM");
        vo.add(ent);
      }
    } catch (Exception e) {
        logger.error(ps.getQueryString());
        System.out.println("[Error@schedule.ScheduleDAO.getSchedule()");
      System.out.println(e.toString());
    } finally {
        ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return vo;
  }

  protected void P_PLAN_ADD_PROC(String strGrp, String strTitle, String strStartYmd, String strEndYmd, String strStartHM, String strEndYM, String strRegid, String strContents) {
    Connection                conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps   = null;
    Logger logger = Logger.getLogger(this.getClass());
    try {
      ps = new WrapPreparedStatementUtil(conn, " EXEC P_PLAN_ADD_PROC ?, ?, ?, ?, ?, ?, ?, ? ");
      int i = 1;
      ps.setString(i++, "PLAN" + strGrp);
      ps.setString(i++, strTitle);
      ps.setString(i++, strStartYmd);
      ps.setString(i++, strEndYmd);
      ps.setString(i++, strStartHM);
      ps.setString(i++, strEndYM);
      ps.setString(i++, strRegid);
      ps.setString(i++, strContents);

      logger.debug(ps.getQueryString());
      ps.execute();
    } catch (Exception e) {
      logger.error(ps.getQueryString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    }
  }
  protected void P_PLAN_MOD_PROC(int intPlanId, String strGrp, String strTitle, String strStartYmd, String strEndYmd, String strStartHM, String strEndYM, String strRegid, String strContents) {
    Connection                conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps   = null;
    Logger logger = Logger.getLogger(this.getClass());
    try {
      ps = new WrapPreparedStatementUtil(conn, " EXEC P_PLAN_MOD_PROC ?, ?, ?, ?, ?, ?, ?, ?, ? ");
      int i = 1;
      ps.setInt(   i++, intPlanId);
      ps.setString(i++, "PLAN" + strGrp);
      ps.setString(i++, strTitle);
      ps.setString(i++, strStartYmd);
      ps.setString(i++, strEndYmd);
      ps.setString(i++, strStartHM);
      ps.setString(i++, strEndYM);
      ps.setString(i++, strRegid);
      ps.setString(i++, strContents);

      logger.debug(ps.getQueryString());
      ps.execute();
    } catch (Exception e) {
      logger.error(ps.getQueryString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    }
  }
  protected void P_PLAN_DROP_PROC(String strPlanId) {
    Connection                conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps   = null;
    Logger logger = Logger.getLogger(this.getClass());
    try {
      ps = new WrapPreparedStatementUtil(conn, " EXEC P_PLAN_DROP_PROC ?;");
      int i = 1;
      ps.setString(i++, strPlanId);
      logger.debug(ps.getQueryString());
      ps.execute();
    } catch (Exception e) {
      logger.error(ps.getQueryString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps);
    }
  }
  protected ScheduleVO P_PLAN_DETAIL_PROC(int intPlanId) throws ParseException {
    Connection                conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps   = null;
    ResultSet                 rs   = null;
    Logger logger = Logger.getLogger(this.getClass());
    ScheduleVO ent = new ScheduleVO();
    try {
      ps = new WrapPreparedStatementUtil(conn, " EXEC P_PLAN_DETAIL_PROC ? ");
      ps.setInt(1, intPlanId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      while(rs.next()) {
        ent.START_YMD    = rs.getString("START_YMD");
        ent.END_YMD      = rs.getString("END_YMD");
        ent.START_HM     = rs.getString("START_HM").substring(0,2) + ":" + rs.getString("START_HM").substring(2,4);
        ent.END_HM       = rs.getString("END_HM").substring(0,2) + ":" + rs.getString("END_HM").substring(2,4);
        ent.SCH_NM       = StrUtil.nvl(rs.getString("TITLE"));
        ent.SCH_LIST_SEQ = String.valueOf(rs.getInt("PLAN_ID"));
        ent.GRP          = rs.getString("PLAN_SECTION_CD").substring(4);
        ent.EMP_NM       = StrUtil.nvl(rs.getString("EMP_NM"));
        ent.CONTENTS     = StrUtil.nvl(rs.getString("CONTENTS"));
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return ent;
  }
}
