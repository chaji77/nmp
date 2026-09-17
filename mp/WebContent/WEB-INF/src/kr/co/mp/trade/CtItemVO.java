package kr.co.mp.trade;

import java.util.ArrayList;

public class CtItemVO {
  public String CTID; // 매매계약서아이디
  public String SEQNO; // 일련번호
  public String ITEMNAME; // 품목명
  public String QTY; // 수량
  public String UNITPRICE; // 단가
  public String UNIT; // 단위
  public String SIZE; // 규격
  public String SUPPLYAMT; // 공급가액
  public String TAXAMT; // 세액
  public String TOTALAMT; // 합계금액
  
  public static String setXml(ArrayList<CtItemVO> arr) {
	  StringBuffer sb = new StringBuffer();
	  if (arr!=null && arr.size()>0) {
		  for (CtItemVO v : arr) {
			  sb.append("<NODE ");
			  sb.append("SEQNO=\""+v.SEQNO+"\" ");
			  sb.append("ITEMNAME=\""+((v.ITEMNAME).replaceAll("\"", "").replaceAll("\"", ""))+"\" ");
			  sb.append("QTY=\""+v.QTY+"\" ");
			  sb.append("UNITPRICE=\""+v.UNITPRICE+"\" ");
			  sb.append("UNIT=\""+v.UNIT+"\" ");
			  sb.append("SIZE=\""+v.SIZE+"\" ");
			  sb.append("SUPPLYAMT=\""+v.SUPPLYAMT+"\" ");
			  sb.append("TAXAMT=\""+v.TAXAMT+"\" ");
			  sb.append("TOTALAMT=\""+v.TOTALAMT+"\" />");
		  }
	  }
	  return sb.toString();
  }
  
  @Override
  public String toString() {
	return "CtItemVO [CTID=" + CTID + ", SEQNO=" + SEQNO + ", ITEMNAME=" + ITEMNAME + ", QTY=" + QTY + ", UNITPRICE="
			+ UNITPRICE + ", UNIT=" + UNIT + ", SIZE=" + SIZE + ", SUPPLYAMT=" + SUPPLYAMT + ", TAXAMT=" + TAXAMT
			+ ", TOTALAMT=" + TOTALAMT + "]";
  }
}
