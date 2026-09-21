package kr.co.mp.trade;

import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;

import kr.co.funology.fw.mgr.ConfigurationMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.mp.mgr.sales.MpFeeCalcurator;

public class TradeBean {
  TradeDAO dao;
  public TradeBean() {
    this.dao = new TradeDAO();
  }
  public int SIGNINFO_ADD_PROC(String str) {
    return this.dao.SIGNINFO_ADD_PROC(str);
  }
  public CtHeaderVO CT_HEADER_ADD_PROC(CtHeaderVO vo, String strItemXml) {
    CtHeaderVO r = this.dao.CT_HEADER_ADD_PROC(vo, strItemXml);
    // ADD A COMMISSION WHEN WRITING A CONTRACT : 2025-03-18
    vo.CTID = r.CTID;
    MpFeeCalcurator calc = new MpFeeCalcurator();
    try {
      calc.execute(Integer.parseInt(vo.CTID));
      vo = calc.getCtHeaderFormat(vo);
    } catch (Exception e) {}
    this.dao.CT_HEADER_MPFEE_ADD_PROC(vo);
    return r;
  }
  public CtHeaderVO CT_HEADER_MOD_PROC(CtHeaderVO vo, String strItemXml) {
    // ADD A COMMISSION WHEN MODIFYING A CONTRACT : 2025-03-18
    MpFeeCalcurator calc = new MpFeeCalcurator();
    try {
      calc.execute(Integer.parseInt(vo.CTID));
      vo = calc.getCtHeaderFormat(vo);
    } catch (Exception e) {}
    return this.dao.CT_HEADER_MOD_PROC(vo, strItemXml);
  }
  public int CT_HEADER_CHANGE_STATUS_PROC(int intCtId, int intCpyId, String strStatus, String strLoginId, String strManagerYn) {
    return this.dao.CT_HEADER_CHANGE_STATUS_PROC(intCtId, intCpyId, strStatus, strLoginId, strManagerYn);
  }
  public CtHeaderVO CT_HEADER_CONFIRM_PROC(int intCtId, int intCpyId, String strLoginId, String strRemoteIP, int intSignId, String strManagerYn, CtHeaderVO hvo) {
    return this.dao.CT_HEADER_CONFIRM_PROC(intCtId, intCpyId, strLoginId, strRemoteIP, intSignId, strManagerYn, hvo);
  }
  /**
   * 본 계약금액이 (세금계산서 발행금액 - 매매계약서 결제금액합계액)을 초과하는지 확인한다.
   * 
   * @param strTaxAppNo
   * @param strContractAmt
   * @return
   */
  public boolean CHECK_SETTLED_SUM_PROC(String strTaxAppNo, String strContractAmt, int intCtId) {
    long lngLimitAmt = this.dao.CHECK_SETTLED_SUM_PROC(strTaxAppNo, intCtId);
    if (lngLimitAmt>0) {
      Long lngContractAmt = Long.parseLong(strContractAmt);
      if (lngContractAmt > lngLimitAmt) return false;
    } else return false;
    return true;
  }
  
  public long[] CT_HEADER_CONTRACT_AMT_PROC(int intBuyerId, int intSellerId, int intMonth) {
    return this.dao.CT_HEADER_CONTRACT_AMT_PROC(intBuyerId, intSellerId, intMonth);
  }
  
  public CtHeaderVO CT_HEADER_SEND_PROC(int intCtId) {
    return this.dao.CT_HEADER_SEND_PROC(intCtId);
  }
  
  public ArrayList<CtHeaderVO> CT_HEADER_LIST_PROC (CtHeaderVO pvo, int intCpyId, String strStartYmd, String strEndYmd, int intTargetCpyId, String strPageCode, int intPrsId) {
    return this.dao.CT_HEADER_LIST_PROC(pvo, intCpyId, strStartYmd.replaceAll("-",  ""), strEndYmd.replaceAll("-",  ""), intTargetCpyId, strPageCode, intPrsId);
  }
  public ArrayList<CtHeaderVO> CT_HEADER_LIST_PROC (CtHeaderVO pvo, int intCpyId, String strStartYmd, String strEndYmd, int intTargetCpyId, String strPageCode, int intPrsId, String strGuarInstCd) {
    return this.dao.CT_HEADER_LIST_PROC(pvo, intCpyId, strStartYmd.replaceAll("-",  ""), strEndYmd.replaceAll("-",  ""), intTargetCpyId, strPageCode, intPrsId, strGuarInstCd);
  }
  public ArrayList<CtHeaderVO> CT_HEADER_COMING_LIST_PROC (CtHeaderVO pvo, int intCpyId, String strStartYmd, String strEndYmd) {
    return this.dao.CT_HEADER_COMING_LIST_PROC(pvo, intCpyId, StrUtil.nvl(strStartYmd, "20200101").replaceAll("-",  ""), StrUtil.nvl(strEndYmd, "20801231").replaceAll("-",  ""));
  }
  public CtHeaderVO CT_HEADER_DETAIL_PROC(int intCtId) {
    return this.dao.CT_HEADER_DETAIL_PROC(intCtId);
  }
  public ArrayList<CtItemVO> CT_ITEM_LIST_PROC (int intCtId) {
    return this.dao.CT_ITEM_LIST_PROC(intCtId);
  }
  public ArrayList<UnusualTransactionVO> UNUSUAL_TRANSACTION_LIST_BY_CTID_PROC(String strCtIds, String strWithReleased) {
    return this.dao.UNUSUAL_TRANSACTION_LIST_BY_CTID_PROC(strCtIds, strWithReleased);
  }
  public ArrayList<SignVO> SIGNINFO_LIST_BY_CTID_PROC(int intCtId) {
    return this.dao.SIGNINFO_LIST_BY_CTID_PROC(intCtId);
  }
  public int UNUSUAL_TRANSACTION_RELEASE_PROC(UnusualTransactionVO pvo) {
    return this.dao.UNUSUAL_TRANSACTION_RELEASE_PROC(pvo);
  }
  public long GUARANTEE_LIMIT_PROC(int intCpyId, String strBankCd, int intPayId) {
    return this.dao.GUARANTEE_LIMIT_PROC(intCpyId, strBankCd, intPayId);
  }
  public ArrayList<UnusualListVO> UNUSUAL_TRANSACTION_LIST_PROC(int intPage, int intPageSize, String strWithReleasedYN, String guar_gubun) {
    return this.dao.UNUSUAL_TRANSACTION_LIST_PROC(intPage, intPageSize, strWithReleasedYN, guar_gubun);
  }
  public ArrayList<TodayStatVO> DAILY_STAT_PROC(String strDate) {
    return this.dao.DAILY_STAT_PROC(strDate);
  }
  
  /**
   * 은행별로 세금계산서 작성일 기준으로 사용가능한 결제마감일을 가져온다
   * @param strDate   세금계산서 작성일
   * @param strBankCd 은행코드
   * @return 가능한 결제마감일
   */
  public static String getPermittedDateOfTaxInvoice(String strDate, String strBankCd) {
    String strReturnDay = "";
    int    intPlusOption = 0;
    DateTimeFormatter f = DateTimeFormatter.ofPattern("yyyyMMdd");
    LocalDate today = LocalDate.now();
    YearMonth pym   = YearMonth.of(today.getYear(), today.getMonthValue()).minusMonths(1);
    LocalDate ld    = pym.atEndOfMonth();
    String strLastMonthEndDate = ld.format(f);
    strDate = StrUtil.nvl(strDate, strLastMonthEndDate);
    try {
      LocalDate c = LocalDate.parse(strDate, f);
      strReturnDay = (c.plusDays(30)).format(f);
    } catch (Exception e) {
      return strDate;
    }
    String strPlusOneDayBank = ConfigurationMgr.getInstance().getString("BANK_31DAY_ADD_DATE_WHEN_HOLIDAY");
    if (strPlusOneDayBank.contains(strBankCd)) {
      intPlusOption = 1;
    }
    return TradeDAO.HOLIDAY_PERMIT_INVOICE_DAY_PROC(strReturnDay, intPlusOption);
  }
  
  /**
   * 매매계약서 승인
   * @param intCtId      매매계약서아이디
   * @param intCpyId     회원사아이디
   * @param strLoginId   로그인아이디
   * @param strRemoteIP  아이피
   * @param intSignSeq   서명키
   * @param strManagerYn 관리자여부
   * @return
   */
  public String confirm(int intCtId, int intCpyId, String strLoginId, String strRemoteIP, int intSignSeq, String strManagerYn) {

    String strErrorMsgPrefix = AbnormalConfiguration.getInstance().getString("ERR_HEADER");

    /********** DATA LOAD ************/
    CtHeaderVO headerVo = this.CT_HEADER_DETAIL_PROC(intCtId);
    ArrayList<CtItemVO> arrItems = this.CT_ITEM_LIST_PROC(intCtId);
    
	/*
	 * if (headerVo.CTTYPE.equals("B")) headerVo.SELLER_IP = strRemoteIP; else
	 * headerVo.BUYER_IP = strRemoteIP;
	 */
    if (String.valueOf(intCpyId).equals(headerVo.CPYBUYER)) {
        headerVo.BUYER_IP = strRemoteIP;
        headerVo.SGN_ID   = String.valueOf(intSignSeq);

    } else if (String.valueOf(intCpyId).equals(headerVo.CPYSELLER)) {
        headerVo.SELLER_IP = strRemoteIP;
        headerVo.SELLER_APP_SGN_ID = String.valueOf(intSignSeq);
    }
    
    /********** CHECH ABNORMAL TRANSACTION ************/
    AbnormalTransactionCheck abnormal = new AbnormalTransactionCheck();
    boolean start = abnormal.initialize(intCpyId, headerVo, arrItems);
    if (start && !abnormal.initLimit().equals("0000")) {
      return "{\"step\":\"abnormal\",\"msg\":\""+ strErrorMsgPrefix + abnormal.getFailMsgInitLimit() +"\"}";
    }
    if (start && !abnormal.isBlocked()) { // RYAN-MIN. 이상거래가 걸려 있으면 거래 진행 차단 추가 (2025-03-28)
      String msg = StrUtil.nvl(abnormal.execute("CHECK_STEP_CONFIRM"));
      if (!msg.equals("00000")) {
        return "{\"step\":\"abnormal\",\"msg\":\""+ strErrorMsgPrefix + abnormal.getErrorMsgAndSave(msg)+"\"}";
      }
    } else {
      return "{\"step\":\"abnormal\",\"msg\":\"이상거래 사유 미해소 또는 거래 검증 실패로 거래를 진행할 수 없습니다. 고객센터로 문의바랍니다.\"}";
    }
    
    /********** CALCULATE FEE ************/
    MpFeeCalcurator calc = new MpFeeCalcurator();
    try {
      calc.execute(intCtId);
      headerVo = calc.getCtHeaderFormat(headerVo);
    } catch (Exception e) {
      return "{\"step\":\"abnormal\",\"msg\":\""+ConfigurationMgr.getInstance().getString("ERR_MPFEE_MSG")+"\"}";
    }
    
    /********** CONFIRM ************/
    CtHeaderVO vo = this.CT_HEADER_CONFIRM_PROC(intCtId, intCpyId, strLoginId, strRemoteIP, intSignSeq, strManagerYn, headerVo);
    return "SUCCESS____"+StrUtil.nvl(vo.STATUS)+"____"+StrUtil.nvl(vo.CONFIRM_SETTLE_YN);
  }
  
  /* STATUS CHANGE LOGS */
  public ArrayList<String[]> CT_HEADER_STATUS_CHANGE_LIST_BY_CTID_PROC(int intCtId) {
    return this.dao.CT_HEADER_STATUS_CHANGE_LIST_BY_CTID_PROC(intCtId);
  }
  
  public TradeEntitiesVO CT_HEADER_ENTITIES_PROC(int intCtId) {
    return this.dao.CT_HEADER_ENTITIES_PROC(intCtId);
  }
  public ArrayList<TransactionResultVO> RECEIVE_XML_K311_LIST_BY_CTNO_PROC(String strCtNos) {
    return this.dao.RECEIVE_XML_K311_LIST_BY_CTNO_PROC(strCtNos);
  }
  
  public void CT_HEADER_ADD_SGN_PROC(int intCtId, int intSgnId) {
    this.dao.CT_HEADER_ADD_SGN_PROC(intCtId, intSgnId);
  }
}
