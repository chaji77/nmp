package kr.co.mp.trade;

/** CL120(한도조회) 응답 한 줄. 응답 전이면 STATUS 만 채워진다. */
public class CyclnLimitVO {
  public static final String STATUS_DONE = "2";  // 응답수신
  public static final String STATUS_FAIL = "9";  // 전송실패

  public String STATUS    = "";  // 0-전송대기, 1-전송중, 2-응답수신, 9-전송실패
  public String RESP_CD   = "";  // 응답코드
  public String RES_MSG   = "";  // 응답메시지
  public String TRX_CLS   = "";  // 거래구분. 1-일반
  public String NEW_YMD   = "";  // 신규일 yyyy-MM-dd
  public String MTR_YMD   = "";  // 만기일 yyyy-MM-dd
  public long   LIMIT_AMT = 0L;  // 약정한도
  public long   LOAN_AMT  = 0L;  // 대출잔액
  public long   SPARE_AMT = 0L;  // 한도여유액
  public String ETC       = "";  // 끝 16자리. 무엇인지 아직 확인하지 못했다

  /** 거래구분 이름. 일반 외의 코드는 아직 확인하지 못해 코드를 그대로 보인다. */
  public String getTrxClsName() {
    return "1".equals(this.TRX_CLS) ? "일반" : this.TRX_CLS;
  }
}
