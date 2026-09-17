package kr.co.soap.controll;

import java.sql.Connection;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConnectionMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;
import kr.co.mp.c.PersonVO;

public class SoapCommonDAO {
	
	protected String GET_INFO_SEQUENCE_DAILY_NEXTSEQ(String strSeqId) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
				
	    WrapPreparedStatementUtil ps = null;
	    Logger logger = Logger.getLogger(this.getClass());
	    ResultSet rs = null;
	    String strNextSeqNo = "";
	    try {
	      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.GET_INFO_SEQUENCE_DAILY_NEXTSEQ ?;");
	      int i = 0;
	      ps.setString(++i, StrUtil.getParameter(StrUtil.nvl(strSeqId), "", 3));
	      logger.debug(ps.getQueryString());
	      rs = ps.executeQuery();
	      if (rs!=null && rs.next()) {
	    	  strNextSeqNo = rs.getString("GENERATED_ID");
	      }
	    } catch (Exception e) {
	      logger.error(ps.getQueryString());
	      logger.error(e.toString());
	    } finally {
	    	ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
	    }
	    return strNextSeqNo;
	}
	
	protected SoapCommonVO.CompanyVO GET_COMPANY_INFO_PROC(int intCpyID) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
				
	    WrapPreparedStatementUtil ps = null;
	    Logger logger = Logger.getLogger(this.getClass());
	    ResultSet rs = null;
	    
	    SoapCommonVO.CompanyVO companyVO = null; // 반환할 객체 선언
	    
	    try {
	      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.GET_COMPANY_INFO_PROC ?;");
	      int i = 0;
	      ps.setInt(++i, intCpyID);
	      logger.debug(ps.getQueryString());
	      rs = ps.executeQuery();
	      if (rs!=null && rs.next()) {
	    	  companyVO = new SoapCommonVO().new CompanyVO();
	    	  companyVO.CPY_ID 			= rs.getInt("CPY_ID");
	    	  companyVO.CPY_BUSINESS_NO = rs.getString("CPY_BUSINESS_NO");
	    	  companyVO.CPY_INCORPORATE_NO = rs.getString("CPY_INCORPORATE_NO");
	    	  companyVO.CPY_CEO_NO 		= rs.getString("CPY_CEO_NO");
	    	  companyVO.MP_CODE 		= rs.getString("MP_CODE");
	      }
	    } catch (Exception e) {
	      logger.error(ps.getQueryString());
	      logger.error(e.toString());
	    } finally {
	    	ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
	    }
	    return companyVO;
	}
	
	protected SoapCommonVO.BankVO GET_BANK_INFO_PROC(String strBnkCd) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
				
	    WrapPreparedStatementUtil ps = null;
	    Logger logger = Logger.getLogger(this.getClass());
	    ResultSet rs = null;
	    
	    SoapCommonVO.BankVO bankVO = null;
	    
	    try {
	      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.GET_BANK_INFO_PROC ?;");
	      int i = 0;
	      ps.setString(++i, strBnkCd);
	      logger.debug(ps.getQueryString());
	      rs = ps.executeQuery();
	      if (rs!=null && rs.next()) {
	    	  bankVO = new SoapCommonVO().new BankVO();
	    	  bankVO.BNK_CD 	= rs.getString("BNK_CD");
	    	  bankVO.BNK_NAME 	= rs.getString("BNK_NAME");
	    	  bankVO.BNK_NO 	= rs.getString("BNK_NO");
	    	  bankVO.BNK_SNAME 	= rs.getString("BNK_SNAME");
	      }
	    } catch (Exception e) {
	      logger.error(ps.getQueryString());
	      logger.error(e.toString());
	    } finally {
	    	ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
	    }
	    return bankVO;
	}
	
	protected SoapCommonVO.BankProductsVO GET_BANK_PRODUCTS_INFO_PROC(String strMpCode, String strBnkCd, int intPayId, int intTradeType) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
				
	    WrapPreparedStatementUtil ps = null;
	    Logger logger = Logger.getLogger(this.getClass());
	    ResultSet rs = null;
	    
	    SoapCommonVO.BankProductsVO bankProducts = null;
	    
	    try {
	      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.GET_BANK_PRODUCTS_INFO_PROC ?, ?, ?, ?;");
	      int i = 0;
	      ps.setString(++i, strMpCode);
	      ps.setString(++i, strBnkCd);
	      ps.setInt(++i, intPayId);
	      ps.setInt(++i, intTradeType);
	      logger.debug(ps.getQueryString());
	      rs = ps.executeQuery();
	      if (rs!=null && rs.next()) {
	    	  bankProducts = new SoapCommonVO().new BankProductsVO();
	    	  bankProducts.MPCODE 	 = rs.getString("MPCODE");
	    	  bankProducts.BNK_CD 	 = rs.getString("BNK_CD");
	    	  bankProducts.PAY_ID 	 = rs.getInt("PAY_ID");
	    	  bankProducts.TRADETYPE = rs.getString("TRADETYPE");
	    	  bankProducts.LIMITYN 	 = rs.getString("LIMITYN");
	    	  bankProducts.SETTLEMENTTYPE = rs.getString("SETTLEMENTTYPE");
	    	  bankProducts.USERFIELD 	  = rs.getString("USERFIELD");
	      }
	    } catch (Exception e) {
	      logger.error(ps.getQueryString());
	      logger.error(e.toString());
	    } finally {
	    	ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
	    }
	    return bankProducts;
	}
	
	protected SoapCommonVO.CtHeaderEtcVO GET_CT_HEADER_ETC_INFO_PROC(int intCtId) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		 
	    WrapPreparedStatementUtil ps = null;
	    Logger logger = Logger.getLogger(this.getClass());
	    ResultSet rs = null;
	    
	    SoapCommonVO.CtHeaderEtcVO CtHeaderEtcVO = null;
	    
	    try {
	      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.GET_CT_HEADER_ETC_INFO_PROC ?;");
	      int i = 0;
	      ps.setInt(++i, intCtId);
	      logger.debug(ps.getQueryString());
	      rs = ps.executeQuery();
	      if (rs!=null && rs.next()) {
	    	  CtHeaderEtcVO = new SoapCommonVO().new CtHeaderEtcVO();
	    	  CtHeaderEtcVO.CTID 	 		 	= rs.getInt("CTID");
	    	  CtHeaderEtcVO.CU_USE_YN 	 		= rs.getString("CU_USE_YN");
	    	  CtHeaderEtcVO.TAX_SECTION 	 	= rs.getString("TAX_SECTION");
	    	  CtHeaderEtcVO.BUYER_IP 	 		= rs.getString("BUYER_IP");
	    	  CtHeaderEtcVO.SELLER_IP 	 		= rs.getString("SELLER_IP");
	    	  CtHeaderEtcVO.BUYER_SGN_ID 	 	= rs.getString("BUYER_SGN_ID");
	    	  CtHeaderEtcVO.BUYER_SGN_DATE 	 	= rs.getString("BUYER_SGN_DATE");
	    	  CtHeaderEtcVO.SELLER_SGN_ID 	 	= rs.getString("SELLER_SGN_ID");
	    	  CtHeaderEtcVO.SELLER_SGN_DATE 	= rs.getString("SELLER_SGN_DATE");
	    	  CtHeaderEtcVO.SELLER_APP_SGN_ID 	= rs.getString("SELLER_APP_SGN_ID");
	    	  CtHeaderEtcVO.SELLER_APP_SGN_DATE = rs.getString("SELLER_APP_SGN_DATE");
	    	  CtHeaderEtcVO.APP_TYPE 	 		= rs.getString("APP_TYPE");
	      }
	    } catch (Exception e) {
	      logger.error(ps.getQueryString());
	      logger.error(e.toString());
	    } finally {
	    	ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
	    	
	    }
	    return CtHeaderEtcVO;
	}
	
	protected SoapCommonVO.XmlB311VO GET_XML_B311_PROC(int intCtId) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		 
	    WrapPreparedStatementUtil ps = null;
	    Logger logger = Logger.getLogger(this.getClass());
	    ResultSet rs = null;
	    
	    SoapCommonVO.XmlB311VO xmlB311VO = null;
	    
	    try {
	      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.GET_XML_B311_PROC ?;");
	      int i = 0;
	      ps.setInt(++i, intCtId);
	      logger.debug(ps.getQueryString());
	      rs = ps.executeQuery();
	      if (rs!=null && rs.next()) {
	    	  xmlB311VO = new SoapCommonVO().new XmlB311VO();
	    	  xmlB311VO.CTID 	 		 = rs.getInt("CTID");
	    	  xmlB311VO.CTNO 	 		 = rs.getString("CTNO");
	    	  xmlB311VO.DIRTYPE 	 	 = rs.getString("DIRTYPE");
	    	  xmlB311VO.TRADEDATE 		 = rs.getString("TRADEDATE");
	    	  xmlB311VO.CONTRACTDATE	 = rs.getString("CONTRACTDATE");
	    	  xmlB311VO.CPYBUYER 		 = rs.getInt("CPYBUYER");
	    	  xmlB311VO.CPYBUYER_BIZNO	 = rs.getString("CPYBUYER_BIZNO");
	    	  xmlB311VO.CPYBUYER_INCORPORATE_NO = rs.getString("CPYBUYER_INCORPORATE_NO");
	    	  xmlB311VO.MP_CODE 		 = rs.getString("MP_CODE");
	    	  xmlB311VO.CPYSELLER 		 = rs.getInt("CPYSELLER");
	    	  xmlB311VO.CPYSELLER_CRG_ID = rs.getInt("CPYSELLER_CRG_ID");
	    	  xmlB311VO.CPYSELLER_NM 	 = rs.getString("CPYSELLER_NM");
	    	  xmlB311VO.CPYSELLER_BIZNO  = rs.getString("CPYSELLER_BIZNO");
	    	  xmlB311VO.CPYSELLER_INCORPORATE_NO = rs.getString("CPYSELLER_INCORPORATE_NO");
	    	  xmlB311VO.TAXBIZTYPE 		 = rs.getString("TAXBIZTYPE");
	    	  xmlB311VO.TOTALCONTRACTAMT = rs.getString("TOTALCONTRACTAMT");
	    	  xmlB311VO.MPPAYCPY 	 	 = rs.getString("MPPAYCPY");
	    	  xmlB311VO.MPFEE_TOTALAMT 	 = rs.getString("MPFEE_TOTALAMT");
	    	  xmlB311VO.BNK_CD 	 		 = rs.getString("BNK_CD");
	    	  xmlB311VO.BNK_NO 	 		 = rs.getString("BNK_NO");
	    	  xmlB311VO.MTYDATE 	 	 = rs.getString("MTYDATE");
	    	  xmlB311VO.CONTRACT_STATUS  = rs.getString("CONTRACT_STATUS");
	    	  xmlB311VO.SETTLEAMT 	 	 = rs.getString("SETTLEAMT");
	    	  xmlB311VO.SETTLEDUEDATE 	 = rs.getString("SETTLEDUEDATE");
	    	  xmlB311VO.CONFIRM_SETTLE_YN = rs.getString("CONFIRM_SETTLE_YN");
	    	  xmlB311VO.TAXAPPROVALNO 	 = rs.getString("TAXAPPROVALNO");
	    	  xmlB311VO.PAY_ID 	 		 = rs.getInt("PAY_ID");
	    	  xmlB311VO.TAXISSUEYN 	 		  = rs.getString("TAXISSUEYN");
	    	  xmlB311VO.PAYMENTAPPROVALTYPE   = rs.getString("PAYMENTAPPROVALTYPE");
	    	  xmlB311VO.PAYMENTAPPROVALTYPEYN = rs.getString("PAYMENTAPPROVALTYPEYN");
	    	  xmlB311VO.EXPIRATIONDATEYN 	  = rs.getString("EXPIRATIONDATEYN");
	    	  xmlB311VO.PAYMENTDUEDATEYN 	  = rs.getString("PAYMENTDUEDATEYN");
	    	  xmlB311VO.SETTLEMENTDUEDAYS 	  = rs.getInt("SETTLEMENTDUEDAYS");
	    	  xmlB311VO.USERFIELD 	  		  = rs.getString("USERFIELD");
	    	  xmlB311VO.FEETRANSFERYN 	  	  = rs.getString("FEETRANSFERYN");
	    	  xmlB311VO.HANDACCEPTYN 	  	  = rs.getString("HANDACCEPTYN");
	    	  xmlB311VO.TRADETYPE 	  	  	  = rs.getString("TRADETYPE");
	    	  xmlB311VO.SETTLEMENTTYPE		  = rs.getString("SETTLEMENTTYPE");
	    	  xmlB311VO.PAYMENTDUEDAYS		  = rs.getString("PAYMENTDUEDAYS");
	    	  xmlB311VO.SBILL_SEQ 	 	 	  = rs.getString("SBILL_SEQ");
	    	  xmlB311VO.BILL_NO 	 	  	  = rs.getString("BILL_NO");
	    	  xmlB311VO.BILL_DT 	 	  	  = rs.getString("BILL_DT");
	    	  xmlB311VO.PAY_SUM_AMOUNT 	 	  = rs.getString("PAY_SUM_AMOUNT");
	    	  xmlB311VO.TOTALAMT 	 	  	  = rs.getString("TOTALAMT");
	    	  //xmlB311VO.CT_ITEM_XML 	 	  = rs.getString("CT_ITEM_XML");
	    	  xmlB311VO.ITEM_TOTALAMT 	 	  = rs.getString("ITEM_TOTALAMT");
	    	  xmlB311VO.PRS_LOGIN 	 	 	  = rs.getString("PRS_LOGIN");
	    	  xmlB311VO.APRUSER 	 	 	  = rs.getString("APRUSER");
	    	  xmlB311VO.APPRTIME 	 	 	  = rs.getString("APPRTIME");
	      }
	    } catch (Exception e) {
	      logger.error(ps.getQueryString());
	      logger.error(e.toString());
	    } finally {
	    	ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
	    	
	    }
	    return xmlB311VO;
	}
	
	protected SoapCommonVO GET_XML_B311_ITEM_PROC(int intCtId) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		
	    WrapPreparedStatementUtil ps = null;
	    Logger logger = Logger.getLogger(this.getClass());
	    ResultSet rs = null;
	    
	    ArrayList<SoapCommonVO.XmlB311ItemVO> allItems = new ArrayList<>();
	    SoapCommonVO.XmlB311ItemVO mainItem = null;
	    
	    try {
	      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.GET_XML_B311_ITEM_PROC ?;");
	      int i = 0;
	      ps.setInt(++i, intCtId);
	      logger.debug(ps.getQueryString());
	      rs = ps.executeQuery();
	      if (rs!=null) {
	    	  while (rs.next()) {
	    		  SoapCommonVO.XmlB311ItemVO xmlB311ItemVO = new SoapCommonVO().new XmlB311ItemVO();
		    	  xmlB311ItemVO.CTID 	 	= rs.getInt("CTID");
		    	  xmlB311ItemVO.SEQNO 	 	= rs.getString("SEQNO");
		    	  xmlB311ItemVO.ITEMNAME 	= rs.getString("ITEMNAME");
		    	  xmlB311ItemVO.QTY 		= rs.getDouble("QTY");
		    	  xmlB311ItemVO.UNITPRICE	= rs.getDouble("UNITPRICE");
		    	  xmlB311ItemVO.UNIT 		= rs.getString("UNIT");
		    	  xmlB311ItemVO.SIZE	 	= rs.getString("SIZE");
		    	  xmlB311ItemVO.SUPPLYAMT 	= rs.getInt("SUPPLYAMT");
		    	  xmlB311ItemVO.TAXAMT 		= rs.getInt("TAXAMT");
		    	  xmlB311ItemVO.TOTALAMT 	= rs.getInt("TOTALAMT");
		    	  allItems.add(xmlB311ItemVO);
		    	  
		    	  // SEQNO가 "001"인 아이템을 MAIN 아이템으로 설정
	              if ("001".equals(xmlB311ItemVO.SEQNO)) {
	            	  mainItem = xmlB311ItemVO;
	              }
	    	  }
	      }
	    } catch (Exception e) {
	      logger.error(ps.getQueryString());
	      logger.error(e.toString());
	    } finally {
	    	ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
	    }
	    
	    SoapCommonVO vo = new SoapCommonVO();
	    vo.mainItem = mainItem;
	    vo.allItems = allItems;
	    
	    return vo;
	}
	
	protected String GET_TAX_MONEY_LIMIT_CHK_PROC(int intCtId, String strAppNo, String strGubun) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
				
	    WrapPreparedStatementUtil ps = null;
	    Logger logger = Logger.getLogger(this.getClass());
	    ResultSet rs = null;
	    
	    String strTotAmt = "";
	    
	    try {
	      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.GET_TAX_MONEY_LIMIT_CHK_PROC ?, ?, ?;");
	      int i = 0;
	      ps.setInt(++i, intCtId);
	      ps.setString(++i, strAppNo);
	      ps.setString(++i, strGubun);
	      logger.debug(ps.getQueryString());
	      rs = ps.executeQuery();
	      if (rs!=null && rs.next()) {
	    	  strTotAmt = rs.getString("TOTALCONTRACTAMT");
	      }
	    } catch (Exception e) {
	      logger.error(ps.getQueryString());
	      logger.error(e.toString());
	    } finally {
	    	ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
	    }
	    return strTotAmt;
	}
	
	protected String GET_BIZ_DATE_PROC(String strChkDate, int intDays, String strBankCode, String strBillDate) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		 
	    WrapPreparedStatementUtil ps = null;
	    Logger logger = Logger.getLogger(this.getClass());
	    ResultSet rs = null;
	    
	    String strNextDate = "";
	    
	    try {
	      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.GET_BIZ_DATE_PROC ?, ?, ?, ?;");
	      int i = 0;
	      ps.setString(++i, strChkDate);
	      ps.setInt(++i, intDays);
	      ps.setString(++i, strBankCode);
	      ps.setString(++i, strBillDate);
	      logger.debug(ps.getQueryString());
	      rs = ps.executeQuery();
	      if (rs!=null && rs.next()) {
	    	  strNextDate = rs.getString("NEXTBIZDAY");
	      }
	    } catch (Exception e) {
	      logger.error(ps.getQueryString());
	      logger.error(e.toString());
	    } finally {
	    	ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
	    }
	    return strNextDate;
	}
	
	protected int GET_MAX_TABLE_PROC(String strTableNm, String strMaxCol, String strConditionCol, String strConditionVal) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		 
	    WrapPreparedStatementUtil ps = null;
	    Logger logger = Logger.getLogger(this.getClass());
	    ResultSet rs = null;
	    
	    int strMaxValue = 0;
	    
	    try {
	      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.GET_MAX_TABLE_PROC ?, ?, ?, ?;");
	      int i = 0;
	      ps.setString(++i, strTableNm);
	      ps.setString(++i, strMaxCol);
	      ps.setString(++i, strConditionCol);
	      ps.setString(++i, strConditionVal);
	      logger.debug(ps.getQueryString());
	      rs = ps.executeQuery();
	      if (rs!=null && rs.next()) {
	    	  strMaxValue = rs.getInt("MAX_VALUE");
	      }
	    } catch (Exception e) {
	      logger.error(ps.getQueryString());
	      logger.error(e.toString());
	    } finally {
	    	ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
	    }
	    return strMaxValue;
	}
	
	protected int SEND_XML_B311_ADD_PROC(B311VO vo) {
		System.out.println("SEND_XML_B311_ADD_PROC .....");
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		 
	    WrapPreparedStatementUtil ps = null;
	    Logger logger = Logger.getLogger(this.getClass());
	    ResultSet rs = null;
	    int intResult = 0;
	    try {
	      String q = "";
	      for (int a=0; a<13; a++) {
	        q += ", ?";
	      }
	      q = q.substring(1);
	      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.SEND_XML_B311_ADD_PROC "+ q +";");
	      int i = 0;
	      ps.setInt(   ++i, vo.getCtId());
	      ps.setString(++i, StrUtil.getParameter(vo.getOrderNO(), "", 20));
	      ps.setString(++i, StrUtil.getParameter(vo.getFund(), "", 5));
	      ps.setString(++i, StrUtil.getParameter(vo.getSeqNO(), "", 5));
	      ps.setString(++i, StrUtil.getParameter(vo.getReceiver(), "", 7));
	      ps.setString(++i, StrUtil.getParameter(vo.getTransactionSEQNO(), "", 5));
	      ps.setString(++i, StrUtil.getParameter(vo.getTransactionNO(), "", 4));
	      ps.setString(++i, StrUtil.getParameter(vo.getTransactionDate(), "0", 8));
	      ps.setString(++i, StrUtil.getParameter(vo.getTransactionTime(), "0", 6));
	      ps.setString(++i, StrUtil.getParameter(vo.getResponseCode(), "0", 4));
	      ps.setString(++i, StrUtil.getParameter(vo.getResponseMessage(), "0", 500));
	      ps.setString(++i, StrUtil.getParameter(vo.getResResponseCode(), "0", 4));
	      ps.setString(++i, StrUtil.getParameter(vo.getResResponseMessage(), "0", 500));
	      logger.debug(ps.getQueryString());
	      ps.executeUpdate();
	    } catch (Exception e) {
	      logger.error(ps.getQueryString());
	      logger.error(e.toString());
	      intResult = -1;
	    } finally {
	    	ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
	    }
	    return intResult;
	}
	
	protected int SEND_XML_B311_MOD_PROC(SoapCommonVO.SendXmlB311VO vo) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		 
	    WrapPreparedStatementUtil ps = null;
	    Logger logger = Logger.getLogger(this.getClass());
	    ResultSet rs = null;
	    int intResult = 0;
	    try {
	      String q = "";
	      for (int a=0; a<10; a++) {
	        q += ", ?";
	      }
	      q = q.substring(1);
	      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.SEND_XML_B311_MOD_PROC "+ q +";");
	      int i = 0;
	      ps.setInt(   ++i, vo.CTID);
	      ps.setString(++i, StrUtil.getParameter(vo.STATUS, "", 3));
	      ps.setString(++i, StrUtil.getParameter(vo.SEQNO, "", 5));
	      ps.setString(++i, StrUtil.getParameter(vo.FUND, "", 5));
	      ps.setString(++i, StrUtil.getParameter(vo.RESRESPONSECODE, "", 4));
	      ps.setString(++i, StrUtil.getParameter(vo.RESRESPONSEMSG, "", 500));
	      
	      ps.setString(++i, StrUtil.getParameter(vo.CONTRACTDATE, "", 8));
	      ps.setString(++i, StrUtil.getParameter(vo.TRADEDATE, "", 8));
	      ps.setString(++i, StrUtil.getParameter(vo.SETTLEDUEDATE, "", 8));
	      
	      ps.setString(++i, StrUtil.getParameter(vo.TRANSACTIONNO, "", 4));
	      
	      logger.debug(ps.getQueryString());
	      rs = ps.executeQuery();
	      if (rs!=null && rs.next()) {
	    	  intResult = rs.getInt("RESULT");
	      }
	    } catch (Exception e) {
	      logger.error(ps.getQueryString());
	      logger.error(e.toString());
	      intResult = -1;
	    } finally {
	    	ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
	    }
	    return intResult;
	}
	
	protected int SEND_XML_B315_MOD_PROC(SoapCommonVO.SendXmlB311VO vo) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		 
	    WrapPreparedStatementUtil ps = null;
	    Logger logger = Logger.getLogger(this.getClass());
	    ResultSet rs = null;
	    int intResult = 0;
	    try {
	      String q = "";
	      for (int a=0; a<8; a++) {
	        q += ", ?";
	      }
	      q = q.substring(1);
	      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.SEND_XML_B315_MOD_PROC "+ q +";");
	      int i = 0;
	      ps.setInt(   ++i, vo.CTID);
	      ps.setString(++i, StrUtil.getParameter(vo.STATUS, "", 3));
	      ps.setString(++i, StrUtil.getParameter(vo.SEQNO, "", 5));
	      ps.setString(++i, StrUtil.getParameter(vo.FUND, "", 5));
	      ps.setString(++i, StrUtil.getParameter(vo.RESRESPONSECODE, "", 4));
	      ps.setString(++i, StrUtil.getParameter(vo.RESRESPONSEMSG, "", 500));
	      ps.setString(++i, StrUtil.getParameter(vo.CANUSER, "", 30));
	      ps.setString(++i, StrUtil.getParameter(vo.CANTIME, "", 14));
	      logger.debug(ps.getQueryString());
	      rs = ps.executeQuery();
	      if (rs!=null && rs.next()) {
	    	  intResult = rs.getInt("RESULT");
	      }
	    } catch (Exception e) {
	      logger.error(ps.getQueryString());
	      logger.error(e.toString());
	      intResult = -1;
	    } finally {
	    	ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
	    }
	    return intResult;
	}
	
	protected SoapCommonVO.ReadXmlA181VO GET_XML_A181_PROC(int intCtId, String strSeqNo) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		 
	    WrapPreparedStatementUtil ps = null;
	    Logger logger = Logger.getLogger(this.getClass());
	    ResultSet rs = null;
	    
	    SoapCommonVO.ReadXmlA181VO readXmlA181VO = null;
	    
	    try {
	      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.GET_XML_A181_PROC ?, ?;");
	      int i = 0;
	      ps.setInt(++i, intCtId);
	      ps.setString(++i, strSeqNo);
	      logger.debug(ps.getQueryString());
	      rs = ps.executeQuery();
	      if (rs!=null && rs.next()) {
	    	  readXmlA181VO = new SoapCommonVO().new ReadXmlA181VO();
	    	  readXmlA181VO.CTID 	 		 = rs.getInt("CTID");
	    	  readXmlA181VO.CTNO 	 		 = rs.getString("CTNO");
	    	  readXmlA181VO.RECEIVER 	 	 = rs.getString("RECEIVER");
	    	  readXmlA181VO.TRANSACTIONSEQNO = rs.getString("TRANSACTIONSEQNO");
	    	  readXmlA181VO.TRANSACTIONNO	 = rs.getString("TRANSACTIONNO");
	    	  readXmlA181VO.TRANSACTIONDATE  = rs.getString("TRANSACTIONDATE");
	    	  readXmlA181VO.TRANSACTIONTIME	 = rs.getString("TRANSACTIONTIME");
	    	  readXmlA181VO.MP_CODE	 		 = rs.getString("MP_CODE");
	    	  readXmlA181VO.USERFIELD 		 = rs.getString("USERFIELD");
	      }
	    } catch (Exception e) {
	      logger.error(ps.getQueryString());
	      logger.error(e.toString());
	    } finally {
	    	ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
	    }
	    return readXmlA181VO;
	}
	
	/**
	 * CTNO => FIND CTID
	 * @param vo
	 * @return
	 */
	protected SoapCommonVO.CtHeaderVO GET_CT_HEADER_PROC(String strOrderNo) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		
	    WrapPreparedStatementUtil ps = null;
	    Logger logger = Logger.getLogger(this.getClass());
	    ResultSet rs = null;
	    
	    SoapCommonVO.CtHeaderVO ctHeaderVO = null;
	    
	    try {
	      
	    	ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.GET_CT_HEADER_PROC ?;");
	    	ps.setString(1, strOrderNo);
	    	logger.debug(ps.getQueryString());
	    	rs = ps.executeQuery();
	    	if (rs!=null && rs.next()) {
	    		ctHeaderVO = new SoapCommonVO().new CtHeaderVO();
	    		ctHeaderVO.CTID = rs.getInt("CTID");
	    		ctHeaderVO.CTNO = rs.getString("CTNO");
	    		ctHeaderVO.CPYBUYER = rs.getInt("CPYBUYER");
	    		ctHeaderVO.BNKCD = rs.getString("BNK_CD");
	    		//ctHeaderVO.SETTLEMENTSTATUS = rs.getInt("SETTLEMENTSTATUS");
	    		ctHeaderVO.MPFEE_TOTALAMT = rs.getInt("MPFEE_TOTALAMT");
	    		ctHeaderVO.STATUS = rs.getString("STATUS");
	    	}
	    } catch (Exception e) {
	    	logger.error(ps.getQueryString());
	    	logger.error(e.toString());
	    } finally {
	    	ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
	    }
	    return ctHeaderVO;
	}
	
	
	
	public int RECEIVE_XML_K311_ADD_PROC(K311VO xmlK311) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		 
	    WrapPreparedStatementUtil ps = null;
	    Logger logger = Logger.getLogger(this.getClass());
	    ResultSet rs = null;
	    int intResult = 0;
	    try {
	      String q = "";
	      for (int a=0; a<21; a++) {
	        q += ", ?";
	      }
	      q = q.substring(1);
	      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.RECEIVE_XML_K311_ADD_PROC "+ q +";");
	      int i = 0;
	      
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getOrderno(), "", 20));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getSeqno(), "", 5));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getFund(), "", 5));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getSender(), "", 7));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getTransactionseqno(), "", 5));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getReceiver(), "", 7));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getTransactionno(), "", 4));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getTradedate(), "", 8));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getTransactiontime(), "", 6));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getResponsecode(), "", 4));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getResponsemessage(), "", 39));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getUserfield(), "", 39));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getTradedate(), "", 8));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getContractdate(), "", 8));
	      ps.setInt(++i, xmlK311.getSettlementdueamt());
	      ps.setInt(++i, xmlK311.getSettlementamt());
	      ps.setInt(++i, xmlK311.getPaymentamt());
	      ps.setInt(++i, xmlK311.getRefundamt());
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getSettlementduedate(), "", 8));
	      ps.setInt(++i, xmlK311.getBuyerfee());
	      ps.setInt(++i, xmlK311.getSellerfee());
	      /*
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getRessender(), "", 20));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getRestransactionseqno(), "", 20));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getResreceiver(), "", 20));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getRestransactionno(), "", 20));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getRestransactiondate(), "", 20));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getResuserfield(), "", 20));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getRestransactiontime(), "", 20));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getResresponsecode(), "", 20));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getResresponsemessage(), "", 20));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getResorderno(), "", 20));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getRescontractdate(), "", 20));
	      */
	      
	      logger.debug(ps.getQueryString());
	      rs = ps.executeQuery();
	      if (rs!=null && rs.next()) {
	    	  intResult = rs.getInt("RESULT");
	      }
	    } catch (Exception e) {
	      logger.error(ps.getQueryString());
	      logger.error(e.toString());
	      intResult = -1;
	    } finally {
	    	ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
	    }
	    return intResult;
	}
	
	public int RECEIVE_XML_K311_RES_MOD_PROC(K311VO xmlK311) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		 
	    WrapPreparedStatementUtil ps = null;
	    Logger logger = Logger.getLogger(this.getClass());
	    ResultSet rs = null;
	    int intResult = 0;
	    try {
	      String q = "";
	      for (int a=0; a<14; a++) {
	        q += ", ?";
	      }
	      q = q.substring(1);
	      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.RECEIVE_XML_K311_RES_MOD_PROC "+ q +";");
	      int i = 0;
	      
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getOrderno(), "", 20));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getSeqno(), "", 5));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getFund(), "", 5));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getRessender(), "", 7));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getRestransactionseqno(), "", 5));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getResreceiver(), "", 7));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getRestransactionno(), "", 4));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getRestransactiondate(), "", 8));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getResuserfield(), "", 39));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getRestransactiontime(), "", 6));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getResresponsecode(), "", 4));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getResresponsemessage(), "", 150));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getResorderno(), "", 20));
	      ps.setString(++i, StrUtil.getParameter(xmlK311.getRescontractdate(), "", 8));
	      
	      logger.debug(ps.getQueryString());
	      rs = ps.executeQuery();
	      if (rs!=null && rs.next()) {
	    	  intResult = rs.getInt("RESULT");
	      }
	    } catch (Exception e) {
	      logger.error(ps.getQueryString());
	      logger.error(e.toString());
	      intResult = -1;
	    } finally {
	    	ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
	    }
	    return intResult;
	}
	
	protected int RECEIVE_XML_K311_MOD_PROC(SoapCommonVO.CtHeaderVO vo) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		 
	    WrapPreparedStatementUtil ps = null;
	    Logger logger = Logger.getLogger(this.getClass());
	    ResultSet rs = null;
	    int intResult = 0;
	    try {
	      String q = "";
	      for (int a=0; a<5; a++) {
	        q += ", ?";
	      }
	      q = q.substring(1);
	      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.RECEIVE_XML_K311_MOD_PROC "+ q +";");
	      int i = 0;
	      ps.setInt(   ++i, vo.CTID);
	      ps.setString(++i, StrUtil.getParameter(vo.CTNO, "", 20));
	      ps.setInt(++i, vo.SETTLEMENTSTATUS);
	      ps.setInt(++i, vo.CPYBUYER);
	      ps.setInt(++i, vo.MPFEE_TOTALAMT);
	      logger.debug(ps.getQueryString());
	      rs = ps.executeQuery();
	      if (rs!=null && rs.next()) {
	    	  intResult = rs.getInt("RESULT");
	      }
	    } catch (Exception e) {
	      logger.error(ps.getQueryString());
	      logger.error(e.toString());
	      intResult = -1;
	    } finally {
	    	ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
	    }
	    return intResult;
	}
	
	protected int RECEIVE_XML_K315_MOD_PROC(SoapCommonVO.CtHeaderVO vo) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		 
	    WrapPreparedStatementUtil ps = null;
	    Logger logger = Logger.getLogger(this.getClass());
	    ResultSet rs = null;
	    int intResult = 0;
	    try {
	      String q = "";
	      for (int a=0; a<5; a++) {
	        q += ", ?";
	      }
	      q = q.substring(1);
	      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.RECEIVE_XML_K315_MOD_PROC "+ q +";");
	      int i = 0;
	      ps.setInt(   ++i, vo.CTID);
	      ps.setString(++i, StrUtil.getParameter(vo.CTNO, "", 20));
	      ps.setInt(++i, vo.SETTLEMENTSTATUS);
	      ps.setInt(++i, vo.CPYBUYER);
	      ps.setString(++i, vo.BNKCD);
	      logger.debug(ps.getQueryString());
	      rs = ps.executeQuery();
	      if (rs!=null && rs.next()) {
	    	  intResult = rs.getInt("RESULT");
	      }
	    } catch (Exception e) {
	      logger.error(ps.getQueryString());
	      logger.error(e.toString());
	      intResult = -1;
	    } finally {
	    	ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
	    }
	    return intResult;
	}
	
	protected int RECEIVE_XML_K321_MOD_PROC(SoapCommonVO.CtHeaderVO vo) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
				
	    WrapPreparedStatementUtil ps = null;
	    Logger logger = Logger.getLogger(this.getClass());
	    ResultSet rs = null;
	    int intResult = 0;
	    try {
	      String q = "";
	      for (int a=0; a<2; a++) {
	        q += ", ?";
	      }
	      q = q.substring(1);
	      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.RECEIVE_XML_K321_MOD_PROC "+ q +";");
	      int i = 0;
	      ps.setInt(   ++i, vo.CTID);
	      ps.setString(++i, vo.STATUS);
	      logger.debug(ps.getQueryString());
	      rs = ps.executeQuery();
	      if (rs!=null && rs.next()) {
	    	  intResult = rs.getInt("RESULT");
	      }
	    } catch (Exception e) {
	      logger.error(ps.getQueryString());
	      logger.error(e.toString());
	      intResult = -1;
	    } finally {
	    	ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
	    }
	    return intResult;
	}
	
	protected String GET_FUND_PROC(int intCtId, String strGubun, int intPayId) {
		Connection conn = ConnectionMgr.getInstance().getConnetion();
		 
	    WrapPreparedStatementUtil ps = null;
	    Logger logger = Logger.getLogger(this.getClass());
	    ResultSet rs = null;
	    
	    String strFund = "";
	    
	    try {
	      ps = new WrapPreparedStatementUtil(conn, "EXEC DBO.GET_FUND_PROC ?, ?, ?;");
	      int i = 0;
	      ps.setInt(++i, intCtId);
	      ps.setString(++i, strGubun);
	      ps.setInt(++i, intPayId);
	      logger.debug(ps.getQueryString());
	      rs = ps.executeQuery();
	      if (rs!=null && rs.next()) {
	    	  strFund = rs.getString("FUND");
	      }
	    } catch (Exception e) {
	      logger.error(ps.getQueryString());
	      logger.error(e.toString());
	    } finally {
	    	ConnectionMgr.getInstance().closeConnection(conn, ps, rs);
	    }
	    return strFund;
	}
	
	public static void main(String[] args) {
		/*
		SoapCommonVO vo = new SoapCommonBean().GET_XML_B311_ITEM_PROC(11);
		System.out.println(vo.mainItem.ITEMNAME);
		System.out.println(vo.allItems);
		*/
		System.out.println(StrUtil.cutString("강장공장공장장은간공장장공장장공장장공장장공장장이다.", 10, ""));
		
		/*
		String itemnm = "";
		ArrayList<SoapCommonVO.XmlB311ItemVO> arr = new SoapCommonBean().GET_XML_B311_ITEM_PROC(11);
		if(arr != null && arr.size() > 0) {
			for (int i=0; i<arr.size(); i++) {
				SoapCommonVO.XmlB311ItemVO xmlb311Itemvo = (SoapCommonVO.XmlB311ItemVO)arr.get(0);
				if("001".equals(xmlb311Itemvo.SEQNO)) {
					itemnm = xmlb311Itemvo.ITEMNAME;
					break;
				}
			}
		}
		
		System.out.println("itemnm : " + itemnm);
		*/
		//System.out.println("::" + StrUtil.nvl(dao.GET_TAX_MONEY_LIMIT_CHK_PROC(1, "", ""),"0"));
	}
}
