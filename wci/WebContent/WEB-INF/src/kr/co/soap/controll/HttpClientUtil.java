package kr.co.soap.controll;

import java.io.ByteArrayInputStream;
import java.io.DataInputStream;
import java.io.OutputStream;
import java.io.StringWriter;
import java.net.HttpURLConnection;
import java.net.URL;

import org.w3c.dom.Document;

import kr.co.funology.fw.GlobalEnv;
import kr.co.funology.fw.mgr.ConfigurationMgr;
import kr.co.funology.fw.util.XMLEasyUtil;
import kr.co.funology.fw.util.XMLUtil;

public class HttpClientUtil {
    private static CommonElementResInfo commonElementResInfo;

    // 공통 URL 호출 메서드
    private static String getUrl(String code) {
        if (code == null || code.isEmpty()) {
            return EnvironmentPropertiesDAO.getInstance().getEnv("sURL");
        } else if(ConfigurationMgr.getInstance().getString("OWNER_MPCODE").equalsIgnoreCase(code)) {
            System.out.println(EnvironmentPropertiesDAO.getInstance().getEnv("sURL"));
            return EnvironmentPropertiesDAO.getInstance().getEnv("sURL");
        } else {
            return EnvironmentPropertiesDAO.getInstance().getEnv(code + "_sURL");
        }
    }

    // 공통 호출 메서드 (중복 코드 제거)
    private static byte[] call(byte[] content, String code) throws Exception {
        
        HttpURLConnection conn = null;
        conn = (HttpURLConnection) new URL(getUrl(code)).openConnection();
        conn.setDoInput(true);
        conn.setDoOutput(true);
        conn.setUseCaches(false);
        conn.setRequestProperty("Content-Type", "text/xml; charset=UTF-8");
        conn.setRequestProperty("XERC-SyncTimeout", EnvironmentPropertiesDAO.getInstance().getEnv("timeout"));
        
        try (OutputStream out = conn.getOutputStream()) {
            out.write(content);
            out.flush();
            //out.close();
        } catch(Exception e) {
            System.out.println(e.toString());
        }
        
        // 응답 코드 확인
        int responseCode = conn.getResponseCode();
        int contLength = conn.getContentLength();
        
        try (DataInputStream in = new DataInputStream(conn.getInputStream())) {
            byte[] resContent = new byte[contLength];
            in.readFully(resContent);
            return resContent;
        } finally {
            conn.disconnect();
        }
    }

    // 요청을 처리하고 응답을 반환하는 메서드 (shinboCall 리팩토링)
    public static Document shinboCall(Document doc) throws Exception {
        return shinboCall(doc, null);
    }

    public static Document shinboCall(Document doc, String eibs) throws Exception {
        String sync = "SYNC";
        Document resDoc = null;
        synchronized (sync) {
            //경로 읽기
            EnvironmentPropertiesDAO.getInstance().load(GlobalEnv.getWebRootDir() + "WEB-INF/environment.properties");
            // XML 포맷 정리 및 로깅
            doc = XMLUtil.formatXml(doc);
            StringWriter sw = new StringWriter(1024);
            XMLUtil.displayXML(doc, sw);
            LoanUtil.fileWriteKodit(sw.toString());
      
            System.out.println("=================요청전문 시작>>==================");
            System.out.println(sw.toString());
            System.out.println("=================요청전문 끝>>==================");
      
            byte[] resContent;
            if (eibs != null) {
                resContent = call(sw.toString().getBytes(), eibs);
                System.out.println("eibs");
            } else {
                String sender = XMLUtil.getNodeValue(doc, "sb:Sender");
                resContent = call(sw.toString().getBytes(), sender);
                System.out.println("kodit");
            }
      
            // 응답 처리
            resDoc = XMLEasyUtil.parseXMLDocument(new ByteArrayInputStream(resContent));
            sw = new StringWriter(1024);
              XMLUtil.displayXML(resDoc, sw);
      
              System.out.println("=================응답전문 시작==================");
              System.out.println(sw.toString());
              System.out.println("=================응답전문 끝==================");
              LoanUtil.fileWriteKodit(sw.toString());
      
              // 응답으로부터 commonElementResInfo 객체 생성
              commonElementResInfo = new CommonElementResInfo();
              commonElementResInfo.makeThisObjectFromDocument(resDoc);
        } // End Of Sync
        
        return resDoc;
    }

    public static CommonElementResInfo getCommonElementResInfo() {
        return commonElementResInfo;
    }
}
