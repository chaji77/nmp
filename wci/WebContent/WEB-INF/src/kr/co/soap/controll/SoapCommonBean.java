package kr.co.soap.controll;

public class SoapCommonBean {
	
	private SoapCommonDAO dao;
	
	/**
	 * SoapCommonBean
	 */
	public SoapCommonBean() {
		this.dao = new SoapCommonDAO();
	}
	
	/**
	 * Generating a Sequence for XML
	 * @param strSeqId
	 * @return
	 */
	public String GET_INFO_SEQUENCE_DAILY_NEXTSEQ(String strSeqId) {
		return this.dao.GET_INFO_SEQUENCE_DAILY_NEXTSEQ(strSeqId);
	}
	
	/**
	 * COMPANY_INFO
	 * @param intCpyID
	 * @return
	 */
	public SoapCommonVO.CompanyVO GET_COMPANY_INFO_PROC(int intCpyID) {
		return this.dao.GET_COMPANY_INFO_PROC(intCpyID);
	}
	
	/**
	 * BANK_INFO
	 * @param strBnkCd
	 * @return
	 */
	public SoapCommonVO.BankVO GET_BANK_INFO_PROC(String strBnkCd) {
		return this.dao.GET_BANK_INFO_PROC(strBnkCd);
	}
	
	/**
	 * BANK_PRODUCTS_INFO
	 * @param strMpCode
	 * @param strBnkCd
	 * @param intPayId
	 * @param intTradeType
	 * @return
	 */
	public SoapCommonVO.BankProductsVO GET_BANK_PRODUCTS_INFO_PROC(String strMpCode, String strBnkCd, int intPayId, int intTradeType) {
		return this.dao.GET_BANK_PRODUCTS_INFO_PROC(strMpCode, strBnkCd, intPayId, intTradeType);
	}
	
	/**
	 * CT_HEADER_ETC_INFO
	 * @param intCtId
	 * @return
	 */
	public SoapCommonVO.CtHeaderEtcVO GET_CT_HEADER_ETC_INFO_PROC(int intCtId) {
		return this.dao.GET_CT_HEADER_ETC_INFO_PROC(intCtId);
	}
	
	/**
	 * XML_B311 DATA SET
	 * @param intCtId
	 * @return
	 */
	public SoapCommonVO.XmlB311VO GET_XML_B311_PROC(int intCtId) {
		return this.dao.GET_XML_B311_PROC(intCtId);
	}
	
	public SoapCommonVO GET_XML_B311_ITEM_PROC(int intCtId) {
		return this.dao.GET_XML_B311_ITEM_PROC(intCtId);
	}
	
	/**
	 * TAX_AMT_LIMIT_CHK
	 * @param intCtId
	 * @param strAppNo
	 * @param strGubun
	 * @return
	 */
	public String GET_TAX_MONEY_LIMIT_CHK_PROC(int intCtId, String strAppNo, String strGubun) {
		return this.dao.GET_TAX_MONEY_LIMIT_CHK_PROC(intCtId, strAppNo, strGubun);
	}
	
	/**
	 * (strChkDate add intDays) min biz-date 
	 * @param strChkDate
	 * @param intDays
	 * @return
	 */
	public String GET_BIZ_DATE_PROC(String strChkDate, int intDays, String strBankCode, String strBillDate) {
		return this.dao.GET_BIZ_DATE_PROC(strChkDate, intDays, strBankCode, strBillDate);
	}
	
	public int GET_MAX_TABLE_PROC(String strTableNm, String strMaxCol, String strConditionCol, String strConditionVal) {
		return this.dao.GET_MAX_TABLE_PROC(strTableNm, strMaxCol, strConditionCol, strConditionVal);
	}
	
	public int SEND_XML_B311_ADD_PROC(B311VO vo) {
		return this.dao.SEND_XML_B311_ADD_PROC(vo);
	}
	
	public int SEND_XML_B311_MOD_PROC(SoapCommonVO.SendXmlB311VO vo) {
		return this.dao.SEND_XML_B311_MOD_PROC(vo);
	}
	
	public int SEND_XML_B315_MOD_PROC(SoapCommonVO.SendXmlB311VO vo) {
		return this.dao.SEND_XML_B315_MOD_PROC(vo);
	}
	
	public SoapCommonVO.ReadXmlA181VO GET_XML_A181_PROC(int intCtId, String strSeqNo) {
		return this.dao.GET_XML_A181_PROC(intCtId, strSeqNo);
	}
	
	public SoapCommonVO.CtHeaderVO GET_CT_HEADER_PROC(String strOrderNo) {
		return this.dao.GET_CT_HEADER_PROC(strOrderNo);
	}
	
	public int RECEIVE_XML_K311_ADD_PROC(K311VO xmlK311) {
		return this.dao.RECEIVE_XML_K311_ADD_PROC(xmlK311);
	}
	
	public int RECEIVE_XML_K311_RES_MOD_PROC(K311VO xmlK311) {
		return this.dao.RECEIVE_XML_K311_RES_MOD_PROC(xmlK311);
	}
	
	public int RECEIVE_XML_K311_MOD_PROC(SoapCommonVO.CtHeaderVO vo) {
		return this.dao.RECEIVE_XML_K311_MOD_PROC(vo);
	}
	
	public int RECEIVE_XML_K315_MOD_PROC(SoapCommonVO.CtHeaderVO vo) {
		return this.dao.RECEIVE_XML_K315_MOD_PROC(vo);
	}
	
	public int RECEIVE_XML_K321_MOD_PROC(SoapCommonVO.CtHeaderVO vo) {
		return this.dao.RECEIVE_XML_K321_MOD_PROC(vo);
	}
	
	public String GET_FUND_PROC(int intCtId, String strGubun, int intPayId) {
		return this.dao.GET_FUND_PROC(intCtId, strGubun, intPayId);
	}
}
