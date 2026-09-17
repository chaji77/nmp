package kr.co.mp.trade;

import java.sql.Connection;
import java.sql.ResultSet;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.DateTimeUtil;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

/**
 * 매매계약서 유효 검증 클래스
 */
public class ValidateCheck {

  CtHeaderVO cvo;        // 매매계약서 정보
  String strBuyerBizNo;  // 구매사 사업자번호
  String strSellerBizNo; // 판매사 사업자번호
  
  /**
   * 검증 초기화 
   * @param hvo 매매계약서정보
   * @param strBuyerBizNo 구매사 사업자번호
   * @param strSellerBizNo 판매사 사업자번호
   * @return 올바른 정보인가?
   */
  public boolean initialize(CtHeaderVO hvo, String strBuyerBizNo, String strSellerBizNo) {
    Logger logger = Logger.getLogger(this.getClass());
    this.cvo = hvo;
    this.strBuyerBizNo = StrUtil.nvl(strBuyerBizNo);
    this.strSellerBizNo = StrUtil.nvl(strSellerBizNo);
    if (this.cvo==null) logger.debug("cvo==null");
    if (StrUtil.nvl(this.cvo.CPYBUYER).equals("")) logger.debug("StrUtil.nvl(this.cvo.CPYBUYER).equals(\"\")");
    if (StrUtil.nvl(this.cvo.CPYSELLER).equals("")) logger.debug("StrUtil.nvl(this.cvo.CPYSELLER).equals(\"\")");
    if (this.strBuyerBizNo.length()!=10) logger.debug(this.strBuyerBizNo + ".length()!=10");
    if (this.strSellerBizNo.length()!=10) logger.debug(this.strSellerBizNo + ".length()!=10");
    return (this.cvo==null || StrUtil.nvl(this.cvo.CPYBUYER).equals("") || StrUtil.nvl(this.cvo.CPYSELLER).equals("") || this.strBuyerBizNo.length()!=10 || this.strSellerBizNo.length()!=10) ? false : true;
  }
  /**
   * 유효검증 시작
   * 
   * @param strStepCode 검증단계(작성/승인으로 구분)
   * @return 유효한 매매계약서이면 "00000", 아니면 해당되는 검증코드
   */
  public String execute(String strStepCode) {
    String[] strCheckItems = (StrUtil.nvl(AbnormalConfiguration.getInstance().getString(strStepCode)+",")).split(",");
    for (int i=0; i<strCheckItems.length; i++) {
      if (strCheckItems[i].equals("V0001") && !V0001()) return getErrorMsg("V0001");
      if (strCheckItems[i].equals("V0002") && !V0002()) return getErrorMsg("V0002");
      if (strCheckItems[i].equals("V0003")) {
        int[] intDishonor = V0003();
        if (intDishonor[0]>0) return getErrorMsg("V0003B");
        if (intDishonor[1]>0) return getErrorMsg("V0003S");
      }
      if (strCheckItems[i].equals("V0004") && !V0004()) return getErrorMsg("V0004");
      if (strCheckItems[i].equals("V0005") && !V0005()) return getErrorMsg("V0005");
    }
    return "00000";
  }
  /**
   * 검증코드에 해당되는 오류메시지를 가져온다.
   * 
   * @param strCode 검증코드
   * @return 메시지
   */
  public String getErrorMsg(String strCode) {
    return AbnormalConfiguration.getInstance().getString(strCode);
  }

  /**
   * 구매사와 판매사의 사업자번호가 다른가?
   * 
   * @return 동일하면 false
   */
  private boolean V0001() {
    return (this.strBuyerBizNo.equals(strSellerBizNo)) ? false : true; 
  }
  
  /**
   * 거래불가업체가 아닌가? 
   * 
   * @return 거래불가업체이면 false
   */
  private boolean V0002() {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("ValidateCheck.checkV002");
    ResultSet rs = null;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.COMPANY_NO_TRADE_CHECK_PROC ?, ?;");
      int i = 0;
      ps.setString(++i, this.strBuyerBizNo);
      ps.setString(++i, this.strSellerBizNo);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        int intCnt = rs.getInt("CNT");
        if (intCnt>0) return false;
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return true;
  }
  /**
   * 폐업한 회사가 아닌가?
   * 
   * @return 폐업한 회사이면 false
   */
  private int[] V0003() {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger("ValidateCheck.checkV003");
    ResultSet rs = null;
    int[] intReturn = {0,0};
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.COMPANY_DISHONOR_CHECK_PROC ?, ?;");
      int i = 0;
      ps.setInt(++i, Integer.parseInt(this.cvo.CPYBUYER));
      ps.setInt(++i, Integer.parseInt(this.cvo.CPYSELLER));
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
        intReturn[0] = rs.getInt("BUYER");
        intReturn[1] = rs.getInt("SELLER");
      }
    } catch (Exception e) {
      logger.error(ps.getQueryString());
      logger.error(e.toString());
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return intReturn;
  }
  /**
   * 세금계산서의 합계금액이 거래합계금액을 초과하는가?
   * 
   * @return 초과하면 false
   */
  private boolean V0004() {
    if (this.cvo.TAXAPPROVALNO.equals("")) return true; // 세금계산서 미첨부된 매매계약서는 통과(판매계약서/비보증/기보개인+종이계산서/일반자금 중 일부판매사 거래업체)
    return new TradeBean().CHECK_SETTLED_SUM_PROC(this.cvo.TAXAPPROVALNO, this.cvo.TOTALCONTRACTAMT, Integer.parseInt(this.cvo.CTID));
  }
  /**
   * 세금계산서 작성일이 은행의 31일 허용기준에 부합하지 않는가?
   * @return 부합하지 않으면 false
   */
  private boolean V0005() {
    if (this.cvo.TAXAPPROVALNO.equals("")) return true; // 세금계산서 미첨부된 매매계약서는 통과(판매계약서/비보증/기보개인+종이계산서/일반자금 중 일부판매사 거래업체)
    String s = this.cvo.PAY_ID.substring(this.cvo.PAY_ID.length() - 1);
    if (s.equals("4")) { // 구매자금만 검증
      String today   = DateTimeUtil.getCurrentDate("");
      String valDate = TradeBean.getPermittedDateOfTaxInvoice(StrUtil.extractInteger(this.cvo.BILL_DT), StrUtil.nvl(this.cvo.BNK_CD));
      if (Integer.parseInt(today) > Integer.parseInt(valDate)) return false;
    }
    return true;
  }
}
