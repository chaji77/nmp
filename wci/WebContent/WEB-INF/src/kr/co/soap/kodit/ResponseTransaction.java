package kr.co.soap.kodit;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.io.StringReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.HashMap;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.w3c.dom.Document;
import org.xml.sax.InputSource;

import kr.co.funology.fw.mgr.ConfigurationMgr;
import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.XMLEasyUtil;
import kr.co.soap.controll.LoanUtil;
import kr.co.soap.kodit.loan.emtnet.EmtNetRcvBM;

@WebServlet(name="ResponseTransaction", urlPatterns="/ResponseTransaction")
public class ResponseTransaction extends HttpServlet {
	
	private static final long serialVersionUID = 1L;
	
	private Document resultXML = null;
	private LoanUtil loanUtil = new LoanUtil();
	private String strXML = "";
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		System.out.println("호출 : >>>>>>>> get");
		request.setCharacterEncoding("EUC-KR");
		processRequest(request, response);
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		System.out.println("### POST 요청 처리 시작 ###");
		request.setCharacterEncoding("EUC-KR");
        processRequest(request, response);
    }
	
	private void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
		
		response.setContentType("text/xml; charset=EUC-KR");
		response.setCharacterEncoding("EUC-KR");
		
        //PrintWriter out = response.getWriter();
		OutputStream os = response.getOutputStream();
        
        String sendDoc = StrUtil.nvl(request.getParameter("xmldoc"));
        this.strXML = sendDoc;
        System.out.println("this.strXML ###############################################");
        System.out.println("this.strXML : " + sendDoc);
        System.out.println("this.strXML ###############################################");
        
        if (sendDoc == null || sendDoc.trim().isEmpty()) {
            byte[] errorBytes = "<error>sendDoc is null or empty</error>".getBytes("EUC-KR");
            os.write(errorBytes);
            os.flush();
            os.close();
            return;
        }
        
        try {
            this.resultXML = XMLEasyUtil.parseXMLDocument(new InputSource(new StringReader(sendDoc)));
            HashMap<String, String> ht = loanUtil.getXmlData(resultXML);
            
            String transactionNO = ht.get("sb:TransactionNO").substring(0, 4);
            System.out.println("transactionNO : " + transactionNO);
            
            String responseXml = processTransaction(transactionNO, ht);
            //out.println(responseXml);
            byte[] responseBytes = responseXml.getBytes("EUC-KR");
            os.write(responseBytes);
        } catch (Exception e) {
            //out.println("<error>" + e.getMessage() + "</error>");
        	String errorXml = "<error>" + e.getMessage() + "</error>";
            byte[] errorBytes = errorXml.getBytes("EUC-KR");
            os.write(errorBytes); 
        } finally {
        	os.flush();
            os.close();
        }
    }
	
	private String processTransaction(String transactionNO, HashMap<String, String> ht) {
		
		/*
		HashMap<String, String> map = ht;
		map.forEach((key, value) -> {
			System.out.println("Key: " + key + ", Value: " + value);
		});
		*/
		
        // 트랜잭션 처리 로직 (A181, A185, EMTNETC 등)
        if ("A185".equals(transactionNO)) {
            return createA185Response(ht);
        } else if ("A181".equals(transactionNO)) {
            return createA181Response(ht);
        } else if ("C221".equals(transactionNO) || "C223".equals(transactionNO) || "C225".equals(transactionNO) || "C227".equals(transactionNO) || "D211".equals(transactionNO)
        		|| "D215".equals(transactionNO) || "E211".equals(transactionNO) || "F221".equals(transactionNO) || "F225".equals(transactionNO) || "H211".equals(transactionNO)
        		|| "H215".equals(transactionNO) || "E221".equals(transactionNO) || "E225".equals(transactionNO)
        		) 
        {
        	return forwardToBServer(this.strXML);
        } else {
        	return createOtherResponse(this.resultXML, ht);
        }
    }
	
	private String forwardToBServer(String resultXML) {
		
		String targetUrl = ConfigurationMgr.getInstance().getString("EBS_RESPONSE_URL");
		//String targetUrl = "http://210.112.124.45:7004/xerc/send/encoding.jsp";
		//String targetUrl = "http://211.50.114.142:7004/xerc/send/rcv3_han.jsp";

	    try {
	    	
	    	//String xmlDoc = XMLEasyUtil.documentToString(resultXML);
	    	
	    	System.out.println("*************************");
	    	System.out.println("*************************");
	    	System.out.println("xmlDoc : " + resultXML);
	    	System.out.println("*************************");
	    	System.out.println("*************************");
	    	
	    	
	        URL url = new URL(targetUrl);
	        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
	        conn.setRequestMethod("POST");
	        conn.setDoOutput(true);
	        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded; charset=EUC-KR");

	        try (OutputStream os = conn.getOutputStream()) {
	            os.write("xmldoc=".getBytes("US-ASCII")); // ASCII 고정
	            os.write(resultXML.getBytes("EUC-KR"));      // 본문은 EUC-KR
	        }

	        StringBuilder response = new StringBuilder();
	        try (BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream(), "EUC-KR"))) {
	            String line;
	            while ((line = in.readLine()) != null) {
	                response.append(line);
	            }
	        }

	        LoanUtil.fileWriteKoditGuarantee(resultXML);
	        return response.toString();

	    } catch (Exception e) {
	        return "<error>Exception while forwarding to 45 server: " + e.getMessage() + "</error>";
	    }
	}

	
	private String createA185Response(HashMap<String, String> ht) {
        return "<?xml version='1.0' encoding='EUC-KR'?>" +
               "<sb:ResCommon xmlns:sb='http://www.shinbo.co.kr' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>" +
               "<sb:Common>" +
               "<sb:Sender>" + ht.get("sb:Sender") + "</sb:Sender>" +
               "<sb:TransactionSEQNO>" + ht.get("sb:TransactionSEQNO") + "</sb:TransactionSEQNO>" +
               "<sb:Receiver>" + ht.get("sb:Receiver") + "</sb:Receiver>" +
               "<sb:TransactionNO>A186</sb:TransactionNO>" +
               "<sb:TransactionDate>" + ht.get("sb:TransactionDate") + "</sb:TransactionDate>" +
               "<sb:TransactionTime>" + ht.get("sb:TransactionTime") + "</sb:TransactionTime>" +
               "<sb:ResponseCode>0000</sb:ResponseCode>" +
               "<sb:ResponseMessage>정상</sb:ResponseMessage>" +
               "</sb:Common></sb:ResCommon>";
    }
	
	private String createA181Response(HashMap<String, String> ht) {
		return "<?xml version='1.0' encoding='EUC-KR' ?> \n" +                               
				"<sb:ResTransactionInquiry xmlns:sb='http://www.shinbo.co.kr'> \n" +          
				"<sb:Common xmlns:sb='http://www.shinbo.co.kr'> \n" +   
				"<sb:Sender>"+ ht.get("sb:resSender") +"</sb:Sender> \n" +
				"<sb:TransactionSEQNO>"+ ht.get("sb:resTransactionSEQNO") +"</sb:TransactionSEQNO> \n" +
				"<sb:Receiver>"+ ht.get("sb:Receiver") +"</sb:Receiver>  \n" +
				"<sb:TransactionNO>A182</sb:TransactionNO> \n" +                             
				"<sb:TransactionDate>"+ ht.get("sb:resTransactionDate") +"</sb:TransactionDate> \n" +       
				"<sb:TransactionTime>"+ ht.get("sb:resTransactionTime") +"</sb:TransactionTime> \n" +
				"<sb:ResponseCode>0000</sb:ResponseCode> \n" + 
				"<sb:ResponseMessage>트랜잭션조회 처리되었습니다.</sb:ResponseMessage> \n" +
				"<sb:UserField /> \n" +
				"</sb:Common> \n" +
				"<sb:Response> \n" +
				"<sb:TransactionResultCode>"+ ht.get("sb:resCode") +"</sb:TransactionResultCode> \n" +
				"<sb:TransactionResultMessage>"+ ht.get("sb:resMsg") +"</sb:TransactionResultMessage> \n" +
				"</sb:Response> \n" +
				"</sb:ResTransactionInquiry> ";                                           
    }
	
	private String createOtherResponse(Document resultXML, HashMap<String, String> ht) {
		EmtNetRcvBM rcvBM = new EmtNetRcvBM();
		return rcvBM.receiveBM(resultXML, ht);
	}
	
	public static void main(String[] args) throws IOException {
		
		String targetUrl = "http://n.mp1.co.kr/mp/ResponseTransaction";
		//String targetUrl = "http://w2.mp1.co.kr/mp/ResponseTransaction";
		//String targetUrl = "http://118.36.148.168:8080/mp/ResponseTransaction";
		
		String eucKrXml = "<?xml version=\"1.0\" encoding=\"euc-kr\"?>\n"
		        + "<sb:GuaranteeInform xmlns:sb=\"http://www.shinbo.co.kr\">\n"
		        + "  <sb:Common>\n"
		        + "    <sb:Sender>0763910</sb:Sender>\n"
		        + "    <sb:TransactionSEQNO>99999</sb:TransactionSEQNO>\n"
		        + "    <sb:Receiver>EMTNET</sb:Receiver>\n"
		        + "    <sb:TransactionNO>E211</sb:TransactionNO>\n"
		        + "    <sb:TransactionDate>20250429</sb:TransactionDate>\n"
		        + "    <sb:TransactionTime>101800</sb:TransactionTime>\n"
		        + "    <sb:ResponseCode>0000</sb:ResponseCode>\n"
		        + "    <sb:UserField>88889</sb:UserField>\n"
		        + "  </sb:Common>\n"
		        + "  <sb:Transfer>\n"
		        + "    <sb:GuaranteeCode>A1</sb:GuaranteeCode>\n"
		        + "    <sb:BuyerID>1101115514610</sb:BuyerID>\n"
		        + "    <sb:BuyerBusinessNO>1088158595</sb:BuyerBusinessNO>\n"
		        + "    <sb:ApplicationNO>LXT20241219000000001</sb:ApplicationNO>\n"
		        + "    <sb:GuaranteeNO>TAI202400018</sb:GuaranteeNO>\n"
		        + "    <sb:IssueDate>20241220</sb:IssueDate>\n"
		        + "    <sb:GuaranteeAMT>70000000</sb:GuaranteeAMT>\n"
		        + "    <sb:GuaranteeExpirationDate>20251219</sb:GuaranteeExpirationDate>\n"
		        + "    <sb:GuaranteeType>02</sb:GuaranteeType>\n"
		        + "    <sb:Creditor>주식회사　엘뇬감골닐우감</sb:Creditor>\n"
		        + "    <sb:ConditionCount>4</sb:ConditionCount>\n"
		        + "    <sb:ConditionDetail seq=\"1\">\n"
		        + "      <sb:Condition>본　보증서는　신용보증약관　제７조（신용보증책임의　범위）　</sb:Condition>\n"
		        + "    </sb:ConditionDetail>\n"
		        + "    <sb:ConditionDetail seq=\"2\">\n"
		        + "      <sb:Condition>제２항에도　불구하고，　대금지급기일　또는　어음지급기일이　</sb:Condition>\n"
		        + "    </sb:ConditionDetail>\n"
		        + "    <sb:ConditionDetail seq=\"3\">\n"
		        + "      <sb:Condition>신용보증기한으로부터　６개월　이내인　피보증채무에　한하여　</sb:Condition>\n"
		        + "    </sb:ConditionDetail>\n"
		        + "    <sb:ConditionDetail seq=\"4\">\n"
		        + "      <sb:Condition>보증책임을　부담합니다．</sb:Condition>\n"
		        + "    </sb:ConditionDetail>\n"
		        + "  </sb:Transfer>\n"
		        + "</sb:GuaranteeInform>";
		/*
		
		String eucKrXml =  "<?xml version=\"1.0\" encoding=\"euc-kr\"?>\n" +
			    	    "<sb:CChangeKM xmlns:sb=\"http://www.shinbo.co.kr\">\n" +
			    	    "  <sb:Common>\n" +
			    	    "    <sb:Sender>0766506</sb:Sender>\n" +
			    	    "    <sb:TransactionSEQNO>2664</sb:TransactionSEQNO>\n" +
			    	    "    <sb:Receiver>EMTNET</sb:Receiver>\n" +
			    	    "    <sb:TransactionNO>F221</sb:TransactionNO>\n" +
			    	    "    <sb:TransactionDate>20250423</sb:TransactionDate>\n" +
			    	    "    <sb:TransactionTime>150403</sb:TransactionTime>\n" +
			    	    "    <sb:ResponseCode>0000</sb:ResponseCode>\n" +
			    	    "    <sb:UserField>04438170.7.131.138</sb:UserField>\n" +
			    	    "  </sb:Common>\n" +
			    	    "  <sb:Transfer>\n" +
			    	    "    <sb:ID>1601110208309</sb:ID>\n" +
			    	    "    <sb:BusinessNO>3058181912</sb:BusinessNO>\n" +
			    	    "    <sb:CustomerNO>65823015</sb:CustomerNO>\n" +
			    	    "    <sb:CGuaranteeNO>ATMA202501064</sb:CGuaranteeNO>\n" +
			    	    "    <sb:BankText>엘지전자（주）</sb:BankText>\n" +
			    	    "    <sb:CompanyNameText>주식회사　청우이엔지</sb:CompanyNameText>\n" +
			    	    "    <sb:CEONameText>대표이사　배경록</sb:CEONameText>\n" +
			    	    "    <sb:Address>대전광역시　중구　서문로　５８　，　３층（문화동）</sb:Address>\n" +
			    	    "    <sb:GuaranteeNO>TMA201800386</sb:GuaranteeNO>\n" +
			    	    "    <sb:GuaranteeDate>20180523</sb:GuaranteeDate>\n" +
			    	    "    <sb:GuaranteeExpirationDate>20250516</sb:GuaranteeExpirationDate>\n" +
			    	    "    <sb:GuaranteeAMTText>￦1,000,000,000-</sb:GuaranteeAMTText>\n" +
			    	    "    <sb:CIssueDate>20250423</sb:CIssueDate>\n" +
			    	    "    <sb:ChiefName>최원목</sb:ChiefName>\n" +
			    	    "    <sb:KCGFBranch>대전</sb:KCGFBranch>\n" +
			    	    "    <sb:TELNO>1588-6565</sb:TELNO>\n" +
			    	    "    <sb:TeamCode>2</sb:TeamCode>\n" +
			    	    "    <sb:TeamMember>전주현</sb:TeamMember>\n" +
			    	    "    <sb:BranchAddress>대전　동구　대전로　８５３　（정동，　신용보증기금）</sb:BranchAddress>\n" +
			    	    "    <sb:IssueInformation>2025.04.23-13:18-12-TMA-전주현-170.7</sb:IssueInformation>\n" +
			    	    "    <sb:CCount>1</sb:CCount>\n" +
			    	    "    <sb:CDetail seq=\"1\">\n" +
			    	    "      <sb:CArticle>보증기한</sb:CArticle>\n" +
			    	    "      <sb:Before>２０２５－０５－１６</sb:Before>\n" +
			    	    "      <sb:After>２０２６－０５－１５</sb:After>\n" +
			    	    "    </sb:CDetail>\n" +
			    	    "  </sb:Transfer>\n" +
			    	    "</sb:CChangeKM>";
			    	    */
		
		/*
		String eucKrXml = "<?xml version=\"1.0\" encoding=\"EUC-KR\" standalone=\"no\"?>\n"
			    + "<sb:CChangeKM xmlns:sb=\"http://www.shinbo.co.kr\">\n"
			    + " <sb:Common>\n"
			    + "  <sb:Sender>0767712</sb:Sender>\n"
			    + "  <sb:TransactionSEQNO>12774</sb:TransactionSEQNO>\n"
			    + "  <sb:Receiver>EMTNET</sb:Receiver>\n"
			    + "  <sb:TransactionNO>F221</sb:TransactionNO>\n"
			    + "  <sb:TransactionDate>20250425</sb:TransactionDate>\n"
			    + "  <sb:TransactionTime>171639</sb:TransactionTime>\n"
			    + "  <sb:ResponseCode>0000</sb:ResponseCode>\n"
			    + "  <sb:UserField>04683170.7.212.75</sb:UserField>\n"
			    + " </sb:Common>\n"
			    + " <sb:Transfer>\n"
			    + "  <sb:ID>5501261182633</sb:ID>\n"
			    + "  <sb:BusinessNO>6080594665</sb:BusinessNO>\n"
			    + "  <sb:CustomerNO>44451929</sb:CustomerNO>\n"
			    + "  <sb:CGuaranteeNO>ATQI202501071</sb:CGuaranteeNO>\n"
			    + "  <sb:BankText>??±¹?¸??¾?¾Ø?×??³?·????¨????</sb:BankText>\n"
			    + "  <sb:CompanyNameText>???­???????????????Ø¿??¡</sb:CompanyNameText>\n"
			    + "  <sb:CEONameText>´???¡¡±???°?</sb:CEONameText>\n"
			    + "  <sb:Address>°æ³²¡¡??¿ø½?¡¡¸¶????Æ÷±¸¡¡???²º???·?¡¡?±?·¡¡???±?°?±?¿¡¡?¶?°?²??¡¡?¨½?Æ÷?¿?±°¡??¡¡¸¶??¸¸¾Æ??Æ???¾ÆÆ?Æ®??</sb:Address>\n"
			    + "  <sb:GuaranteeNO>TQI201300529</sb:GuaranteeNO>\n"
			    + "  <sb:GuaranteeDate>20130524</sb:GuaranteeDate>\n"
			    + "  <sb:GuaranteeExpirationDate>20250509</sb:GuaranteeExpirationDate>\n"
			    + "  <sb:GuaranteeAMTText>??10,000,000-</sb:GuaranteeAMTText>\n"
			    + "  <sb:CIssueDate>20250425</sb:CIssueDate>\n"
			    + "  <sb:ChiefName>??¿ø¸?</sb:ChiefName>\n"
			    + "  <sb:KCGFBranch>¸¶??</sb:KCGFBranch>\n"
			    + "  <sb:TELNO>1588-6565</sb:TELNO>\n"
			    + "  <sb:TeamCode>3</sb:TeamCode>\n"
			    + "  <sb:TeamMember>?¶???ø</sb:TeamMember>\n"
			    + "  <sb:BranchAddress>°æ³²¡¡??¿ø½?¡¡¸¶????Æ÷±¸¡¡º??¾°?¸®·?¡¡?´?¶??¡¡?¹?þ¡¡?¨¿??¿?¿??¡¡??¼º??¸?º?????</sb:BranchAddress>\n"
			    + "  <sb:IssueInformation>2025.04.25-17:07-32-TQI-?????ø-170.7</sb:IssueInformation>\n"
			    + "  <sb:CCount>1</sb:CCount>\n"
			    + "  <sb:CDetail seq=\"1\">\n"
			    + "   <sb:CArticle>º¸??±???</sb:CArticle>\n"
			    + "   <sb:Before>?²?°?²???­?°???­?°?¹</sb:Before>\n"
			    + "   <sb:After>?²?°?²?¶?­?°???­?°?¸</sb:After>\n"
			    + "  </sb:CDetail>\n"
			    + " </sb:Transfer>\n"
			    + "</sb:CChangeKM>";
	*/
 // 위 XML 문자열
		/*
		String host = "211.50.114.142";
	    int port = 8080;
	    String path = "/mp/ResponseTransaction";
		
	    // POST 데이터 준비
	    String postData = "xmldoc=" + java.net.URLEncoder.encode(eucKrXml, "EUC-KR");
	    byte[] postDataBytes = postData.getBytes("EUC-KR");

	    Socket socket = new Socket(host, port);
	    OutputStream os = socket.getOutputStream();
	    OutputStreamWriter writer = new OutputStreamWriter(os, "EUC-KR");

	    // HTTP 요청 Header 작성
	    writer.write("POST " + path + " HTTP/1.1\r\n");
	    writer.write("Host: " + host + "\r\n");
	    writer.write("Content-Type: application/x-www-form-urlencoded; charset=EUC-KR\r\n");
	    writer.write("Content-Length: " + postDataBytes.length + "\r\n");
	    writer.write("Connection: close\r\n");
	    writer.write("\r\n"); // 헤더 끝
	    writer.flush();

	    // HTTP 요청 Body 작성
	    os.write(postDataBytes);
	    os.flush();

	    // 응답 읽기
	    BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream(), "EUC-KR"));
	    String line;
	    while ((line = in.readLine()) != null) {
	        System.out.println(line);
	    }

	    in.close();
	    socket.close();
	    */
		URL url = new URL(targetUrl);
		HttpURLConnection conn = (HttpURLConnection) url.openConnection();
		conn.setDoOutput(true);
		conn.setRequestMethod("POST");
		conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded; charset=euc-kr");

		String postData = "xmldoc=" + URLEncoder.encode(eucKrXml, "EUC-KR");
		try (OutputStream os = conn.getOutputStream()) {
		    os.write(postData.getBytes("EUC-KR"));
		}

		BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream(), "EUC-KR"));
		String line;
		while ((line = in.readLine()) != null) {
		    System.out.println(line);
		}
		in.close();
	}
}
