package kr.co.mp.trade;

import kr.co.mp.common.CommonVO;

public class UnusualTransactionVO extends CommonVO {
	public String SEQ; // SEQ
	public String SECTION; // 이상거래 구분
	public String CTNO; // 매매계약번호
	public String CPYBUYER; // 구매사ID
	public String CPYSELLER; // 판매사ID
	public String CONTENT; // 이상거래내용
	public String WRITETIME; // 작성시간
	public String PAY_ID; // 상품코드
	public String USE_YN; // 정상사용가능여부
	public String USE_TIME; // 정상사용승인시간
	public String USE_ID; // 정상처리자
	public String PRO_RESULT; // 처리내역
	public String CTID; // 매매계약ID
	
	
	public String SBILL_SEQ; // 거래용세금계산서아이디
	public String BNK_CD;
	public String BUYER_NM;
	public String BUYER_BIZ_NO;
	public String SELLER_NM;
	public String SELLER_BIZ_NO;
}
