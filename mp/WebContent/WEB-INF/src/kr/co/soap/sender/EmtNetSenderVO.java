package kr.co.soap.sender;

public class EmtNetSenderVO {
	public String xmlGubn;
	public int ctId;
	public int cpyId;
	public String bnkCd;
	public int payId;
	public double amt;
	public String seqNo;
	public String editGubun;

	 // ★ A311S 추가
    public String sellerBizNo;   // 판매기업 사업자번호
    public String sellerCorpNo;  // 판매기업 법인번호

    // ★ C211 추가
    public String applNo;        // 담보보증 신청번호 (INFO_GUARANTEE PK)
    public String creUser;       // 작업자 ID (CREUSER 적재용)

    // ★ B211 추가
    public String orderNo;       // 매매계약 주문번호 (XML_B211 PK)
    public String b211SeqNo;     // 매매계약 일련번호 (기본 001)

    // ★ K231 추가
    public String k231SeqNo;     // 결제전문 상환순번 (기본 001)
}
