package kr.co.mp.trade;

public class TradeStatusVO {
	public String CTTYPE;
	public String COM_TYPE;
	public String WAIT_TYPE;
	public int    WAIT_COUNT;
	
	@Override
	public String toString() {
		return "TradeStatusVO [CTTYPE=" + CTTYPE + ", COM_TYPE=" + COM_TYPE + ", WAIT_TYPE=" + WAIT_TYPE
				+ ", WAIT_COUNT=" + WAIT_COUNT + "]";
	}
	
	
}
