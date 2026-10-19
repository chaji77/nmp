package kr.co.mp.trade;

import kr.co.mp.common.CommonVO;

public class CyclnOrderVO extends CommonVO {
  public String ORDERNO;      // 주문번호
  public String TRADEDATE;    // 거래일
  public String ORDERNAME;    // 주문명
  public String REQDLVDATE;   // 납기요청일
  public String BC_NAME;      // 구매사명
  public String SC_NAME;      // 판매사명
  public String PURC_PRIC;    // 구매금액(CL080)
  public String FEE_RATE;     // 수수료율(CL090)
  public String SETL_PLN_YMD; // 결제예정일(CL090)
  public String TAX_ISSU_YMD; // 세금계산서발행일(CL090)
  public String MTR_YMD;      // 만기일(CL100)
  public String SETL_PLN_PRIC;// 결제예정금액(CL090)
  public String SETL_PRIC;    // 실결제금액(CL100)
  public String STATUS;       // 주문상태(CYCLN_ORDER.STATUS)
  public String TRX_CLS;      // 거래구분(CL100.TRX_CLS) 1-결제, 2-취소
  public String CQ090_STATUS; // 결제예정전문 처리상태(CYCLN_QUEUE.STATUS). 은행접수 단계
  public String CQ100_STATUS; // 결제상태(CYCLN_QUEUE.STATUS)
  public String REGTIME;      // 등록일시(CYCLN_ORDER.CRETIME)
  public String PAYTIME;      // 결제일시(CYCLN_SETTLE.CRETIME)
  public String CODE_NM;      // 상태 표시명(CYCLN_ORDER_STATUS)
  public String TMSG_FAIL_YN; // 마지막 CL080·CL090 전문발송 실패 여부(Y/N)

  /* 마지막 CL080·CL090 이 실패했을 때 상태 표시명 뒤에 붙이는 문구 */
  public static final String TMSG_FAIL_SUFFIX = " 전문발송 실패";

  /* 거래 진행에 쓰는 상태코드. 전체 목록은 아래 ORDER_STATUS 에 있다. */
  public static final String STATUS_BUYER_CHGREQ  = "020"; // 구매사 변경요청. 승인 뒤에도 이 상태로 남아 다음 단계로 간다
  public static final String STATUS_SELLER_CHGREQ = "025"; // 판매사 변경요청
  public static final String STATUS_SELLER_CANREQ = "030"; // 판매사 취소요청. 이 상태에서는 더 진행하지 않는다
  public static final String STATUS_BUYER_CANREQ  = "035"; // 구매사 취소요청
  public static final String STATUS_CONFIRMED     = "050"; // 판매기업 승인(확정)
  public static final String STATUS_BUYER_CANCEL  = "090"; // 구매사 취소
  public static final String STATUS_SELLER_CANCEL = "095"; // 판매사 취소

  /* 전문 거래구분. CL080/CL090 이 같은 값을 쓴다. */
  public static final String TRX_REGIST = "01";
  public static final String TRX_CHANGE = "02";
  public static final String TRX_CANCEL = "03";

  /* 거래당사자 구분. 같은 상태코드라도 구매사/판매사 화면의 표시명이 다르다. */
  public static final String ROLE_BUYER  = "B";
  public static final String ROLE_SELLER = "S";
  /* 구매·판매 구분 없이 한 회사의 거래를 모두 본다. 관리자 회원별 거래화면용. */
  public static final String ROLE_ALL    = "A";

  /* FOR SEARCH */
  public String STATUS_CD       = ""; // 화면에서 고른 단일 상태코드
  public String STATUS1         = ""; // 주문상태 조건
  public String STATUS2         = ""; // 결제상태 조건('NUL'이면 전문 없는 건만)
  public String STATUS3         = ""; // 은행접수 조건('NUL'이면 전문 없는 건만)
  public String TRX_CLS_COND    = ""; // 거래구분 조건
  public String ORDERNO_COND    = ""; // 주문번호 검색어
  public String TRADEDATE_START = "";
  public String TRADEDATE_END   = "";
  public int    BC_ID           = 0;
  public int    SC_ID           = 0;
  public int    CPY_ID          = 0;  // 거래당사자 화면의 로그인 회사
  public String STATUS_COND     = ""; // 주문상태 코드 조건(ORDER_STATUS 의 코드)
  public String CPY_NAME_COND   = ""; // 거래상대 기업명 검색어
  public String ROLE            = ROLE_BUYER; // 조회 기준. ROLE_BUYER-발주계약서, ROLE_SELLER-납품내역관리, ROLE_ALL-전체

  /**
   * 화면 드롭다운용 상태 정의. 거래가 나아가는 순서대로 적는다.
   * {상태코드, 표시명, STATUS1, STATUS2, TRX_CLS, STATUS3}
   *   STATUS1 : CYCLN_ORDER.STATUS
   *   STATUS2 : 결제전문(CL100)의 CYCLN_QUEUE.STATUS
   *   TRX_CLS : CYCLN_CL100.TRX_CLS
   *   STATUS3 : 결제예정전문(CL090)의 CYCLN_QUEUE.STATUS
   * STATUS2·STATUS3 의 'NUL' 은 그 전문이 없는 건을, 빈값은 조건으로 보지 않음을 뜻한다.
   */
  public static final String[][] STATUS_FILTERS = {
      {"CT", "발주계약서 작성", "010", "NUL", "",   ""   }
    , {"OC", "발주 취소",       "090", "NUL", "",   ""   }
    , {"DC", "납품 취소",       "095", "NUL", "",   ""   }
    , {"DF", "납품 확정",       "050", "NUL", "",   "NUL"}
    , {"BK", "은행접수",        "050", "NUL", "",   "2"  }
    , {"PD", "결제 완료",       "050", "2",   "01", ""   }
    , {"PC", "결제 취소",       "050", "2",   "02", ""   }
  };

  /**
   * 검색 드롭다운용 상태코드 목록. {상태코드, 표시명}
   * 표시명은 CYCLN_ORDER_STATUS 가 갖고 있지만, 검색조건 목록까지 조회하기는 과해서
   * 코드 목록만 여기 둔다. 조회결과 한 건의 표시명은 프로시저의 CODE_NM 을 쓴다.
   */
  public static final String[][] ORDER_STATUS = {
      {"010", "승인대기"    }
    , {"020", "구매사 변경요청"}
    , {"025", "판매사 변경요청"}
    , {"030", "판매사 취소요청"}
    , {"035", "구매사 취소요청"}
    , {"050", "확정"        }
    , {"090", "구매사 취소"  }
    , {"095", "판매사 취소"  }
  };

  /**
   * 결제예정전문(CL090)이 나간 뒤 결제통보(CL100)가 오기 전까지 보일 단계명.
   * {CYCLN_QUEUE.STATUS, 표시명}
   */
  public static final String[][] BANK_STEP_NM = {
      {"0", "은행접수중"  }
    , {"1", "은행접수중"  }
    , {"2", "은행접수"    }
    , {"9", "은행접수실패"}
  };

  /** 조회결과 한 건의 상태 표시명. 프로시저가 준 CODE_NM 에 전문 상태를 덮어쓴다. */
  public String getOrderStatusNm() {
    return getOrderStatusNm(this.CODE_NM, this.STATUS, this.CQ090_STATUS, this.CQ100_STATUS, this.TRX_CLS, this.TMSG_FAIL_YN);
  }

  /**
   * 전문 상태 표시명 뒤에, 마지막 CL080·CL090 이 실패했으면 '전문발송 실패' 를 붙인다.
   *
   * @param strFailYn 프로시저가 준 TMSG_FAIL_YN
   */
  public static String getOrderStatusNm(String strCodeNm, String strStatus,
                                        String strQ090, String strQ100, String strTrxCls, String strFailYn) {
    return getOrderStatusNm(strCodeNm, strStatus, strQ090, strQ100, strTrxCls)
         + ("Y".equals(strFailYn) ? TMSG_FAIL_SUFFIX : "");
  }

  /**
   * 전문 상태까지 반영한 거래당사자 화면용 표시명.
   *
   * 거래는 발주 → 확정 → 은행접수(CL090) → 결제완료(CL100) 순으로 나아간다.
   * CYCLN_ORDER_STATUS 에는 전문 단계가 없어서 뒤쪽 단계부터 덮어쓴다.
   *   1) 결제전문이 있으면 결제 정의(STATUS_FILTERS)
   *   2) 없고 결제예정전문이 있으면 은행접수 단계(BANK_STEP_NM)
   *   3) 둘 다 없으면 프로시저가 준 CYCLN_ORDER_STATUS 의 표시명
   *
   * @param strCodeNm  프로시저가 준 CODE_NM(역할에 맞는 BCNAME/SCNAME)
   * @param strStatus  CYCLN_ORDER.STATUS
   * @param strQ090    CL090 전문의 CYCLN_QUEUE.STATUS. 전문이 없으면 빈값
   * @param strQ100    CL100 전문의 CYCLN_QUEUE.STATUS. 전문이 없으면 빈값
   * @param strTrxCls  CYCLN_CL100.TRX_CLS
   */
  public static String getOrderStatusNm(String strCodeNm, String strStatus,
                                        String strQ090, String strQ100, String strTrxCls) {
    String strCode = (strStatus==null) ? "" : strStatus.trim();
    // 취소요청은 결제예정전문 취소가 나가 있어도 취소요청으로 보인다.
    if (strCode.equals(STATUS_SELLER_CANREQ) || strCode.equals(STATUS_BUYER_CANREQ)) {
      String strBase = oneLine(strCodeNm);
      return strBase.equals("") ? strCode : strBase;
    }
    if (strQ100!=null && !strQ100.trim().equals("")) {
      // 변경을 거친 건(020·025)도 결제 단계는 확정(050) 건과 같게 보인다.
      boolean isChanged = strCode.equals(STATUS_BUYER_CHGREQ) || strCode.equals(STATUS_SELLER_CHGREQ);
      String strNm = matchStatusFilter(isChanged ? STATUS_CONFIRMED : strStatus, strQ100, strTrxCls);
      if (strNm!=null) return strNm;
    } else {
      String strNm = matchBankStep(strQ090);
      if (strNm!=null) return strNm;
    }
    String strBase = oneLine(strCodeNm);
    if (!strBase.equals("")) return strBase;
    return (strStatus==null) ? "" : strStatus.trim(); // 상태코드 정의가 없는 건
  }

  /** 조회결과 한 건의 상태 글자색. */
  public String getOrderStatusColor() {
    return getOrderStatusColor(this.STATUS, this.CQ100_STATUS, this.TRX_CLS);
  }

  /**
   * 상태 글자색. 목록과 상세가 같이 쓴다.
   *   빨강 - 취소요청(030·035). 승인 뒤 취소 전문이 나간 건
   *   검정 - 취소(090·095). 전문이 나가기 전에 취소한 건. 결제취소도 여기
   *   초록 - 결제완료
   *   파랑 - 그 밖의 진행 중인 건(발주계약서 등록, 변경요청, 납품확정, 은행접수 등)
   *
   * @param strStatus CYCLN_ORDER.STATUS
   * @param strQ100   CL100 전문의 CYCLN_QUEUE.STATUS. 전문이 없으면 빈값
   * @param strTrxCls CYCLN_CL100.TRX_CLS
   */
  public static String getOrderStatusColor(String strStatus, String strQ100, String strTrxCls) {
    String strCode = (strStatus==null) ? "" : strStatus.trim();
    String strQueue = (strQ100==null) ? "" : strQ100.trim();
    String strTrx = (strTrxCls==null) ? "" : strTrxCls.trim();
    if (strCode.equals(STATUS_SELLER_CANREQ) || strCode.equals(STATUS_BUYER_CANREQ)) return "red";
    if (strCode.equals(STATUS_BUYER_CANCEL)  || strCode.equals(STATUS_SELLER_CANCEL)) return "black";
    if (strQueue.equals("2") && strTrx.equals("01")) return "green";
    if (strQueue.equals("2") && strTrx.equals("02")) return "black";
    return "blue";
  }

  /** 결제예정전문의 큐 상태에 맞는 단계명. 전문이 없으면 null. */
  private static String matchBankStep(String strQ090) {
    String strQueue = (strQ090==null) ? "" : strQ090.trim();
    if (strQueue.equals("")) return null;
    for (String[] f : BANK_STEP_NM) {
      if (f[0].equals(strQueue)) return f[1];
    }
    return null;
  }

  /**
   * CYCLN_ORDER_STATUS 의 표시명을 한 줄로 편다.
   * DB 값이 '구매사 <BR>발주상태' 처럼 줄바꿈 앞뒤에 공백을 갖고 있어 공백도 하나로 줄인다.
   */
  private static String oneLine(String strNm) {
    if (strNm==null) return "";
    return strNm.replaceAll("(?i)<br\\s*/?>", " ").replaceAll("\\s+", " ").trim();
  }

  /**
   * STATUS_FILTERS 에서 한 건에 맞는 정의를 찾아 표시명을 돌려준다. 없으면 null.
   */
  private static String matchStatusFilter(String strStatus, String strQueue, String strTrxCls) {
    strStatus = (strStatus==null) ? "" : strStatus.trim();
    strQueue  = (strQueue==null)  ? "" : strQueue.trim();
    strTrxCls = (strTrxCls==null) ? "" : strTrxCls.trim();
    for (String[] f : STATUS_FILTERS) {
      if (!f[2].equals(strStatus)) continue;
      if (f[3].equals("NUL")) { if (!strQueue.equals("")) continue; }
      else                    { if (!f[3].equals(strQueue)) continue; }
      if (!f[4].equals("") && !f[4].equals(strTrxCls)) continue;
      return f[1];
    }
    return null;
  }

  /**
   * 화면에서 넘어온 단일 상태코드를 STATUS1 / STATUS2 / TRX_CLS 조건으로 쪼갠다.
   * 정의에 없는 값이면 전체조회로 둔다.
   */
  public void setStatusCd(String strStatusCd) {
    this.STATUS_CD    = (strStatusCd==null) ? "" : strStatusCd.trim();
    this.STATUS1      = "";
    this.STATUS2      = "";
    this.STATUS3      = "";
    this.TRX_CLS_COND = "";
    for (String[] f : STATUS_FILTERS) {
      if (f[0].equals(this.STATUS_CD)) {
        this.STATUS1      = f[2];
        this.STATUS2      = f[3];
        this.TRX_CLS_COND = f[4];
        this.STATUS3      = f[5];
        return;
      }
    }
    this.STATUS_CD = "";
  }

}
