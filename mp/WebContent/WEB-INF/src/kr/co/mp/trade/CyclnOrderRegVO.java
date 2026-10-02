package kr.co.mp.trade;

import java.util.ArrayList;

/**
 * 싸이클론 발주계약서 등록용 VO.
 * CYCLN_ORDER 한 건(계약기본정보)과 CYCLN_ORDER_ITEM 여러 건(제품정보)을 담는다.
 * 주문번호(ORDERNO)는 동시등록에서도 겹치지 않도록 프로시저가 만든다.
 */
public class CyclnOrderRegVO {
  public int    CPYBUYER      = 0;   // 구매기업 CPY_ID(로그인 회사)
  public int    CPYSELLER     = 0;   // 판매기업 CPY_ID
  public String ORDERNAME     = "";  // 발주계약서명
  public String REQDLVDATE    = "";  // 요청납기일 yyyyMMdd
  public String DLVADDRESS    = "";  // 도착지
  public String ESTIMATE_TYPE = "1"; // 계산서 종류. 1-과세, 2-영세율, 3-면세
  public String CREUSER       = "";  // 작성자 로그인 아이디

  public ArrayList<ItemVO> ITEMS = new ArrayList<ItemVO>();

  /** 제품정보 한 줄 */
  public static class ItemVO {
    public String SEQNO       = "";  // 일련번호 3자리
    public String PRD_TITLE   = "";  // 제품명
    public String UNIT        = "";  // 단위
    public String REQQTY      = "0"; // 요청수량
    public String REQPRICE    = "0"; // 요청단가
    public String SUPPLYAMT   = "0"; // 공급가액
    public String TAXAMT      = "0"; // 세액
    public String TOTALAMT    = "0"; // 총액
    public String DESCRIPTION = "";  // 기타제품사양
  }

  /**
   * 제품정보를 프로시저가 XML 로 읽을 &lt;NODE .../&gt; 문자열로 만든다.
   * 매매계약서(CtItemVO.setXml)와 같은 방식이되, 따옴표를 버리지 않고 XML 로 이스케이프한다.
   */
  public static String setXml(ArrayList<ItemVO> arr) {
    StringBuffer sb = new StringBuffer();
    if (arr!=null) {
      for (ItemVO v : arr) {
        sb.append("<NODE ");
        sb.append("SEQNO=\""       + esc(v.SEQNO)       + "\" ");
        sb.append("PRD_TITLE=\""   + esc(v.PRD_TITLE)   + "\" ");
        sb.append("UNIT=\""        + esc(v.UNIT)        + "\" ");
        sb.append("REQQTY=\""      + esc(v.REQQTY)      + "\" ");
        sb.append("REQPRICE=\""    + esc(v.REQPRICE)    + "\" ");
        sb.append("SUPPLYAMT=\""   + esc(v.SUPPLYAMT)   + "\" ");
        sb.append("TAXAMT=\""      + esc(v.TAXAMT)      + "\" ");
        sb.append("TOTALAMT=\""    + esc(v.TOTALAMT)    + "\" ");
        sb.append("DESCRIPTION=\"" + esc(v.DESCRIPTION) + "\" />");
      }
    }
    return sb.toString();
  }

  /** XML 속성값으로 넣을 수 있게 특수문자를 바꾼다. */
  private static String esc(String s) {
    if (s==null) return "";
    return s.replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;");
  }
}
