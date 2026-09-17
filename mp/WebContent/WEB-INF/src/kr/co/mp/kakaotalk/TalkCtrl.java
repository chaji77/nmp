package kr.co.mp.kakaotalk;

import com.baroservice.api.BarobillApiProfile;
import com.baroservice.api.BarobillApiService;
import com.baroservice.ws.KakaotalkTemplate;
import com.baroservice.ws.KakaotalkATMessage;

import kr.co.funology.fw.GlobalEnv;
import kr.co.funology.fw.mgr.ConfigurationMgr;
import kr.co.funology.fw.util.StrUtil;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.List;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
/**
 * 카카오톡 메시징
 * <pre>
 *   성능개선사항
 *   (1) barobillApiService 초기화에 5초. 초기화를 한번만 하도록 싱글톤으로 구현
 *   (2) barobillApiService만 죽을 수 있으므로, loadService()로 별도 초기화하고 매 전송시마다 실행되도록 변경
 *   (3) 템플릿을 가져오는 시간을 줄이기 위해 로컬의 XML(WEB-INF/kakaotemplates.xml)을 호출하는 것으로 변경
 *   (4) MakeTemplates.jsp를 통해 탬플릿 XML이 생성되도록 변경
 * </pre>
 */
public class TalkCtrl {
  private static TalkCtrl instance = null;
  private BarobillApiService barobillApiService = null;
  private String ck = "";
  private String cn = "";
  private String cid = "";
  private String channelid = "";

  private TalkCtrl() {
    loadService();
    this.cn        = StrUtil.nvl(ConfigurationMgr.getInstance().getString("OWNER_BIZ_NO")).replaceAll("-", "");
    this.ck        = StrUtil.nvl(ConfigurationMgr.getInstance().getString("ETAX_KEY"));
    this.cid       = StrUtil.nvl(ConfigurationMgr.getInstance().getString("ETAX_ID"));
    this.channelid = StrUtil.nvl(ConfigurationMgr.getInstance().getString("KAKAO_CHANNEL_ID"));
  }
  
  private void loadService() {
    try {
      if (this.barobillApiService == null) this.barobillApiService = (ConfigurationMgr.getInstance().getString("ETAX_RELEASE_YN").equals("N")) ? new BarobillApiService(BarobillApiProfile.TESTBED) : new BarobillApiService(BarobillApiProfile.RELEASE);
    } catch (Exception e) {
      System.out.println(e.getMessage());
    }
  }
  
  public static TalkCtrl getInstance() {
    if (instance==null) instance = new TalkCtrl();
    return instance;
  }

  public List<KakaotalkTemplate> getTemplates() {
    loadService();
    if (this.barobillApiService == null) return null;
    List<KakaotalkTemplate> result = this.barobillApiService.kakaotalk.getKakaotalkTemplates(this.ck, this.cn, this.channelid).getKakaotalkTemplate();
    if (result.size() == 1 && result.get(0).getStatus() < 0) { // FAILURE
      System.out.println(result.get(0).getStatus());
    } else { // SUCCESS
      return result;
    }
    return null;
  }
  /*
  public String getTemplate(String strTemplateName) {
    List<KakaotalkTemplate> result = barobillApiService.kakaotalk.getKakaotalkTemplates(this.ck, this.cn, this.channelid).getKakaotalkTemplate();
    if (result.size() == 1 && result.get(0).getStatus() < 0) { // FAILURE
      System.out.println(result.get(0).getStatus());
    } else { // SUCCESS
      for (KakaotalkTemplate template : result) {
        if (template.getTemplateName().equals(strTemplateName)) {
          return template.getTemplateContent();
        }
      }
    }
    return "";
  }
  */
  public String getTemplate(String strTemplateName) {
    try {
      File f = new File(GlobalEnv.getWebRootDir() + "WEB-INF/kakaotemplates.xml");
      DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
      DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
      Document doc = dBuilder.parse(f);
      NodeList rows = doc.getElementsByTagName("row");
      for (int i = 0; i < rows.getLength(); i++) {
          Node row = rows.item(i);
          if (row.getNodeType() == Node.ELEMENT_NODE) {
              Element rowElement = (Element) row;
              String id = rowElement.getElementsByTagName("id").item(0).getTextContent();
              if (strTemplateName.equals(id)) {
                  return rowElement.getElementsByTagName("body").item(0).getTextContent();
              }
          }
      }
    } catch (Exception e) {
      System.out.println(e.toString());
    }
    return "";
  }
  
  /**
   * If it is not on the block list, Send Message through KakaoTalk. 
   * 
   * @param strTemplateName
   * @param strReceiverNumber
   * @param strReceiverName
   * @param strTitle
   * @param arrReplace
   * @return
   */
  public String send(String strTemplateName, String strReceiverNumber, String strReceiverName, String strTitle, List<String[]> arrReplace) {
    if (BlockBean.isBlocked(strReceiverNumber, "")) { // IF THE TRANSMISSION IS BLOCKED, IT WILL NOT BE EXECUTED.
      return "9999";
    }
    String strContents = this.getTemplate(strTemplateName);
    if (arrReplace.size()>0) {
      for (String[] s : arrReplace) {
        strContents = strContents.replaceAll(s[0], s[1]);
      }
    }
    KakaotalkATMessage kakaotalkMessage = new KakaotalkATMessage();
    kakaotalkMessage.setTitle(strTitle);
    kakaotalkMessage.setMessage(strContents);
    kakaotalkMessage.setReceiverNum(strReceiverNumber);
    kakaotalkMessage.setReceiverName(strReceiverName);
    kakaotalkMessage.setSmsSubject("");
    kakaotalkMessage.setSmsMessage("");
    loadService();
    if (this.barobillApiService == null) return "9998";
    String result = this.barobillApiService.kakaotalk.sendATKakaotalk(this.ck, this.cn, this.cid, strTemplateName, "", "N", "", kakaotalkMessage);
    return result;
  }
  
  public static String sendBySystem(String strTemplateCode, int intCpyId, int intCtId, int intBillSeq) {
    String strUrl = ConfigurationMgr.getInstance().getString("DOMAIN_URL") 
                  + ConfigurationMgr.getInstance().getString("CONTEXT_PATH")
                  + ConfigurationMgr.getInstance().getString("KAKAO_SEND_PAGE");
    strUrl += "?tcd="+strTemplateCode+"&cpyid="+Integer.toString(intCpyId)+"&ctid="+Integer.toString(intCtId)+"&billseq="+Integer.toString(intBillSeq);
    BufferedReader in = null;
    String strResult = "";
    try {
      URL url = new URL(strUrl);
      HttpURLConnection con = (HttpURLConnection) url.openConnection();
      in = new BufferedReader(new InputStreamReader(con.getInputStream(), "UTF-8"));
      String l = "";
      while((l=in.readLine())!=null) strResult+=l;
    } catch (Exception e) {
    	
    } finally {
      if(in != null) try { in.close(); } catch(Exception e) { e.printStackTrace(); }
    }
    return strResult;
  }

  public static void main(String[] args) {
    // TalkCtrl.sendBySystem("M001", 0, 0, 0);
    try {
      String body = new TalkCtrl().getTemplate("LoginTemporaryPassword");
      System.out.println(body);
    } catch(Exception e) {}
  }
  
}
