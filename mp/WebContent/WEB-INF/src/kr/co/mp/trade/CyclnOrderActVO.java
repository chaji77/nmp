package kr.co.mp.trade;

/**
 * 발주계약서 처리(승인·수정·취소)용 VO.
 *
 * 프로시저는 넘어온 값을 쓰기만 하므로, 누가 무엇을 할 수 있는지와 어떤 상태로 가야 하는지는
 * 이 VO 를 채우는 쪽(화면 처리 JSP)에서 정한다. 비어 있는 값은 프로시저가 건드리지 않는다.
 */
public class CyclnOrderActVO {
  public String ORDERNO       = "";  // 매매계약번호
  public int    CPY_ID        = 0;   // 처리하는 회사. 거래당사자여야 한다
  public String USERID        = "";  // 처리자 로그인 아이디
  public String STATUS_NOW    = "";  // 화면이 본 상태. 그 사이 바뀌었으면 프로시저가 거른다
  public String STATUS_CF     = "";  // 바꿀 상태. 비우면 상태는 그대로 둔다
  public String ITEM_XML      = "";  // 제품정보 <NODE .../> 묶음. 비우면 제품은 그대로 둔다
  public String DLV_ITEM_XML  = "";  // 승인 뒤 변경요청의 납품 제품정보. SEQNO 로 줄을 맞춰 금액만 고친다

  /* 계약정보. 수정할 때만 채운다. */
  public String ORDERNAME     = "";
  public String REQDLVDATE    = "";  // yyyyMMdd
  public String DLVADDRESS    = "";
  public String ESTIMATE_TYPE = "";  // 1-과세, 2-영세율, 3-면세

  /* 전문에 실을 값. CL080 / CL090 을 보낼 때 채운다. */
  public String TRX_CLS       = CyclnOrderVO.TRX_REGIST; // 01-등록, 02-변경, 03-취소
  public String PURC_ITEM     = "";  // 대표품목
  public String PURC_PRIC     = "";  // 매매금액. 자리수를 채우지 않은 숫자문자열

  /* CL090(결제예정정보)에만 쓴다. */
  public String SETL_PLN_PRIC = "";  // 결제예정금액
  public String SETL_PLN_YMD  = "";  // 결제예정일 yyyyMMdd
  public String TAX_ISSU_YMD  = "";  // 세금계산서 발행일 yyyyMMdd
}
