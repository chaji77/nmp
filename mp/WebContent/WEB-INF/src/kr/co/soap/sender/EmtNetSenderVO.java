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
}
