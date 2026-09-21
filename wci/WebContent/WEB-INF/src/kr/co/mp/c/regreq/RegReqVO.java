package kr.co.mp.c.regreq;

import java.util.LinkedHashMap;
import java.util.Map;

import kr.co.mp.common.CommonVO;

public class RegReqVO extends CommonVO {

	public int    SEQ;
	public int    BUY_CPY_ID;
	public String SELL_CPY_NAME;
	public String SELL_PHONE;
	public String SELL_PRS_NAME;
	public String SELL_FAX;
	public String SELL_EMAIL;
	public String SELL_CPY_BUSINESS_NO;
	public String TRADE_DATE;
	public int    FEE_PAY;
	public String MEMO;
	public int    REQ_STATUS;
	public String REG_DATE;
	public String DEL_DATE;

	public String BUY_CPY_NAME;

	// 목록조회 검색조건
	public String START_DATE;
	public String END_DATE;
	public String SEARCH_NM;

	private static final Map<Integer, String> REQ_STATUS_MAP = new LinkedHashMap<>();
	static {
		REQ_STATUS_MAP.put(1, "등록완료");
		REQ_STATUS_MAP.put(2, "안내완료");
		REQ_STATUS_MAP.put(3, "가입완료");
	}

	public static Map<Integer, String> getReqStatusMap() {
		return REQ_STATUS_MAP;
	}

	public static String getReqStatusLabel(int status) {
		String label = REQ_STATUS_MAP.get(status);
		return (label != null) ? label : String.valueOf(status);
	}

	private static final Map<Integer, String> FEE_PAY_MAP = new LinkedHashMap<>();
	static {
		FEE_PAY_MAP.put(1, "구매기업");
		FEE_PAY_MAP.put(2, "판매기업");
	}

	public static Map<Integer, String> getFeePayMap() {
		return FEE_PAY_MAP;
	}

	public static String getFeePayLabel(int feePay) {
		String label = FEE_PAY_MAP.get(feePay);
		return (label != null) ? label : "";
	}

	@Override
	public String toString() {
		return "RegReqVO {" +
				"SEQ=" + SEQ +
				", BUY_CPY_ID=" + BUY_CPY_ID +
				", SELL_CPY_NAME='" + SELL_CPY_NAME + '\'' +
				", SELL_PHONE='" + SELL_PHONE + '\'' +
				", SELL_PRS_NAME='" + SELL_PRS_NAME + '\'' +
				", SELL_FAX='" + SELL_FAX + '\'' +
				", SELL_EMAIL='" + SELL_EMAIL + '\'' +
				", SELL_CPY_BUSINESS_NO='" + SELL_CPY_BUSINESS_NO + '\'' +
				", TRADE_DATE='" + TRADE_DATE + '\'' +
				", FEE_PAY=" + FEE_PAY +
				", MEMO='" + MEMO + '\'' +
				", REQ_STATUS=" + REQ_STATUS +
				", REG_DATE='" + REG_DATE + '\'' +
				", DEL_DATE='" + DEL_DATE + '\'' +
				'}';
	}
}
