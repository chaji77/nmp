package kr.co.soap.controll.kibo;

public class Kibo_A311VO {
	//Common Element
	private CommonElement commonElement = new CommonElement();
	
	private String BuyerID = null;
	private String BuyerBusinessNO = null;
	private String SellerID = null;
	private String SellerBusinessNO = null;
	private String SettlementType = null;
	private String SettlementDueAMT = null;
	private String OrgCode = null;
	private String PayId = null;
	
	public void setBuyerID(String p_BuyerID)
	{
		this.BuyerID = p_BuyerID;
	}
	
	public void setBuyerBusinessNO(String p_BuyerBusinessNO)
	{
		this.BuyerBusinessNO = p_BuyerBusinessNO;
	}
	
	public void setSellerID(String p_SellerID)
	{
		this.SellerID = p_SellerID;
	}
	
	public void setSellerBusinessNO(String p_SellerBusinessNO)
	{
		this.SellerBusinessNO = p_SellerBusinessNO;
	}
	
	public void setSettlementType(String p_SettlementType)
	{
		this.SettlementType = p_SettlementType;
	}  
	
	public void setSettlementDueAMT(String p_SettlementDueAMT)
	{
		this.SettlementDueAMT = p_SettlementDueAMT;
	}  
	
	public void setOrgCode(String p_OrgCode)
	{
	    this.OrgCode = p_OrgCode;
	}

	public void setPayId(String p_PayId)
	{
	    this.PayId = p_PayId;
	}
	
	public void setCommonElement(CommonElement p_commonElement)
	{
		this.commonElement = p_commonElement;
	}        
	
     public String getBuyerID()
     {
    	 return this.BuyerID;
     }
     
     public String getBuyerBusinessNO()
     {
    	 return this.BuyerBusinessNO;
     }
     
     public String getSellerID()
     {
    	 return this.SellerID;
     }
     
     public String getSellerBusinessNO()
     {
    	 return this.SellerBusinessNO;
     }
     
     public String getSettlementType()
     {
    	 return this.SettlementType;
     }  
     
     public String getSettlementDueAMT()
     {
    	 return this.SettlementDueAMT;
     }  
     
     public String getOrgCode()
     {
       return this.OrgCode;
     }

     public String getPayId()
     {
       return this.PayId;
     }

     
     public CommonElement getCommonElement()
     {
    	 return this.commonElement;
     }
}
