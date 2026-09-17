package kr.co.soap.kibo.loan.emtnet;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.StringReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;

import org.w3c.dom.Document;
import org.xml.sax.InputSource;

import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.XMLEasyUtil;
import kr.co.funology.fw.util.XMLUtil;
import kr.co.soap.controll.LoanUtil;
import kr.co.soap.controll.kibo.CommonElement;
import kr.co.soap.kibo.loan.Kibo_K3XX;

public class EmtNetRcvBM {

	public String receiveBM(String sendDoc) {
		
		System.out.println("################ kibo receive k311 #####################");
		System.out.println("################ kibo receive k311 #####################");
		System.out.println("sendDoc : " + sendDoc);
		System.out.println("################ kibo receive k311 #####################");
		System.out.println("################ kibo receive k311 #####################");
		
        LoanUtil.fileWriteKibo(sendDoc);

        Document resultXML;
        CommonElement commonRCV = new CommonElement();
        CommonElement commonElement = new CommonElement();
        Kibo_K3XX kXX = null;

        try {
            resultXML = parseDocument(sendDoc);
            populateRequestCommonElement(resultXML, commonRCV);

            String transactionNO = commonRCV.getTransactionNO();
            
            if ("K311".equals(transactionNO)) {
                kXX = new EmtNetK311(resultXML);
                ((EmtNetK311) kXX).executeK311();
            } else if ("K315".equals(transactionNO)) {
                kXX = new EmtNetK315(resultXML);
                ((EmtNetK315) kXX).executeK315();
            } else if ("K321".equals(transactionNO)) {
                kXX = new EmtNetK321(resultXML);
                ((EmtNetK321) kXX).executeK321();
            }
            
            commonElement = kXX.getResCommonElement();
            kXX.updateDBWithResponse();
            
        } catch (Exception e) {
            e.printStackTrace();
            String msg = e.getMessage();
            commonElement.setResponseMessage(msg == null ? "" : msg.substring(0, Math.min(msg.length(), 50)));
        }

        //응답 생성
        String responseXml = buildResponseXml(commonRCV, commonElement);
        LoanUtil.fileWriteKibo(responseXml);
        return responseXml;
    }

    private Document parseDocument(String xml) throws Exception {
        return XMLEasyUtil.parseXMLDocument(new InputSource(new StringReader(xml)));
    }

    private void populateRequestCommonElement(Document doc, CommonElement commonRCV) {
    	
        commonRCV.setSender(XMLUtil.getNodeValue(doc, "Sender"));
        commonRCV.setTransactionSEQNO(XMLUtil.getNodeValue(doc, "TransactionSEQNO"));
        commonRCV.setTransactionNO(XMLUtil.getNodeValue(doc, "TransactionNO"));
        commonRCV.setReceiver(XMLUtil.getNodeValue(doc, "Receiver"));
        commonRCV.setTransactionDate(XMLUtil.getNodeValue(doc, "TransactionDate"));
        commonRCV.setTransactionTime(XMLUtil.getNodeValue(doc, "TransactionTime"));
        commonRCV.setUserField(XMLUtil.getNodeValueOption(doc, "UserField"));
        commonRCV.setOrderNO(XMLUtil.getNodeValue(doc, "OrderNO"));
        commonRCV.setContractDate(XMLUtil.getNodeValueOption(doc, "ContractDate"));

        if (commonRCV.getUserField() == null) {
            commonRCV.setUserField("");
        }
    }

    private String buildResponseXml(CommonElement req, CommonElement res) {
        StringBuilder sb = new StringBuilder();
        String transactionNO = res.getTransactionNO();

        sb.append("<?xml version='1.0' encoding='EUC-KR'?>");
        sb.append("<").append(transactionNO).append(">");
        sb.append("<Header></Header>");
        sb.append("<Body>");
        sb.append("<CommPart>");
        sb.append("<Sender>").append(req.getSender()).append("</Sender>");
        sb.append("<TransactionSEQNO>").append(req.getTransactionSEQNO()).append("</TransactionSEQNO>");
        sb.append("<Receiver>").append(req.getReceiver()).append("</Receiver>");
        sb.append("<TransactionNO>").append(transactionNO).append("</TransactionNO>");
        sb.append("<TransactionDate>").append(req.getTransactionDate()).append("</TransactionDate>");
        sb.append("<TransactionTime>").append(req.getTransactionTime()).append("</TransactionTime>");
        sb.append("<ResponseCode>").append(res.getResponseCode()).append("</ResponseCode>");
        sb.append("<ResponseMessage>").append(StrUtil.nvl(res.getResponseMessage())).append("</ResponseMessage>");
        sb.append("<UserField>").append(req.getUserField()).append("</UserField>");
        sb.append("</CommPart>");
        sb.append("<IndivPart>");
        sb.append("<OrderNO>").append(req.getOrderNO()).append("</OrderNO>");
        sb.append("<ContractDate>").append(req.getContractDate()).append("</ContractDate>");
        sb.append("</IndivPart>");
        sb.append("</Body>");
        sb.append("</").append(transactionNO).append(">");

        return XMLUtil.formatXml(sb.toString());
    }

    public static void main(String[] args) {
    	/*
        try (BufferedReader input = new BufferedReader(new FileReader("D:/XML/kibo_k311.xml"))) {
            StringBuilder sb = new StringBuilder();
            int ch;
            while ((ch = input.read()) != -1) {
                sb.append((char) ch);
            }

            EmtNetRcvBM rcvBM = new EmtNetRcvBM();
            String resXML = rcvBM.receiveBM(sb.toString());
            System.out.println(resXML);
        } catch (Exception e) {
            e.printStackTrace();
        }
        */
    	/*
    	        try (BufferedReader input = new BufferedReader(new FileReader("D:/XML/kibo_k311.xml"))) {
    	            StringBuilder sb = new StringBuilder();
    	            int ch;
    	            while ((ch = input.read()) != -1) {
    	                sb.append((char) ch);
    	            }

    	            String xmlData = sb.toString();

    	            // 전송할 URL (IP 또는 도메인)
    	            String targetUrl = "http://210.112.124.3:7770/mps/Send/xmlKiboJavaToSend.jsp"; // 원하는 IP와 경로로 설정

    	            URL url = new URL(targetUrl);
    	            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
    	            conn.setRequestMethod("POST");
    	            conn.setDoOutput(true);
    	            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded; charset=euc-kr");

    	            // POST 데이터 구성
    	            String postData = "inXML=" + URLEncoder.encode(xmlData, "euc-kr");

    	            try (OutputStream os = conn.getOutputStream()) {
    	                os.write(postData.getBytes("euc-kr"));
    	                os.flush();
    	            }

    	            // 응답 확인
    	            int responseCode = conn.getResponseCode();
    	            System.out.println("Response Code: " + responseCode);

    	            try (BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), "euc-kr"))) {
    	                String line;
    	                while ((line = br.readLine()) != null) {
    	                    System.out.println(line);
    	                }
    	            }

    	        } catch (Exception e) {
    	            e.printStackTrace();
    	        }
		*/
    	String msg = "정상";
    	msg = msg == null ? "" : msg.substring(0, Math.min(msg.length(), 50));
    	System.out.println(msg);
    }
    
}
