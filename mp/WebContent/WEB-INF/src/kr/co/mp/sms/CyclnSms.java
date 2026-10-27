package kr.co.mp.sms;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

/**
 * 싸이클론 문자 발송.
 * 수신자는 SMS_RECEIVER_PERSON_PROC 로 찾는다. (PRS_SMS = 1 인 담당자 중 PRS_ID 가 가장 작은 사람)
 * 발송 실패는 로그만 남기고 업무 처리에는 영향을 주지 않는다.
 */
public class CyclnSms {

  /********** 문자 목록 **********/
  /* #{CPY_NAME} 은 보내는 쪽에서 회사명으로 바꿔 넘긴다. */
  /** 구매기업이 발주계약서를 등록했을 때 -> 판매기업 */
  public static final String MSG_ORDER_REG     = "[싸이클론] 발주계약서가 도착하였습니다. mp1.co.kr에서 발주확정해주세요.";
  /** 판매기업이 발주계약서를 승인했을 때 -> 구매기업. 판매기업명 */
  public static final String MSG_ORDER_CONFIRM = "[싸이클론] 판매기업 #{CPY_NAME} 에서 납품확정하였습니다.";
  /** 구매기업이 취소했을 때 -> 판매기업. 구매기업명 */
  public static final String MSG_BUYER_CANCEL  = "[싸이클론] 구매기업 #{CPY_NAME} 에서 발주를 취소하였습니다.";
  /** 판매기업이 취소했을 때 -> 구매기업. 판매기업명 */
  public static final String MSG_SELLER_CANCEL = "[싸이클론] 판매기업 #{CPY_NAME} 에서 납품을 취소하였습니다.";
  /** 구매기업이 승인 뒤 변경요청했을 때 -> 판매기업. 구매기업명 */
  public static final String MSG_BUYER_CHGREQ  = "[싸이클론] 구매기업 #{CPY_NAME} 에서 발주계약 변경을 요청하였습니다.";
  /** 판매기업이 승인 뒤 변경요청했을 때 -> 구매기업. 판매기업명 */
  public static final String MSG_SELLER_CHGREQ = "[싸이클론] 판매기업 #{CPY_NAME} 에서 납품내역 변경을 요청하였습니다.";
  /** 변경요청을 승인했을 때 -> 요청한 쪽. 승인한 쪽 구분과 회사명 */
  public static final String MSG_CHG_CONFIRM   = "[싸이클론] #{CPY_NAME} 에서 변경요청을 승인하였습니다.";
  /** 승인 뒤 취소요청했을 때 -> 상대. 요청한 쪽 구분과 회사명 */
  public static final String MSG_CANCEL_REQ    = "[싸이클론] #{CPY_NAME} 에서 거래를 취소하였습니다.";
  /** (미사용) CL100 결제완료 수신 시. 구매기업명 */
  public static final String MSG_PAY_DONE      = "[싸이클론] 구매기업 #{CPY_NAME} 에서 결제완료하였습니다. 입금확인 부탁드립니다.";
  /** 판매기업 승인 시 CL080 실패 -> 구매기업. 판매기업명 */
  public static final String MSG_CONFIRM_FAIL  = "[싸이클론] 판매기업 #{CPY_NAME} 의 납품확정이 실패하였습니다. 납품기일을 확인해주세요.";

  /** 대출상환 7일전 안내 -> 구매기업. 만기일 yyyyMMdd, 건수, 대출금액 합계(쉼표) */
  public static final String MSG_MATURITY_D7   = "[싸이클론] 기업은행 대출상환 7일전안내.만기일:#{MTR_YMD},#{CNT}건,총#{AMT}원";
  /** 대출상환 당일 안내 -> 구매기업. 만기일 yyyyMMdd, 건수, 대출금액 합계(쉼표) */
  public static final String MSG_MATURITY_D0   = "[싸이클론] 기업은행 대출상환 오늘안내.만기일:#{MTR_YMD},#{CNT}건,총#{AMT}원";

  /** SEND_SMS_PROC @MSG VARCHAR(100) */
  private static final int MAX_MSG_SIZE = 100;

  /**
   * 대출상환 안내. 만기일이 오늘 + intDays 인 건을 구매기업별로 묶어 보낸다.
   *
   * @param intDays 7-7일전 안내, 0-당일 안내
   * @return 발송 대상 기업 수 (조회 실패면 -1)
   */
  public static int sendMaturity(int intDays) {
    Logger logger = Logger.getLogger(CyclnSms.class);
    String strTemplate = (intDays == 0) ? MSG_MATURITY_D0 : MSG_MATURITY_D7;
    ArrayList<String[]> arr = new ArrayList<String[]>(); // CPYBUYER, 문자내용
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    ResultSet rs = null;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.CYCLN_MATURITY_SMS_LIST_PROC ?;");
      ps.setInt(1, intDays);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      while (rs != null && rs.next()) {
        arr.add(new String[] {
          rs.getString("CPYBUYER"),
          strTemplate.replace("#{MTR_YMD}", StrUtil.nvl(rs.getString("MTR_YMD")).trim())
                     .replace("#{CNT}",     String.valueOf(rs.getInt("CNT")))
                     .replace("#{AMT}",     StrUtil.addComma(rs.getLong("AMT")))
        });
      }
    } catch (Exception e) {
      logger.error(ps == null ? "CYCLN_MATURITY_SMS_LIST_PROC" : ps.getQueryString());
      logger.error(e.toString());
      return -1;
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    /* 조회 커넥션을 닫은 뒤 보낸다. send 가 기업마다 커넥션을 따로 쓴다. */
    for (String[] s : arr) {
      send(Integer.parseInt(s[0]), s[1]);
    }
    logger.info("CYCLN MATURITY SMS : DAYS=" + intDays + ", COMPANIES=" + arr.size());
    return arr.size();
  }

  /**
   * 회원사의 문자 수신 담당자에게 발송한다. 수신자가 없으면 보내지 않는다.
   *
   * @param intCpyId 받을 회원사 CPY_ID
   * @param strMsg   문자내용 (문자 목록의 #{CPY_NAME} 을 바꾼 것)
   */
  public static void send(int intCpyId, String strMsg) {
    String strTo = getReceiverMobileNo(intCpyId);
    Logger.getLogger(CyclnSms.class).info("CYCLN SMS : CPY_ID=" + intCpyId + ", TO=" + strTo + ", MSG=" + strMsg);
    if (strTo.length() < 10) {
      Logger.getLogger(CyclnSms.class).info("NO SMS RECEIVER : CPY_ID=" + intCpyId);
      return;
    }
    SendSMS.SEND_CYCLN_SMS_PROC(strTo, strMsg, MAX_MSG_SIZE);
  }

  /**
   * 회원사의 문자 수신 담당자 핸드폰번호 (숫자만, 없으면 빈 문자열)
   */
  private static String getReceiverMobileNo(int intCpyId) {
    Logger logger = Logger.getLogger(CyclnSms.class);
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    ResultSet rs = null;
    String strMobileNo = "";
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.SMS_RECEIVER_PERSON_PROC ?;");
      ps.setInt(1, intCpyId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs != null && rs.next()) {
        strMobileNo = StrUtil.nvl(rs.getString("PRS_MOBILE_NO")).replaceAll("[^0-9]", "");
      }
    } catch (Exception e) {
      logger.error(ps == null ? "SMS_RECEIVER_PERSON_PROC" : ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return strMobileNo;
  }
}
