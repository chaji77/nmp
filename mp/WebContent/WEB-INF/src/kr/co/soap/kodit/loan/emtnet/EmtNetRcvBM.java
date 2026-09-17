package kr.co.soap.kodit.loan.emtnet;

import java.util.HashMap;

import org.w3c.dom.Document;

import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.XMLUtil;
import kr.co.soap.controll.CommonElement;
import kr.co.soap.controll.LoanUtil;
import kr.co.soap.kodit.loan.Kodit_K3XX;

public class EmtNetRcvBM {
	
    public String receiveBM(Document resultXML, HashMap<String, String> ht) {
    	
        String resSchema = "";
        String resBody = null;
        String responseXml = "";
        Kodit_K3XX kXX = null;
        //Document resultXML = null;
        CommonElement commonRCV = new CommonElement();
        CommonElement commonElement = new CommonElement();
        
        try {
            commonRCV.setSender(ht.get("sb:Sender"));
            commonRCV.setTransactionSEQNO(ht.get("sb:TransactionSEQNO"));
            commonRCV.setTransactionNO(ht.get("sb:TransactionNO").substring(0, 4));
            commonRCV.setReceiver(ht.get("sb:Receiver"));
            commonRCV.setTransactionDate(ht.get("sb:TransactionDate"));
            commonRCV.setTransactionTime(ht.get("sb:TransactionTime"));
            commonRCV.setUserField(ht.getOrDefault("sb:UserField", ""));

            
            System.out.println("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
            System.out.println(ht.get("sb:Sender"));
            System.out.println(ht.get("sb:TransactionSEQNO"));
            System.out.println(ht.get("sb:TransactionNO").substring(0, 4));
            System.out.println(ht.get("sb:Receiver"));
            System.out.println(ht.get("sb:TransactionDate"));
            System.out.println(ht.get("sb:Sender"));
            System.out.println(ht.get("sb:UserField"));
            System.out.println("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
            
            
            switch (commonRCV.getTransactionNO()) {
                case "K311":
                    resBody = "Response";
                    kXX = new EmtNetK311(resultXML);
                    ((EmtNetK311) kXX).executeK311();
                    resSchema = ((EmtNetK311) kXX).getResSchema();
                    commonElement = kXX.getResCommonElement();
                    break;
                case "K315":
                    resBody = "Response";
                    kXX = new EmtNetK315(resultXML);
                    ((EmtNetK315) kXX).executeK315();
                    resSchema = ((EmtNetK315) kXX).getResSchema();
                    commonElement = kXX.getResCommonElement();
                    break;
                case "K321":
                    resBody = "Response";
                    kXX = new EmtNetK321(resultXML);
                    ((EmtNetK321) kXX).executeK321();
                    resSchema = ((EmtNetK321) kXX).getResSchema();
                    commonElement = kXX.getResCommonElement();
                    break;
                default:
                    throw new IllegalArgumentException("Unsupported Transaction Type: " + commonRCV.getTransactionNO());
            }
            
            System.out.println("k3xx responseCode : " + commonElement.getResponseCode() + " msg : " + commonElement.getResponseMessage());
            kXX.updateDBWithResponse();
            
        } catch (Exception e) {
            commonElement.setResponseMessage(e.getMessage() == null ? "" : e.getMessage().substring(0, Math.min(50, e.getMessage().length())));
        }

        responseXml = XMLUtil.formatXml(generateResponseXml(commonRCV, commonElement, resSchema, resBody, ht));
        LoanUtil.fileWriteKodit(responseXml);
        return responseXml;
    }

    private String generateResponseXml(CommonElement commonRCV, CommonElement commonElement, String resSchema, String resBody, HashMap<String, String> ht) {
        if (commonElement.getResponseCode().equals("0000")) {
            return "<?xml version='1.0' encoding='EUC-KR'?>" +
                    "<sb:" + resSchema + " xmlns:sb='http://www.shinbo.co.kr' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>" +
                    "   <sb:Common>" +
                    "   <sb:Sender>" + commonRCV.getSender() + "</sb:Sender>" +
                    "   <sb:TransactionSEQNO>" + commonRCV.getTransactionSEQNO() + "</sb:TransactionSEQNO>" +
                    "   <sb:Receiver>" + commonRCV.getReceiver() + "</sb:Receiver>" +
                    "   <sb:TransactionNO>" + commonElement.getTransactionNO() + "</sb:TransactionNO>" +
                    "   <sb:TransactionDate>" + commonRCV.getTransactionDate() + "</sb:TransactionDate>" +
                    "   <sb:TransactionTime>" + commonRCV.getTransactionTime() + "</sb:TransactionTime>" +
                    "   <sb:ResponseCode>" + commonElement.getResponseCode() + "</sb:ResponseCode>" +
                    "   <sb:ResponseMessage>" + StrUtil.nvl(commonElement.getResponseMessage()) + "</sb:ResponseMessage>" +
                    "   <sb:UserField>" + commonRCV.getUserField() + "</sb:UserField>" +
                    "   </sb:Common>" +
                    "   <sb:" + resBody + ">" +
                    "   <sb:OrderNO>" + ht.get("sb:OrderNO") + "</sb:OrderNO>" +
                    "   <sb:ContractDate>" + ht.get("sb:ContractDate") + "</sb:ContractDate>" +
                    "   </sb:" + resBody + ">" +
                    "</sb:" + resSchema + ">";
        } else {
            return "<?xml version='1.0' encoding='EUC-KR'?>" +
                    "<sb:ResCommon xmlns:sb='http://www.shinbo.co.kr' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>" +
                    "   <sb:Common>" +
                    "   <sb:Sender>" + commonRCV.getSender() + "</sb:Sender>" +
                    "   <sb:TransactionSEQNO>" + commonRCV.getTransactionSEQNO() + "</sb:TransactionSEQNO>" +
                    "   <sb:Receiver>" + commonRCV.getReceiver() + "</sb:Receiver>" +
                    "   <sb:TransactionNO>" + commonElement.getTransactionNO() + "</sb:TransactionNO>" +
                    "   <sb:TransactionDate>" + commonRCV.getTransactionDate() + "</sb:TransactionDate>" +
                    "   <sb:TransactionTime>" + commonRCV.getTransactionTime() + "</sb:TransactionTime>" +
                    "   <sb:ResponseCode>" + commonElement.getResponseCode() + "</sb:ResponseCode>" +
                    "   <sb:ResponseMessage>" + StrUtil.nvl(commonElement.getResponseMessage()) + "</sb:ResponseMessage>" +
                    "   <sb:UserField>" + commonRCV.getUserField() + "</sb:UserField>" +
                    "   </sb:Common>" +
                    "</sb:ResCommon>";
        }
    }
}
