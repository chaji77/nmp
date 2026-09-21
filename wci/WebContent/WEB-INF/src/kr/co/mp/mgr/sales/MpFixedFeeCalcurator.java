package kr.co.mp.mgr.sales;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.ResultSet;
import java.text.DecimalFormat;

import org.apache.log4j.Logger;
import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;
import kr.co.mp.trade.CtHeaderVO;
/**
 * MP수수료 계산기
 */
public class MpFixedFeeCalcurator {
  
  private CommissionVO vo; // 수수료정보를 담을 객체

  private int        intCtId               = 0; // 수수료를 계산할 매매계약서의 아이디(CTID)
  private BigDecimal intPercent            = new BigDecimal(100); 
  private String     strPayCpy             = "S";
  private BigDecimal intRate               = new BigDecimal(.000);
  private BigDecimal intAmt                = new BigDecimal(.0000);
  private BigDecimal intStdDays            = new BigDecimal(0.000); 
  private BigDecimal intMtyStDays          = new BigDecimal(0.000); 
  private BigDecimal intMtyEndDays         = new BigDecimal(0.000); 
  private BigDecimal intSettleAmt          = new BigDecimal(0.0000);
  private BigDecimal intDiff               = new BigDecimal(0.000); 
  private BigDecimal intCpyCommissionRate  = new BigDecimal(0.000); 
  private BigDecimal intCpyCommissionRate1 = new BigDecimal(0.000); 
  private BigDecimal intCpyCommissionRate2 = new BigDecimal(0.000); 
  private BigDecimal intDiscountRate       = new BigDecimal(0.000); 
  private BigDecimal intMinFeeAmt          = new BigDecimal(0.0000);
  private BigDecimal intReceiveMoney       = new BigDecimal(0.0000);
  private BigDecimal intSumEndMoney        = new BigDecimal(0.0000);
  
  /**
   * 수수료를 계산한다
   * 
   * @param intCtId 수수료를 계산할 매매계약서의 아이디(CTID)
   * @throws Exception
   */
  public void execute(int intCtId) throws Exception {
    this.intCtId = intCtId;
    this.vo = new CommissionVO();
    if (this.loadCommissionInfo()) {
      this.setCommissionInfo();
      this.calculateCommission();
    }
  }
  /**
   * 수수료정보가 존재하는지 확인한다
   * 
   * @param intId 수수료를 계산할 매매계약서의 아이디(CTID)
   * @return 존재하면 true
   */
  public boolean isCommissionInfo(int intId) {
    this.intCtId = intId;
    this.vo = new CommissionVO(); // 수수료정보객체 초기화
    return this.loadCommissionInfo();
  }
  
  /**
   * 수수료정보를 가져온다
   * 
   * @return 수수료정보가 존재하면 true
   */
  private boolean loadCommissionInfo() {
    Connection conn = ConnectionMgr.getInstance().getConnetion();
    WrapPreparedStatementUtil ps = null;
    Logger logger = Logger.getLogger(this.getClass());
    ResultSet rs = null;
    boolean isExist = false;
    try {
      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.GET_COMMISSION_FIXED_PROC ?;");
      int i = 0;
      ps.setInt(++i, intCtId);
      logger.debug(ps.getQueryString());
      rs = ps.executeQuery();
      if (rs!=null && rs.next()) {
         this.vo.COMM_ID              = Integer.parseInt(rs.getString("COMM_ID"));
         this.vo.CPY_BUYER            = StrUtil.nvl(rs.getString("CPY_BUYER"));
         this.vo.CPY_SELLER           = StrUtil.nvl(rs.getString("CPY_SELLER"));
         this.vo.PAY_CPY              = StrUtil.nvl(rs.getString("PAY_CPY"));
         this.vo.COMM_METHOD          = StrUtil.nvl(rs.getString("COMM_METHOD"));
         this.vo.STD_DAYS             = StrUtil.nvl(rs.getString("STD_DAYS"), "0");
         this.vo.MTY_STDAYS           = StrUtil.nvl(rs.getString("MTY_STDAYS"), "0");
         this.vo.MTY_ENDDAYS          = StrUtil.nvl(rs.getString("MTY_ENDDAYS"), "0");
         this.vo.SETTLE_AMT           = StrUtil.nvl(rs.getString("SETTLE_AMT"), "0");
         this.vo.DIFF                 = StrUtil.nvl(rs.getString("DIFF"), "0");
         this.vo.CPY_COMMISSION_RATE  = StrUtil.nvl(rs.getString("CPY_COMMISSION_RATE"), "0");
         this.vo.CPY_COMMISSION_RATE1 = StrUtil.nvl(rs.getString("CPY_COMMISSION_RATE1"), "0");
         this.vo.CPY_COMMISSION_RATE2 = StrUtil.nvl(rs.getString("CPY_COMMISSION_RATE2"), "0");
         this.vo.DISCOUNT_RATE        = StrUtil.nvl(rs.getString("DISCOUNT_RATE"), "0");
         this.vo.RECEIVE_MONEY        = StrUtil.nvl(rs.getString("RECEIVE_MONEY"), "0");
         this.vo.OFFLINE_YN           = StrUtil.nvl(rs.getString("OFFLINE_YN"));
         this.vo.MAX_YN               = StrUtil.nvl(rs.getString("MAX_YN"));
         this.vo.MIN_FEE_AMT          = StrUtil.nvl(rs.getString("MIN_FEE_AMT"), "0");
         this.vo.SUM_END_MONEY        = StrUtil.nvl(rs.getString("SUM_END_MONEY"), "0");
         isExist = (this.vo.COMM_ID>0) ? true : false;
         logger.debug(this.vo.toString() + ":" + isExist);
      }
    } catch (Exception e) {
      logger.error(e.toString());
      e.printStackTrace();
    } finally {
      ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
    }
    return isExist;
  }
  
  
  /**
   * 수수료 계산에 필요한 정보를 저장한다.
   * 
   */
  private void setCommissionInfo() {
    this.strPayCpy             = this.vo.PAY_CPY;
    this.intStdDays            = new BigDecimal(this.vo.STD_DAYS);
    this.intMtyStDays          = new BigDecimal(this.vo.MTY_STDAYS);
    this.intMtyEndDays         = new BigDecimal(this.vo.MTY_ENDDAYS);
    this.intSettleAmt          = new BigDecimal(this.vo.SETTLE_AMT);
    this.intDiff               = new BigDecimal(this.vo.DIFF);
    this.intCpyCommissionRate  = new BigDecimal(this.vo.CPY_COMMISSION_RATE);
    this.intCpyCommissionRate1 = new BigDecimal(this.vo.CPY_COMMISSION_RATE1);
    this.intCpyCommissionRate2 = new BigDecimal(this.vo.CPY_COMMISSION_RATE2);
    this.intDiscountRate       = new BigDecimal(this.vo.DISCOUNT_RATE);
    this.intMinFeeAmt          = new BigDecimal(this.vo.MIN_FEE_AMT);
    this.intReceiveMoney       = new BigDecimal(this.vo.RECEIVE_MONEY); //받을 금액
    this.intSumEndMoney        = new BigDecimal(this.vo.SUM_END_MONEY); //이미 받은 금액
  }
  
  /**
   * 수수료를 계산한다.
   *
   */
  private void calculateCommission() throws Exception {
    if (vo.OFFLINE_YN.equals("Y")) setNoCommission(new BigDecimal(0.000)); // 오프라인=무료
    else {
      //수수료율 + 수수료율 1 + 수수료율 2 = 0 이면 무조건 (수수료율 : 0% / 수수료금액 : 0원)
      if ((this.intCpyCommissionRate.add(this.intCpyCommissionRate1.add(this.intCpyCommissionRate2))).doubleValue() == 0.000) {
        this.intRate = new BigDecimal(0.000);
        this.intAmt  = new BigDecimal(0.000);
      } else {
        String strMethod = StrUtil.nvl(this.vo.COMM_METHOD, "B20");
        if (strMethod.equals("A10")) calculateA10();
        else if (strMethod.equals("B10")) calculateB10();
        else if (strMethod.equals("B20")) calculateB20();
        else if (strMethod.equals("C10")) calculateC10();
        else if (strMethod.equals("D10")) calculateD10();
        else if (strMethod.equals("D20")) calculateD20();
        else if (strMethod.equals("F10")) calculateF10();
        else calculateB20();
        calculateMax(); // 총액한도제한처리
        checkMaxCollect(); // 과징수 체크
      }
    }
  }
  
  /**
   * 수수료면제
   * 
   * @param rate
   */
  private void setNoCommission(BigDecimal rate) throws Exception {
    this.intRate = rate;
    this.intAmt = new BigDecimal(0.0000);
  }
  
  /**
   * 기본요금제 + 추가요금제
   */
  private void calculateA10() throws Exception {
    if (this.intStdDays.intValue() >= this.intDiff.intValue()) {
      this.intRate = this.intCpyCommissionRate;
    } else {
      this.intRate = (
                (this.intCpyCommissionRate2.subtract(this.intCpyCommissionRate1)).divide(
                      (this.intMtyEndDays.subtract(this.intStdDays)),
                      10,
                      BigDecimal.ROUND_HALF_UP
                 )
              ).multiply(this.intDiff.subtract(this.intStdDays));
      this.intRate = this.intCpyCommissionRate1.add(this.intRate);
    }
    roundRate();
    calculateAmount();
  }
  
  /**
   * 정율
   * 수수료율 = 기본수수료율
   *
   */
  private void calculateB10() throws Exception {
    this.intRate = this.intCpyCommissionRate;
    roundRate();
    calculateAmount();
  }
  
  /**
   * 연환산 정률
   * 수수료율 = 기본수수료율/365*대출일수
   *
   */
  private void calculateB20() throws Exception {
    BigDecimal intYear = new BigDecimal(365.000);
    this.intRate = (
        this.intCpyCommissionRate.divide(intYear, 
                         10, 
                         BigDecimal.ROUND_HALF_UP)
             ).multiply(this.intDiff);
    roundRate();
    calculateAmount();
  }
  
  /**
   * 기간변동
   *
   *
   */
  private void calculateC10() throws Exception {
    this.intRate =
      (
        (this.intCpyCommissionRate2.subtract(this.intCpyCommissionRate1)).divide(
              (this.intMtyEndDays.subtract(this.intMtyStDays)),
              10,
              BigDecimal.ROUND_HALF_UP
         )
      ).multiply(this.intDiff.subtract(this.intMtyStDays));
    this.intRate = this.intCpyCommissionRate1.add(this.intRate);
    roundRate();
    calculateAmount();
  }
  
  /**
   * 연단위 수수료 일시납입 상품의 경우 
   * 수수료율은 0
   * 수수료 = 미납수수료 - 기납수수료
   * 초회 전액 청구
   *
   */
  private void calculateD10() throws Exception {
    this.intRate = new BigDecimal(0.000);
    CommissionVO cvo = new CommissionBean().CHECK_COMM_METHOD_D10_PERIOD(this.intCtId);    // 일시납 기간 초과시 예외처리
    if (cvo!=null && cvo.COMM_ID > 0) {
      this.intAmt = this.intReceiveMoney.subtract(this.intSumEndMoney);    // 받을 금액 - 받은 금액
      if (this.intAmt.doubleValue() < 0) {
        this.intAmt = new BigDecimal(.0000);
      }
    } else {
      this.intAmt = new BigDecimal(.0000);
    }
  }

  private void calculateD20() throws Exception {
    calculateD10();
  }
  
  /**
   * 면제일 경우 
   */
  private void calculateF10() throws Exception {
    this.intAmt   = new BigDecimal(.0000);
    this.intRate   = new BigDecimal(.000);
  }

  /**
   * 수수료율을 조정한다.
   * 수수료율 = 수수료율*할인율
   * 수수료율은 소수점 4자리에서 반올림한다.
   */
  private void roundRate() throws Exception {
    try {
      BigDecimal c = this.intPercent.subtract(intDiscountRate);
      c = c.divide(this.intPercent, 10, BigDecimal.ROUND_HALF_UP);
      this.intRate = this.intRate.multiply(c);
      this.intRate = this.intRate.setScale(3, BigDecimal.ROUND_HALF_UP);
    } catch (Exception e) {
      System.out.println(e.toString());
    }
    
  }
  
  /**
   * 수수료를 계산한다.
   * 수수료는 원단위 절사한다.
   *
   * 수수료 = 결제금액*수수료율/100.
   * 최저수수료에 미달하면 최저수수료를 적용.
   */
  private void calculateAmount() throws Exception {
    this.intAmt = (this.intSettleAmt.multiply(this.intRate)).divide(this.intPercent, 0, BigDecimal.ROUND_FLOOR);
    this.intAmt = (this.intAmt.subtract(this.intMinFeeAmt).doubleValue()<0)
                ? this.intMinFeeAmt
                : this.intAmt;
  }

  /**
   * 수수료 총액한도 상품의 경우 총액한도를 넘지않도록 수수료를 다시 계산한다.
   * 수수료 = ((남은수수료-기납수수료)>낼 수수료) ? 낼 수수로 : 미납수수료-기납수수료
   * 수수료율 = 수수료/결제금액
   */
  private void calculateMax() throws Exception {
    if (vo.MAX_YN.trim().equals("Y")) {
      if ((this.intReceiveMoney.subtract(this.intSumEndMoney)).doubleValue() > this.intAmt.doubleValue()) {
        // this.intAmt  = this.intAmt;
        // this.intRate = this.intRate;
        // this.intRate = this.intAmt.divide(this.intSettleAmt, 3, BigDecimal.ROUND_HALF_UP);
      } else {
        if ((this.intReceiveMoney.subtract(this.intSumEndMoney)).doubleValue() > 0){
          this.intAmt  = this.intReceiveMoney.subtract(this.intSumEndMoney);
          this.intRate = this.intAmt.divide(this.intSettleAmt, 3, BigDecimal.ROUND_HALF_UP);
        } else {
          this.intAmt  = new BigDecimal(.0000);
          this.intRate = new BigDecimal(.000);
        }
      }
    }
  }
  
  /**
   * 일시납/연맥스일 경우, 수수료 과징수 체크를 위한 계약승인된 매매계약서 수수료합 가져오기
   */ 
  private void checkMaxCollect() throws Exception {
    BigDecimal intMpfee_totalamt = new BigDecimal(0.0);
    if (this.vo.MAX_YN.equals("Y") || this.vo.COMM_METHOD.equals("D10") || this.vo.COMM_METHOD.equals("D20")) {
      CommissionVO cvo = new CommissionBean().CHECK_MPFEE_TOTALAMT_SUM_PROC(this.vo.CPY_BUYER);
      if (cvo!=null && cvo.TOTAL_CNT > 0) {
        intMpfee_totalamt = new BigDecimal(cvo.MPFEE_TOTALAMT);
      }
      
      BigDecimal intPlusEndMoney = this.intSumEndMoney.add(intMpfee_totalamt);
      if (intPlusEndMoney.subtract(this.intReceiveMoney).doubleValue() >= 0) {
        this.intAmt = new BigDecimal(.0000);
        this.intRate = new BigDecimal(.000);
      } else if (vo.MAX_YN.trim().equals("Y")) {
        if ((this.intReceiveMoney.subtract(intPlusEndMoney)).doubleValue() > this.intAmt.doubleValue()) {}
        else {
          if ((this.intReceiveMoney.subtract(intPlusEndMoney)).doubleValue() > 0) {
            this.intAmt = this.intReceiveMoney.subtract(intPlusEndMoney);
            this.intRate = this.intAmt.divide(this.intSettleAmt, 3, BigDecimal.ROUND_HALF_UP);
          } else {
            this.intAmt = new BigDecimal(.0000);
            this.intRate = new BigDecimal(.000);
          }
        }
      }
    }
  }
  
  /***************************************
   * 
   * GETTER
   * 
   **************************************/
  
  public String getPayCpy() {
    return this.strPayCpy;
  }
  
  public String getMethod() {
    return StrUtil.nvl(this.vo.COMM_METHOD);
  }
  
  public double getRate() {
    return this.intRate.doubleValue();
  }
  
  public double getAmt() {
    return this.intAmt.doubleValue();
  }
  
  public double getSupplyAmt() {
    return (this.intAmt.divide(new BigDecimal(1.1), 0, BigDecimal.ROUND_HALF_UP)).doubleValue();
  }
  
  public double getTaxAmt() {
    return (this.intAmt.subtract(new BigDecimal(this.getSupplyAmt()))).doubleValue();
  }
  
  public BigDecimal getSettleAmt() {
    return this.intSettleAmt;
  }
  
  public BigDecimal getDiff() {
   return this.intDiff;
  }
  
  public CtHeaderVO getCtHeaderFormat(CtHeaderVO vo) {
    DecimalFormat df = new DecimalFormat("#.000");
    vo.MPFEERATE = df.format(this.getRate());
    df = new DecimalFormat("#");
    vo.MPFEE_SUPPLYAMT = df.format(this.getSupplyAmt());
    vo.MPFEE_TAXAMT = df.format(this.getTaxAmt());
    vo.MPFEE_TOTALAMT = df.format(this.getAmt());
    return vo;
  }
}
