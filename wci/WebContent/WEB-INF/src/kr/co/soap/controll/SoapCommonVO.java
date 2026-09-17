package kr.co.soap.controll;

import java.util.ArrayList;

import org.apache.poi.ss.usermodel.DateUtil;

public class SoapCommonVO {
	
	public class CompanyVO {
		public int CPY_ID;
		public String CPY_BUSINESS_NO;
		public String CPY_INCORPORATE_NO;
		public String CPY_CEO_NO;
		public String MP_CODE;
	}
	
	public class BankVO {
		public String BNK_CD;
		public String BNK_NAME;
		public String BNK_NO;
		public String BNK_SNAME;
	}
	
	public class BankProductsVO {
		public String MPCODE;
		public String BNK_CD;
		public int PAY_ID;
		public String TRADETYPE;
		public String LIMITYN;
		public String SETTLEMENTTYPE;
		public String USERFIELD;
	}
	
	public class CtHeaderVO {
		public int CTID;
		public String CTNO;
		public int CPYBUYER;
		public String STATUS;
		public String BNKCD;
		public String SETTLEDATE;
		public int SETTLEMENTSTATUS;
		public int MPFEE_TOTALAMT;
	}
	
	public class CtHeaderEtcVO {
		public int CTID;
		public String CU_USE_YN;
		public String TAX_SECTION;
		public String BUYER_IP;
		public String SELLER_IP;
		public String BUYER_SGN_ID;
		public String BUYER_SGN_DATE;
		public String SELLER_SGN_ID;
		public String SELLER_SGN_DATE;
		public String SELLER_APP_SGN_ID;
		public String SELLER_APP_SGN_DATE;
		public String APP_TYPE;
	}
	
	public class XmlB311VO {
		public int CTID;
		public String CTNO;
		public String DIRTYPE;
		public String TRADEDATE;
		public String CONTRACTDATE;
		public int CPYBUYER;
		public String CPYBUYER_BIZNO;
		public String CPYBUYER_INCORPORATE_NO;
		public String MP_CODE;
		public int CPYSELLER;
		public int CPYSELLER_CRG_ID;
		public String CPYSELLER_NM;
		public String CPYSELLER_BIZNO;
		public String CPYSELLER_INCORPORATE_NO;
		public String TAXBIZTYPE;
		public String TOTALCONTRACTAMT;
		public String MPPAYCPY;
		public String MPFEE_TOTALAMT;		
		public String BNK_CD;
		public String BNK_NO;
		public String MTYDATE;
		public String CONTRACT_STATUS;
		public String SETTLEAMT;
		public String SETTLEDUEDATE;
		public String CONFIRM_SETTLE_YN;
		public String TAXAPPROVALNO;
		public int PAY_ID;
		public String TAXISSUEYN;
		public String PAYMENTAPPROVALTYPE;
		public String PAYMENTAPPROVALTYPEYN;
		public String EXPIRATIONDATEYN;
		public String PAYMENTDUEDATEYN;
		public int SETTLEMENTDUEDAYS;
		public String USERFIELD;
		public String FEETRANSFERYN;
		public String HANDACCEPTYN;
		public String TRADETYPE;
		public String SETTLEMENTTYPE;
		public String PAYMENTDUEDAYS;
		public String SBILL_SEQ;
		public String BILL_NO;
		public String BILL_DT;
		public String PAY_SUM_AMOUNT;
		public String TOTALAMT;
		//public String CT_ITEM_XML;
		public String ITEM_TOTALAMT;
		public String PRS_LOGIN;
		public String APRUSER;
		public String APPRTIME;
	}
	
	public class XmlB311ItemVO {
		public int CTID;
		public String SEQNO;
		public String ITEMNAME;
        public double QTY;
        public double UNITPRICE;
        public String UNIT;
        public String SIZE;
        public int SUPPLYAMT;
        public int TAXAMT;
        public int TOTALAMT;
	}
	
	public SoapCommonVO.XmlB311ItemVO mainItem;
	public ArrayList<SoapCommonVO.XmlB311ItemVO> allItems;
	
	public class SendXmlB311VO {
		public int CTID; 
		public String ORDERNO;
		public String FUND;
		public String SEQNO;
		public String RECEIVER;
		public String TRANSACTIONSEQNO;
		public String TRANSACTIONNO;
		public String TRANSACTIONDATE;
		public String TRANSACTIONTIME;
		public String RESPONSECODE;
		public String RESPONSEMSG;
		public String RESRESPONSECODE;
		public String RESRESPONSEMSG;
		public String STATUS;
		
		public String CANUSER;
		public String CANTIME;
		
		public String CONTRACTDATE;
		public String TRADEDATE;
		public String SETTLEDUEDATE;
	}
	
	public class ReadXmlA181VO {
		public int CTID;
		public String CTNO; 
		public String ORDERNO;
		public String RECEIVER;
		public String TRANSACTIONSEQNO;
		public String TRANSACTIONNO;
		public String TRANSACTIONDATE;
		public String TRANSACTIONTIME;
		public String MP_CODE;
		public String USERFIELD;
	}
	
	public class MastOffCommissonVO {
		public int CPY_ID;
		public int SEQNO; 
		public String START_DT;
		public String END_DT;
		public int COMM_ID;
		public String COMM_METHOD;
		public String MAX_YN;
	}
	
	public class GetFundVO {
		public int CTID;
		public int CTNO;
		public String FUND;
	}
}
