package kr.co.mp.trade;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConfigurationMgr;
import kr.co.funology.fw.util.DateTimeUtil;
import kr.co.funology.fw.util.StrUtil;
import kr.co.mp.c.CompanyVO;
import kr.co.mp.c.CustomerBean;
import kr.co.mp.c.RelationCompanyBean;
import kr.co.mp.c.RelationCompanyVO;
import kr.co.soap.controll.A312VO;
import kr.co.soap.kodit.loan.emtnet.EmtNetA311;

/**
 * 이상거래 검증 클래스
 * 
 * @see abnormaltransation.properties
 */
public class AbnormalTransactionCheck {
  
  private int intCpyId = 0;                    // 검증대상 회원사아이디
  private CtHeaderVO hvo;                      // 검증할 매매계약서
  private ArrayList<CtItemVO> arrItems;        // 검증할 매매계약의 품목
  private CustomerBean bean;                   // 구매사 및 판매사 정보를 가져올때 사용하기 위한 bean
  private CompanyVO buyerVo;                   // 구매사 정보
  private CompanyVO sellerVo;                  // 판매사 정보
  private TaxVO taxVo;                         // 세금계산서 정보
  private long   lngLimit;                     // 결제한도금액
  private ArrayList<String> arrReleasedCauses; // 해제된 이상거래 항목
  private Logger logger;                       // 로거

  /**
   * 이상거래 검증을 위한 데이터 초기화
   * 
   * @param h  CtHeader
   * @param i  CtItems
   */
  public boolean initialize(int intCpyId, CtHeaderVO h, ArrayList<CtItemVO> i) {
    this.logger   = Logger.getLogger(this.getClass());
    this.intCpyId = intCpyId;
    this.hvo      = h;
    this.arrItems = i;
    this.bean     = new CustomerBean();
    this.lngLimit = 0L;
    if (this.hvo!=null && this.hvo.CPYBUYER!=null && StrUtil.isOnlyNumeric(this.hvo.CPYBUYER)) this.buyerVo = this.getCompany(Integer.parseInt(this.hvo.CPYBUYER));
    if (this.hvo!=null && this.hvo.CPYSELLER!=null && StrUtil.isOnlyNumeric(this.hvo.CPYSELLER)) this.sellerVo = this.getCompany(Integer.parseInt(this.hvo.CPYSELLER));
    if (this.hvo!=null && StrUtil.isOnlyNumeric(this.hvo.SBILL_SEQ) && !this.hvo.SBILL_SEQ.equals("0")) {
      this.taxVo = new TaxBean().CT_BILL_MASTER_DETAIL_PROC(this.hvo.SBILL_SEQ);
    } else this.taxVo = null;
    boolean isReady = (this.hvo==null || this.arrItems==null || this.arrItems.size()==0 || this.buyerVo==null || this.sellerVo==null) ? false : true;
    try {
      System.out.println("this.hvo      : " + this.hvo);
      System.out.println("this.arrItems : " + this.arrItems);
      System.out.println("this.buyerVo  : " + this.buyerVo);
      System.out.println("this.sellerVo : " + this.sellerVo);
      System.out.println("this.taxVo    : " + this.taxVo);
      System.out.println("isReady       : " + isReady);
    } catch (Exception e) {}
    return isReady;
  }
  /**
   * 한도조회
   * <pre>A311을 선행하려면 abnormaltransaction.properties의 USE_A311_FOR_WRITE값을 Y로 설정한다</pre>
   * @return
   */
  public String initLimit() {
    if (StrUtil.nvl(AbnormalConfiguration.getInstance().getString("USE_A311_FOR_WRITE"), "N").equals("Y")) {
      EmtNetA311 a311 = new EmtNetA311(this.intCpyId, hvo.BNK_CD, Integer.parseInt(hvo.PAY_ID), 0.0);
      A312VO tranVo = a311.executeA311();
      if (tranVo.getCommonElement().getResponseCode().equals("0000")) {
        this.lngLimit = Long.parseLong(tranVo.getBankLimitAMT());
      } else return tranVo.getCommonElement().getResponseCode();
    } else {
      this.lngLimit = new TradeBean().GUARANTEE_LIMIT_PROC(this.intCpyId, hvo.BNK_CD, Integer.parseInt(hvo.PAY_ID));
    }
    return "0000";
  }
  /**
   * 보증서가 없을 때 관련 메시지를 가져온다.
   * 
   * @return
   */
  public String getFailMsgInitLimit() {
    return StrUtil.nvl(AbnormalConfiguration.getInstance().getString("KD_NOT_HAS_GUARANTEE"));
  }
  /**
   * 이미 이상거래에 걸려있는지 확인한다. 이미 이상거래에 걸려 있으면 추가적인 이상거래 검증을 진행하지 않는다.
   * 
   * @return
   */
  public boolean isBlocked() {
    ArrayList<String> a = AbnormalTransactionDAO.UNUSUAL_TRANSACTION_BLOCKED_BY_CTID_PROC(Integer.parseInt(this.hvo.CTID));
    boolean is = (a!=null && a.size()>0) ? true : false;
    System.out.println("isBlocked : " + is);
    return is;
  }
  /**
   * 이상거래 검증을 시작한다.
   * 
   * @param strStep 이상거래 검증 단계 (작성/승인전/승인시로 구분한다)
   * @return 정상이면 00000, 아니면 이상거래코드
   */
  public String execute(String strStep) {
    this.arrReleasedCauses = AbnormalTransactionDAO.UNUSUAL_TRANSACTION_RELEASED_BY_CTID_PROC(Integer.parseInt(this.hvo.CTID));
    // START BRANCH-OFF : 신보와 기보의 이상거래 검증 항목이 달라 분기한다. (2024/04/25)
    String strBranchOffYN  = StrUtil.nvl(AbnormalConfiguration.getInstance().getString("CHECK_STEP_BRANCH"), "N");
    String strStepTail = "";
    if (strBranchOffYN.equals("Y")) {
      String[] strKoditProds = (StrUtil.nvl(AbnormalConfiguration.getInstance().getString("KODIT_PRODUCTS"))).split(",");
      String[] strKiboProds  = (StrUtil.nvl(AbnormalConfiguration.getInstance().getString("KIBO_PRODUCTS"))).split(",");
      if (this.hvo.PAY_ID == null || this.hvo.PAY_ID.equals("")) strStepTail = "";
      else {
        for (int p = 0; p<strKoditProds.length; p++) { // 신보상품인지
          if (hvo.PAY_ID.equals(strKoditProds[p])) {
            strStepTail = "_KODIT";
            break;
          }
        }
        for (int p = 0; p<strKiboProds.length; p++) {  // 기보상품인지
          if (hvo.PAY_ID.equals(strKiboProds[p])) {
            strStepTail = "_KIBO";
            break;
          }
        }
      }
      strStep = strStep + strStepTail;
    }
    // END OF BRANCH-OFF
    if (strBranchOffYN.equals("Y") && strStepTail.equals("")) return "00000"; // 신보도 아니고 기보도 아니면 SKIP
    String[] strCheckItems = (StrUtil.nvl(AbnormalConfiguration.getInstance().getString(strStep))+",").split(",");
    System.out.println(this.hvo.PAY_ID);
    System.out.println(strStep);
    System.out.println(Arrays.toString(strCheckItems));
    for (int i=0; i<strCheckItems.length; i++) {
      if (strCheckItems[i].equals("KD001") && this.KD001() && !this.isReleasedCause("KD001")) return "KD001";
      if (strCheckItems[i].equals("KD002") && this.KD002() && !this.isReleasedCause("KD002")) return "KD002";
      if (strCheckItems[i].equals("KD003") && this.KD003() && !this.isReleasedCause("KD003")) return "KD003";
      if (strCheckItems[i].equals("KD004") && this.KD004() && !this.isReleasedCause("KD004")) return "KD004";
      if (strCheckItems[i].equals("KD005") && this.KD005(this.lngLimit) && !this.isReleasedCause("KD005")) return "KD005";
      if (this.hvo.CTTYPE.equals("B")) {
        if (strCheckItems[i].equals("KD006") && this.KD006() && !this.isReleasedCause("KD006")) return "KD006";
      }
      if (strCheckItems[i].equals("KD007") && this.KD007(this.lngLimit) && !this.isReleasedCause("KD007")) return "KD007";
      if (strCheckItems[i].equals("KD008") && this.KD008() && !this.isReleasedCause("KD008")) return "KD008";
      if (strCheckItems[i].equals("KD009") && this.KD009() && !this.isReleasedCause("KD009")) return "KD009";
      if (strCheckItems[i].equals("KD010") && this.KD010() && !this.isReleasedCause("KD010")) return "KD010";
      if (strCheckItems[i].equals("KD012") && this.KD012() && !this.isReleasedCause("KD012")) return "KD012";
      if (strCheckItems[i].equals("KD013") && this.KD013() && !this.isReleasedCause("KD013")) return "KD013";
      if (strCheckItems[i].equals("KD014") && this.KD014() && !this.isReleasedCause("KD014")) return "KD014";
      // ADD FOR KIBO
      if (strCheckItems[i].equals("KD015") && this.KD015(this.lngLimit) && !this.isReleasedCause("KD015")) return "KD015";
      if (strCheckItems[i].equals("KD016") && this.KD016() && !this.isReleasedCause("KD016")) return "KD016";
      if (strCheckItems[i].equals("KD017") && this.KD017() && !this.isReleasedCause("KD017")) return "KD017";
    }
    return "00000";
  }
  /**
   * 오류가 발생한 이상거래 코드로 오류 메시지를 가져오고 디비에도 저장한다.
   * 
   * @param strCode 이상거래 코드
   * @return 메시지
   */
  public String getErrorMsgAndSave(String strCode) {
    try { 
      AbnormalTransactionDAO.UNUSUAL_TRANSACTION_ADD_PROC(Integer.parseInt(hvo.CTID), strCode);
    } catch (Exception e) {
      this.logger.error("getErrorMsgAndSave.UNUSUAL_TRANSACTION_ADD_PROC");
      this.logger.error(e.toString());
    }
    return getErrorMsg(strCode);
  }
  /**
   * 이상거래 메시지를 가져온다. 이것은 getErrorMsgAndSave()에서 호출된다. 
   * 
   * @param strCode 이상거래코드
   * @return 메시지
   */
  public String getErrorMsg(String strCode) {
    String rtn = AbnormalConfiguration.getInstance().getString(strCode);
    String strTel = ConfigurationMgr.getInstance().getString("OWNER_TEL");
    String strFax = ConfigurationMgr.getInstance().getString("OWNER_FAX");
    rtn = rtn.replaceAll("____OWNER_TEL____", strTel);
    rtn = rtn.replaceAll("____OWNER_FAX____", strFax);
    return rtn;
  }
  /**
   * 해제된 이상거래인지 확인한다.
   * 
   * @param strCode 이상거래코드
   * @return 해제여부
   */
  private boolean isReleasedCause(String strCode) {
    if (this.arrReleasedCauses!=null && this.arrReleasedCauses.size()>0) {
      for (String s : this.arrReleasedCauses) {
        if (s.equals(strCode)) return true;
      }
    }
    return false;
  }
  
  /**
   * 업체의 정보를 가져온다
   * @param intCpyId 업체아이디
   * @return 업체정보
   */
  private CompanyVO getCompany(int intCpyId) {
    return this.bean.COMPANY_DETAIL_PROC(intCpyId);
  }
  
  /**
   * 본지사정보를 가져온다.
   * 
   * @param intTargetCpyId 거래 대상의 회원사아이디
   * @return 거래대상의 본지사정보
   */
  private String getBranches(int intTargetCpyId) {
    String strRelatedCompaies = "";
    ArrayList<RelationCompanyVO> arrRelatedCompanies = new RelationCompanyBean().RELATION_COMPANY_DETAIL_PROC(intTargetCpyId, "N");
    if (arrRelatedCompanies!=null && arrRelatedCompanies.size()>0) {
      for (RelationCompanyVO v : arrRelatedCompanies) {
        strRelatedCompaies += "," + v.RELATIONBIZNO;
      }
    }
    return strRelatedCompaies;
  }
  
  /**
   * 계약의 거래금액을 가져온다.
   * 
   * @return 계약의 거래금액
   */
  private long getTransactionAmt() {
    String amt = StrUtil.nvl(this.hvo.TOTALCONTRACTAMT, "0");
    if (!StrUtil.isOnlyNumeric(amt)) return 0L;
    return Long.parseLong(amt);
  }
  
  /**
   * 판매사의 당기 매출액을 가져온다.
   * 
   * @return 판매사 당기매출액
   */
  private long getSellerRevenue() {
    String strSalesAmt = StrUtil.nvl(this.sellerVo.SALES_AMT, "0");
    long lngSalesAmt = 0L;
    this.logger.debug("getSellerRevenue");
    this.logger.debug(this.sellerVo.CPY_FOUNDYEAR);
    if (StrUtil.isOnlyNumeric(strSalesAmt) && Long.parseLong(strSalesAmt)>0) {
      lngSalesAmt = Long.parseLong(strSalesAmt) * 1000000;
    }
    if (lngSalesAmt==0) { // START-UP
      String y = StrUtil.nvl(this.sellerVo.CPY_FOUNDYEAR, DateTimeUtil.getCurrentDate(""));
      if (y.length()>3) y = y.substring(0,4);
      if (StrUtil.isOnlyNumeric(y)) {
        int intY = Integer.parseInt(y);
        int intC = Integer.parseInt(DateTimeUtil.getCurrentDate("").substring(0,4)) - 1;
        if (intY >= intC) lngSalesAmt = -1L;
      }
    }
    return lngSalesAmt;
  }
  /**
   *  판매사의 최근 6개월 거래금액 합계를 가져온다 
   */
  private long getSellerRecentContractAmt() {
    return (new TradeBean().CT_HEADER_CONTRACT_AMT_PROC(0, this.sellerVo.CPY_ID, 6))[0];
  }
  /**
   * 양사간 최근 1년 거래금액 합계 및 평균을 가져온다 
   */
  private long[] getRecentContractAmtAvg() {
    return new TradeBean().CT_HEADER_CONTRACT_AMT_PROC(this.buyerVo.CPY_ID, this.sellerVo.CPY_ID, 12);
  }

  ////////////////////////////////////////////////////////////////////////////////
  //
  // CHECK ABNORMAL TRANSACTION BY CODE
  //
  ////////////////////////////////////////////////////////////////////////////////
  
  /**
   * 판매,구매기업이 동일한 IP주소로 접속했는가?
   * 
   * @return 동일하면 true
   */
  public boolean KD001() {
    this.logger.debug("KD001");
    this.logger.debug(this.hvo.SELLER_IP + "----" + this.hvo.SGN_ID);
    this.logger.debug(this.hvo.BUYER_IP + "----" + this.hvo.SELLER_APP_SGN_ID);
    if (hvo.SGN_ID.equals("0") && hvo.SELLER_APP_SGN_ID.equals("0")) return false;
    return StrUtil.nvl(this.hvo.SELLER_IP).equals(StrUtil.nvl(this.hvo.BUYER_IP));
  }

  /**
   * 판매·구매기업의 대표자 성명이 동일한가?
   * <pre>공백을 제거한 대표자 성명을 비교</pre>
   * 
   * @return 동일하면 true
   */
  public boolean KD002() {
    this.logger.debug("KD002");
    String buyer  = StrUtil.nvl(this.buyerVo.CPY_CEO_NAME).trim().replaceAll(" ", "");
    String seller = StrUtil.nvl(this.sellerVo.CPY_CEO_NAME).trim().replaceAll(" ", "");

    if (!buyer.contains(",") && !seller.contains(",")) {
      return buyer.equals(seller);
    }

    Set<String> setA = new HashSet<>(Arrays.asList(buyer.split(",")));
    Set<String> setB = new HashSet<>(Arrays.asList(seller.split(",")));

    for (String word : setA) {
      if (setB.contains(word)) {
        return true;
      }
    }
    return false;
  }
  
  /**
   * 경상적인 영업활동 이외의 거래로 의심되는 업종 및 매매거래품목에 대한 거래인가?
   * 
   * @return 거래불가품목명이 포함되어 있으면 true
   */
  public boolean KD003() {
    this.logger.debug("KD003");
    boolean isContain = false;
    String strBlockWords = ConfigurationMgr.getInstance().getString("TRADE_BLOCK_ITEM_NM"); // 거래불가품목명
    String[] arrBlockWords = strBlockWords.split(",");
    if (this.arrItems!=null && this.arrItems.size()>0) {
      for (CtItemVO v : this.arrItems) {
        for (int i=0; i<arrBlockWords.length; i++) {
          if (StrUtil.nvl(v.ITEMNAME).contains(arrBlockWords[i])) {
            isContain = true;
            break;
          }
        }
      }
    }
    return isContain;
  }
  
  /**
   * 사업장 소재지가 동일한 거래처간 매매거래인가?
   * <pre>영문자와 한글 이외의 문자를 모두 제거하고 비교</pre>
   * 
   * @return 동일하면 true
   */
  public boolean KD004() {
    this.logger.debug("KD004");
//    String buyer  = StrUtil.nvl(this.buyerVo.CPY_ADDR).trim().replaceAll("[^a-zA-Z0-9가-힣]", "");
//    String seller = StrUtil.nvl(this.sellerVo.CPY_ADDR).trim().replaceAll("[^a-zA-Z0-9가-힣]", "");
    String buyer  = StrUtil.nvl(this.buyerVo.CPY_ADDR + StrUtil.nvl(this.buyerVo.CPY_ADDR2)).trim().replaceAll("[^a-zA-Z0-9가-힣]", "");
    String seller = StrUtil.nvl(this.sellerVo.CPY_ADDR + StrUtil.nvl(this.sellerVo.CPY_ADDR2)).trim().replaceAll("[^a-zA-Z0-9가-힣]", "");
    boolean isDuplicated = buyer.equals(seller);
    if (isDuplicated) { // 동일사업장이상거래예외테이블 조회
      int intBuyer  = Integer.parseInt(StrUtil.nvl(hvo.CPYBUYER, "0"));
      int intSeller = Integer.parseInt(StrUtil.nvl(hvo.CPYSELLER, "0"));
      int intCnt = new RelationCompanyBean().COMPANY_RELATION_EXCEPT_PROC(intBuyer, intSeller);
      if (intCnt>0) return false;
    }
    return isDuplicated;
  }
  
  /**
   * 거래기업간 최근 1년이내 평균 거래금액 대비 3배 초과하고 대출금 전체한도의 50%이상 소진 및 5천만원 이상인 거래인가?
   * 
   * @param limit 대출한도
   * @return 해당되면 true
   */
  public boolean KD005(long limit) {
    this.logger.debug("KD005");
    long lngCurrentTransactionAmt = getTransactionAmt(); // 당거래금액
    if (lngCurrentTransactionAmt>=50000000) { // 당거래금액이 5천만원 이상이고
      if (lngCurrentTransactionAmt > (getRecentContractAmtAvg())[1]*3) { // 평균거래금액의 3배를 초과하고
        if (limit==0 || lngCurrentTransactionAmt > limit*0.5) return true; // 대출한도가 없거나 당거래금액이 대출한도의 50%가 넘으면
      }
    }
    return false;
  }
  
  /**
   * 판매기업의 회사명과 대표자 성명이 동일한가?
   * 
   * @return 동일하면 true
   */
  public boolean KD006() {
    this.logger.debug("KD006");
    String cn  = StrUtil.nvl(this.sellerVo.CPY_NAME).trim();
    String ceo = StrUtil.nvl(this.sellerVo.CPY_CEO_NAME).trim();
    return cn.equals(ceo);
  }
  
  /**
   * 1건의 거래로 대출금 전체 한도의 80%이상 소진하는가?
   * 
   * @param l 대출한도
   * @return 해당되면 true
   */
  public boolean KD007(long limit) {
    this.logger.debug("KD007");
    long lngTransactionAmt = getTransactionAmt();
    this.logger.debug(limit*0.8);
    this.logger.debug(lngTransactionAmt);
    return (lngTransactionAmt >= (limit*0.8));
  }

  /**
   * 판매기업의 당기매출액 대비 2배의 거래건 (단, 6개월 누적거래금액이 1억원 이상)인가?
   * 
   * @return 해당되면 true
   */
  public boolean KD008() {
    this.logger.debug("KD008");
    long lngRevenue = getSellerRevenue(); // 판매사의 당기매출액
    if (lngRevenue<0) return false; // 아직 매출액이 집계되지 않은 기업이면 통과
    long lngTransactionAmt = getTransactionAmt(); // 거래금액
    if (lngTransactionAmt >= lngRevenue*2) { // 거래금액이 당기매출액의 2배 이상이고
      if (getSellerRecentContractAmt()>=100000000) return true; // 6개월 거래금액이 1억이상이면 이상거래
      else return false; // 아니면 통과
    }
    return false;
  }
  
  /**
   * 판매기업의 건별 매매거래금액 2천만원 이상 또는 6개월 누적 매매거래금액 1억원 이상인가?
   * 
   * @return 해당되면 true
   */
  public boolean KD009() {
    this.logger.debug("KD009");
    boolean isAbnormal = false;
    if (getTransactionAmt()>=20000000) isAbnormal = true; // 매매계약금액이 2천만원 이상이면 이상거래
    if (getSellerRecentContractAmt()>=100000000) isAbnormal = true; // 6개월 거래금액이 1억원 이상이면 이상거래
    if (isAbnormal) { // 이상거래에 걸렸더라도
      if (this.sellerVo.SELLER_CLEAR_YN.equals("Y")) return false; // 판매사사전검증으로 차단해제된 판매사이면 통과
      else return true; // 아니면 이상거래
    }
    return isAbnormal;
  }
  
  /**
   * 판매,구매기업이 동일한 법인번호인가?
   *  
   * @return 해당되면 true
   */
  public boolean KD010() {
    this.logger.debug("KD010");
    boolean isAbnormal = false;
    if (this.buyerVo.CRG_ID.equals("2") || this.sellerVo.CRG_ID.equals("2")) isAbnormal = false; // 둘 중 하나가 개인기업이면 통과
    else if (StrUtil.nvl(this.buyerVo.CPY_INCORPORATE_NO).equals(StrUtil.nvl(this.sellerVo.CPY_INCORPORATE_NO))) isAbnormal = true; // 법인번호가 같으면 이상거래
    return isAbnormal;
  }
  
  /**
   * 등록된 판매기업 당기매출액이 없는가? 
   * 
   * @return 해당되면 true
   */
  public boolean KD012() {
    this.logger.debug("KD012");
    this.logger.debug(getSellerRevenue());
    return (getSellerRevenue() == 0); // 판매사의 당기매출이 0이면 이상거래
  }
  
  /**
   * 전자(세금)계산서 상 판매기업 사업자번호와 회원정보가 불일치하는가?
   * <pre>본지사까지 확인해야 한다</pre>
   * @return 불일치하면 true
   */
  public boolean KD013() {
    this.logger.debug("KD013");
    if (this.taxVo==null) return false;
    String tno = StrUtil.nvl(this.taxVo.SCOMP_VENDERNO);
    String no  = StrUtil.nvl(this.sellerVo.CPY_BUSINESS_NO);
    String strBranches = no+this.getBranches(this.sellerVo.CPY_ID);
    this.logger.debug(strBranches);
    this.logger.debug(tno);
    return (!strBranches.contains(tno));
  }
  
  /**
   * 전자(세금)계산서 상 구매기업 사업자번호와 회원정보 일치 여부 (본지사포함)
   * <pre>본지사까지 확인해야 한다</pre>
   * @return 불일치하면 true
   * @return
   */
  public boolean KD014() {
    this.logger.debug("KD014");
    if (this.taxVo==null) return false;
    String tno = StrUtil.nvl(this.taxVo.RCOMP_VENDERNO);
    String no  = StrUtil.nvl(this.buyerVo.CPY_BUSINESS_NO);
    String strBranches = no+this.getBranches(this.buyerVo.CPY_ID);
    this.logger.debug(strBranches);
    this.logger.debug(tno);
    return (!strBranches.contains(tno));
  }
  
  /**
   * 1건의 거래로 대출금 전체 한도의 100%이상 소진하는가?
   * 
   * @param l 대출한도
   * @return 해당되면 true
   */
  public boolean KD015(long limit) {
    this.logger.debug("KD015");
    long lngTransactionAmt = getTransactionAmt();
    this.logger.debug(limit);
    this.logger.debug(lngTransactionAmt);
    return (lngTransactionAmt >= limit);
  }
  /**
   * 판매기업의 당기매출액 대비 100%의 거래건인가?
   * 
   * @return 해당되면 true
   */
  public boolean KD016() {
    this.logger.debug("KD016");
    long lngRevenue = getSellerRevenue(); // 판매사의 당기매출액
    if (lngRevenue<0) return false; // 아직 매출액이 집계되지 않은 기업이면 통과
    long lngTransactionAmt = getTransactionAmt(); // 거래금액
    return (lngTransactionAmt >= lngRevenue); // 거래금액이 당기매출액의 100% 이상
  }
  
  /**
   * 동일 거래일(세금계산서작성일) 단일 거래처에 4건 이상의 계약인가?
   * 
   * @return 해당되면 true
   */
  public boolean KD017() {
    this.logger.debug("KD017");
    int intCnt = AbnormalTransactionDAO.CT_HEADER_CNT_BY_BILL_DT_PROC(Integer.parseInt(this.hvo.CTID));
    return (intCnt > 3);
  }
}
