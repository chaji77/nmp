package kr.co.soap.controll;

import java.io.File;
import java.io.FileOutputStream;
import java.util.HashMap;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import kr.co.funology.fw.GlobalEnv;
import kr.co.funology.fw.util.DateTimeUtil;
import kr.co.funology.fw.util.XMLEasyUtil;
import kr.co.funology.fw.util.XMLUtil;

public class LoanUtil 
{
	
	SoapCommonBean bean = new SoapCommonBean();
	
	public String getSeqNO_Kodit_xml_b311(String p_orderNo) throws Exception {
		//return bean.GET_MAX_TABLE_PROC("SEND_XML_B311", "SEQNO", "ORDERNO", p_orderNo);
		return getMaxSeqAdd("SEND_XML_B311", "SEQNO", "ORDERNO", p_orderNo, 5);
	}
	
	public String getSeqNO_Kodit_xml_k311(String p_orderNo) throws Exception {
		//return bean.GET_MAX_TABLE_PROC("KODIT_XML_K311", "SEQNO", "ORDERNO", p_orderNo);
		return getMaxSeqAdd("RECEIVE_XML_K311", "SEQNO", "ORDERNO", p_orderNo, 5);
	}
	
	private String getMaxSeqAdd(String strTableNm, String strMaxColumn, String strConditionColumn, String strConditionValue, int intDigit) {
		
		int intSeqNo = 0;
		try {
			intSeqNo = bean.GET_MAX_TABLE_PROC(strTableNm, strMaxColumn, strConditionColumn, strConditionValue);
		} catch(Exception e) {
			e.toString();
		}
		
		return appendLeft(intSeqNo + 1, "0", intDigit);
	}
	
	private String appendLeft(String src, String apchar, int len) {
		int count = len - src.trim().length();
	    for (int i = 0; i < count; i++) {
	      src = apchar.trim() + src.trim();
	    }
	    return src;
	}
	
	private String appendLeft(int src, String apchar, int len) {
	    String str_src = new Integer(src).toString();
	    return appendLeft(str_src, apchar, len);
	}
	
	public int getCtId(String p_orderno) {
		SoapCommonVO.CtHeaderVO ctheaderVO = new SoapCommonVO().new CtHeaderVO();
		
		try {
			ctheaderVO = bean.GET_CT_HEADER_PROC(p_orderno);
		} catch(Exception e) {
			ctheaderVO.CTID = 9999;
			e.printStackTrace();
		}
		
		return ctheaderVO.CTID;
	}
	 
	public static void fileWriteKodit(String xml) {
        try 
        {
            Document doc = XMLEasyUtil.parseXMLDocument(xml);
            String Sender           = XMLUtil.getNodeValue(doc, "sb:Sender");
            String TransactionSEQNO = XMLUtil.getNodeValue(doc, "sb:TransactionSEQNO");
            String Receiver         = XMLUtil.getNodeValue(doc, "sb:Receiver");
            String TransactionNO    = XMLUtil.getNodeValue(doc, "sb:TransactionNO");
            String TransactionDate  = XMLUtil.getNodeValue(doc, "sb:TransactionDate");

            TransactionSEQNO = String.valueOf(Long.parseLong(TransactionSEQNO));
            String path = GlobalEnv.getWebRootDir() + "logfiles/kodit/" + Sender.trim() + "/" + TransactionDate.trim();
            String fileName = TransactionSEQNO +"_"+TransactionNO+"_"+Receiver+".xml";
            LoanUtil.fileWrite(doc, path, fileName);
        }
        catch (Exception e) { }
    }
	
	public static void fileWriteKoditGuarantee(String xml) {
	    try {
	      Document doc = XMLEasyUtil.parseXMLDocument(xml);
	      String Sender = XMLUtil.getNodeValue(doc, "sb:Sender");
	      String TransactionSEQNO = XMLUtil.getNodeValue(doc, "sb:TransactionSEQNO");
	      String Receiver = XMLUtil.getNodeValue(doc, "sb:Receiver");
	      String TransactionNO = XMLUtil.getNodeValue(doc, "sb:TransactionNO");
	      String TransactionDate = XMLUtil.getNodeValue(doc, "sb:TransactionDate");
	      
	      TransactionSEQNO = String.valueOf(Long.parseLong(TransactionSEQNO));
	      String path = String.valueOf(GlobalEnv.getWebRootDir()) + "logfiles/kodit/guarantee/" + DateTimeUtil.getCurrentDate("");
	      String fileName = String.valueOf(TransactionSEQNO) + "_" + TransactionNO + "_" + Receiver + ".xml";
	      fileWrite(doc, path, fileName);
	    } catch (Exception exception) {}
	  }
	
	public static void fileWriteKibo(String xml) {
	    try 
	    {
	    	Document doc = XMLEasyUtil.parseXMLDocument(xml);
	    	String Sender 			= XMLUtil.getNodeValue(doc, "Sender");
	    	String TransactionSEQNO = XMLUtil.getNodeValue(doc, "TransactionSEQNO");
	    	String Receiver 		= XMLUtil.getNodeValue(doc, "Receiver");
	    	String TransactionNO 	= XMLUtil.getNodeValue(doc, "TransactionNO");
	    	String TransactionDate 	= XMLUtil.getNodeValue(doc, "TransactionDate");

	    	TransactionSEQNO = String.valueOf(Long.parseLong(TransactionSEQNO));
	    	String path = GlobalEnv.getWebRootDir() + "logfiles/kibo/" + Sender.trim() + "/" + TransactionDate.trim();
	    	String fileName = TransactionSEQNO + "_" + TransactionNO + "_" + Receiver + ".xml";
	    	LoanUtil.fileWrite(doc, path, fileName);
	    } catch (Exception localException) { }
	}
	
	public static void fileWrite(Document doc, String path, String fileName)
    {
        try {
            File dir = new File(path);
            if(!dir.exists())
                dir.mkdirs();

            File file = new File(dir, fileName);
            FileOutputStream fos = new FileOutputStream(file, true);
            XMLUtil.displayXML(doc, fos);
        }
        catch(Exception exception) { }
    }
	
	public static HashMap<String, String> getXmlData(Document xml) {
	    HashMap<String, String> data = new HashMap<>();
	    NodeList nodes = xml.getElementsByTagName("*"); // 모든 요소 태그 선택
	    
	    for (int i = 0; i < nodes.getLength(); i++) {
	        Node node = nodes.item(i);
	        if (node.getNodeType() == Node.ELEMENT_NODE) {
	            String key = node.getNodeName();
	            String value = node.getTextContent().trim(); // 공백 제거

	            if (!value.isEmpty()) { // 값이 존재할 때만 저장
	                if (data.containsKey(key)) {
	                    data.put(key, data.get(key) + "&" + value); // 기존 값이 있으면 "&"로 결합
	                } else {
	                    data.put(key, value);
	                }
	            }
	        }
	    }
	    return data;
    }
	
    public static void main(String[] args)
    {
    	try
    	{
    	//System.out.println(firstword.substring(14,17));
    	
    	LoanUtil loanUtil = new LoanUtil();
    	
 		System.out.println("EMT012008031200001HO".substring(0, 8));
 		System.out.println("EMT012008031200001HO".substring(13, 18));
 		System.out.println("EMT012008031200001HO".length());
 		//             4000001
 		//             000001
 		//EMT01200803040000001
 		//EMTNETC08021800009KU
    	//System.out.println(commUtil.getNewPayNOServeOne());
    	}
    	catch(Exception ex)
    	{
    	   ex.printStackTrace();
    	}
    }
}
