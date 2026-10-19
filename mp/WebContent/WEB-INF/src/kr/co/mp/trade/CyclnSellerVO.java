package kr.co.mp.trade;

import kr.co.funology.fw.util.FormatUtil;
import kr.co.funology.fw.util.StrUtil;

/** 발주계약서 작성 화면의 판매기업 드롭다운 한 줄. */
public class CyclnSellerVO {
  public int    CPY_ID          = 0;
  public String CPY_NAME        = "";  // 회원사명
  public String CPY_BUSINESS_NO = "";  // 사업자번호. 하이픈 없는 10자리
  public String LAST_TRADEDATE  = "";  // 최근 거래일 yyyyMMdd

  /** 드롭다운에 보일 글자. 같은 상호가 있을 수 있어 사업자번호를 함께 보인다. */
  public String getOptionText() {
    String strBizNo = StrUtil.nvl(this.CPY_BUSINESS_NO).trim();
    if (strBizNo.equals("")) return StrUtil.nvl(this.CPY_NAME);
    return StrUtil.nvl(this.CPY_NAME) + " (" + FormatUtil.addDashBizNo(strBizNo) + ")";
  }
}
