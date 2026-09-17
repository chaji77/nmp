package kr.co.soap.controll;

public class A312VO {
	//Common Element
	private CommonElement commonElement = new CommonElement();
	
	private String BuyerID = null;                 // 
	private String BuyerBusinessNO = null;         // 구매기업사업자번호
	private String BuyerB2BMemberYN = null;        // 구매기업B2B결제시스템 회원여부
	private String BuyerSettlementType = null;     // 구매기업결제수단구분 (1.현금(B2B통장대출) 2. B2B구매카드 3. B2B구매론 4.구매자금대출, 5.외상매출채권, 6. B2B일반자금대출
	private String BuyerSettlementMemberYN = null; // 
	private String BankLimitYN = null;             // 한도설정여부
	private String BankLimitAMT = null;	           // 한도설정액
	private String BankLimitSpare = null;          // 한도여유액
	private String BankLimitSpareYN = null;        // 한도여유여부
	private String SellerID = null;                // 
	private String SellerBusinessNO = null;        // 판매기업사업자번호
	private String SellerB2BMemberYN = null;       // 판매기업회원여부
	
	public void setCommonElement(CommonElement p_commonElement) {
    	this.commonElement = p_commonElement;
	}    
	
	public void setBuyerID(String p_BuyerID) {
    	this.BuyerID = p_BuyerID;
	}
	
	public void setBuyerBusinessNO(String p_BuyerBusinessNO)
	{
    	 this.BuyerBusinessNO = p_BuyerBusinessNO;
	}
	
	public void setBuyerB2BMemberYN(String p_BuyerB2BMemberYN)
	{
    	 this.BuyerB2BMemberYN = p_BuyerB2BMemberYN;
	}
	
	public void setBuyerSettlementType(String p_BuyerSettlementType)
	{
    	 this.BuyerSettlementType = p_BuyerSettlementType;
	}
	
	public void setBuyerSettlementMemberYN(String p_BuyerSettlementMemberYN)
	{
    	 this.BuyerSettlementMemberYN = p_BuyerSettlementMemberYN;
	}
	
	public void setBankLimitYN(String p_BankLimitYN)
	{
    	 this.BankLimitYN = p_BankLimitYN;
	}
	
	public void setBankLimitAMT(String p_BankLimitAMT)
	{
    	 this.BankLimitAMT = p_BankLimitAMT;
	}	
	
	public void setBankLimitSpare(String p_BankLimitSpare)
	{
    	 this.BankLimitSpare = p_BankLimitSpare;
	}
	
	public void setBankLimitSpareYN(String p_BankLimitSpareYN)
	{
    	 this.BankLimitSpareYN = p_BankLimitSpareYN;
	}
   
	public void setSellerID(String p_SellerID)
	{
    	 this.SellerID = p_SellerID;
	}
	
	public void setSellerBusinessNO(String p_SellerBusinessNO)
	{
    	 this.SellerBusinessNO = p_SellerBusinessNO;
	}	
	
	public void setSellerB2BMemberYN(String p_SellerB2BMemberYN)
	{
    	 this.SellerB2BMemberYN = p_SellerB2BMemberYN;
	}
	
	//
	public CommonElement getCommonElement()
	{
    	 return this.commonElement;
	}   
	
	public String getBuyerID()
	{
    	 return this.BuyerID;
	}
	
	public String getBuyerBusinessNO()
	{
    	 return this.BuyerBusinessNO;
	}
	
	public String getBuyerB2BMemberYN()
	{
    	 return this.BuyerB2BMemberYN;
	}
	
	public String getBuyerSettlementType()
	{
    	 return this.BuyerSettlementType;
	}  

	public String getBuyerSettlementMemberYN()
	{
    	 return this.BuyerSettlementMemberYN;
	}
	
	public String getBankLimitYN()
	{
    	 return this.BankLimitYN ;
	}
	
	public String getBankLimitAMT()
	{
    	 return this.BankLimitAMT;
	}
   
	public String getBankLimitSpare()
	{
    	 return this.BankLimitSpare;
	}
	
	public String getBankLimitSpareYN()
	{
    	 return this.BankLimitSpareYN;
	}
	
	public String getSellerID()
	{
    	 return this.SellerID;
	}
	
	public String getSellerBusinessNO()
	{
    	 return this.SellerBusinessNO;
	}
	
	public String getSellerB2BMemberYN()
	{
    	 return this.SellerB2BMemberYN;
	}
}
