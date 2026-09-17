package kr.co.mp.firstbill;
import java.rmi.RemoteException;
import java.util.List;

import com.baroservice.api.BarobillApiProfile;
import com.baroservice.api.BarobillApiService;
import com.baroservice.ws.ArrayOfContact;
import com.baroservice.ws.Contact;
import kr.co.funology.fw.mgr.ConfigurationMgr;
import kr.co.funology.fw.util.StrUtil;

public class BaroBill {
  protected BarobillApiService barobillApiService = null;

  protected String ck = "";
  protected String cn = "";
  protected String cid = "";
  protected String cpw = "";
  protected String cnm = "";
  protected String ceo = "";

  protected String p_bizType    = "";
  protected String p_bizClass   = "";
  protected String p_postNum    = "";
  protected String p_addr1      = "";
  protected String p_addr2      = "";
  protected String p_memberName = "";
  protected String p_phone      = "";
  protected String p_email      = "";

  public BaroBill(BillUserVO v) {
    try {
      this.ck           = ConfigurationMgr.getInstance().getString("ETAX_KEY");
      this.cnm          = v.CORPNAME;
      this.ceo          = v.CEONAME;
      this.cn           = v.CORPNUM.replaceAll("-", "");
      this.p_addr1      = v.ADDR1;
      this.p_addr2      = v.ADDR2;
      this.cid          = v.ID;
      this.cpw          = v.PWD;
      this.p_bizType    = v.BIZTYPE;
      this.p_bizClass   = v.BIZCLASS;
      this.p_memberName = v.MEMBERNAME;
      this.p_phone      = v.TEL;
      this.p_email      = v.EMAIL;
    } catch (Exception e) {
      System.out.println(e.toString());
    }
  }

  private void printVal() {
    System.out.println("ck           : " + this.ck          );
    System.out.println("cnm          : " + this.cnm         );
    System.out.println("ceo          : " + this.ceo         );
    System.out.println("cn           : " + this.cn          );
    System.out.println("p_addr1      : " + this.p_addr1     );
    System.out.println("p_addr2      : " + this.p_addr2     );
    System.out.println("cid          : " + this.cid         );
    System.out.println("cpw          : " + this.cpw         );
    System.out.println("p_bizType    : " + this.p_bizType   );
    System.out.println("p_bizClass   : " + this.p_bizClass  );
    System.out.println("p_memberName : " + this.p_memberName);
    System.out.println("p_phone      : " + this.p_phone     );
    System.out.println("p_email      : " + this.p_email     );
  }
  
  public void setInstance() {
    if (this.barobillApiService==null) {
      try {
        BarobillApiProfile bbp = (ConfigurationMgr.getInstance().getString("ETAX_RELEASE_YN").equals("N")) ? BarobillApiProfile.TESTBED : BarobillApiProfile.RELEASE;
        if (this.barobillApiService == null) this.barobillApiService = new BarobillApiService(bbp);
      } catch (Exception e) {
        System.out.println(e.toString());
      }
    }
  }

  public String getBizNo() {
      return this.cn;
  }
  public String getComNm() {
      return this.cnm;
  }
  public String getCeo() {
      return this.ceo;
  }
  public String getBizType() {
      return this.p_bizType;
  }
  public String getBizClass() {
      return this.p_bizClass;
  }
  public String getAddr() {
      return this.p_addr1;
  }
  public String getManager() {
      return this.p_memberName;
  }
  public String getEmail() {
      return this.p_email;
  }

  public String getRegistedInformation() {
      StringBuffer sb = new StringBuffer();
      sb.append("<tr><th>인&nbsp;&nbsp;증&nbsp;&nbsp;키</th><td>" + this.ck + "</td></tr>");
      sb.append("<tr><th>아&nbsp;&nbsp;이&nbsp;&nbsp;디</th><td>" + this.cid + "</td></tr>");
      sb.append("<tr><th>비밀번호</th><td>비공개</td></tr>");
      sb.append("<tr><th>공급자사업자번호</th><td>" + this.cn + "</td></tr>");
      sb.append("<tr><th>회&nbsp;&nbsp;사&nbsp;&nbsp;명</th><td>" + this.cnm + "</td></tr>");
      sb.append("<tr><th>대표자명</th><td>" + this.ceo + "</td></tr>");
      sb.append("<tr><th>업　　종</th><td>" + this.p_bizType + "</td></tr>");
      sb.append("<tr><th>업　　태</th><td>" + this.p_bizClass + "</td></tr>");
      sb.append("<tr><th>주　　소</th><td>" + this.p_addr1 + "</td></tr>");
      sb.append("<tr><th>발행담당자</th><td>" + this.p_memberName+ "</td></tr>");
      sb.append("<tr><th>발행이메일</th><td>" + this.p_email + "</td></tr>");
      return sb.toString();
  }


  public void CheckCorpIsMember() {
    setInstance();
    String certKey = this.ck;            //인증키
    String corpNum = this.cn;            //연계사업자 사업자번호 ('-' 제외, 10자리)
    String checkCorpNum = this.cn;       //확인할 사업자번호 ('-' 제외, 10자리)
    try {
      int result = barobillApiService.taxInvoice.checkCorpIsMember(certKey, corpNum, checkCorpNum);
      System.out.println(result);
    } catch (Exception e) {
      System.out.println(e.toString());
    }
  }

  public int RegistCorp() throws RemoteException {
      String certKey = this.ck;            //인증키
      String corpNum = this.cn;            //연계사업자 사업자번호 ('-' 제외, 10자리)
      String corpName = this.cnm;            //회사명
      String ceoName = this.ceo;            //대표자명
      String bizType = this.p_bizType;            //업태
      String bizClass = this.p_bizClass;            //업종
      String postNum = "";            //우편번호
      String addr1 = this.p_addr1;                //주소1 (ex. 서울특별시 양천구 목1동)
      String addr2 = this.p_addr2;                //주소2 (ex. SBS방송센터 920)
      String memberName = this.p_memberName;            //담당자 성명
      String juminNum = "";            //주민등록번호 ('-' 제외, 13자리)
      String id = this.cid;                    //연계사업자 아이디
      String pwd = this.cpw;                //연계사업자 비밀번호 (6~20자만 가능)
      String grade = "";                //직급
      String tel = this.p_phone;                //전화번호
      String hp = "";                    //휴대폰
      String email = this.p_email;                //이메일
      printVal();
      setInstance();
      
      int result = barobillApiService.taxInvoice.registCorp(certKey, corpNum, corpName, ceoName, bizType, bizClass, postNum, addr1, addr2, memberName, juminNum, id, pwd, grade, tel, hp, email);
      System.out.println(result);
      return result;
  }

  public void UpdateCorpInfo() throws RemoteException {
      String certKey = this.ck;            //인증키
      String corpNum = this.cn;            //연계사업자 사업자번호 ('-' 제외, 10자리)
      String corpName = this.cnm;            //회사명
      String ceoName = this.ceo;            //대표자명
      String bizType = this.p_bizType;            //업태
      String bizClass = this.p_bizClass;            //업종
      String postNum = "";            //우편번호
      String addr1 = this.p_addr1;                //주소1 (ex. 서울특별시 양천구 목1동)
      String addr2 = this.p_addr2;                //주소2 (ex. SBS방송센터 920)
      setInstance();
      int result = barobillApiService.taxInvoice.updateCorpInfo(certKey, corpNum, corpName, ceoName, bizType, bizClass, postNum, addr1, addr2);
      System.out.println(result);
  }
  
  public int AddUserTopCorp() throws RemoteException {
      String certKey = this.ck;            //인증키
      String corpNum = this.cn;            //연계사업자 사업자번호 ('-' 제외, 10자리)
      /*
      String corpName = this.cnm;            //회사명
      String ceoName = this.ceo;            //대표자명
      String bizType = this.p_bizType;            //업태
      String bizClass = this.p_bizClass;            //업종
      String postNum = "";            //우편번호
      String addr1 = this.p_addr1;                //주소1 (ex. 서울특별시 양천구 목1동)
      String addr2 = this.p_addr2;                //주소2 (ex. SBS방송센터 920)
      */
      String memberName = this.p_memberName;            //담당자 성명
      String juminNum = "";            //주민등록번호 ('-' 제외, 13자리)
      String id = this.cid;                    //연계사업자 아이디
      String pwd = this.cpw;                //연계사업자 비밀번호 (6~20자만 가능)
      String grade = "";                //직급
      String tel = this.p_phone;                //전화번호
      String hp = "";                    //휴대폰
      String email = this.p_email;                //이메일
      setInstance();
      // return barobillApiService.taxInvoice.addUserToCorp(addr1, addr2, memberName, "", id, pwd, "", tel, hp, email);
      return barobillApiService.taxInvoice.addUserToCorp(certKey, corpNum, memberName, juminNum, id, pwd, grade, tel, hp, email);
  }

  public ArrayOfContact GetCorpMemberContacts() throws RemoteException {
      String certKey = this.ck;            //인증키
      String corpNum = this.cn;            //연계사업자 사업자번호 ('-' 제외, 10자리)
      String checkCorpNum = this.cn;        //확인할 사업자번호 ('-' 제외, 10자리)
      setInstance();
      ArrayOfContact result = barobillApiService.taxInvoice.getCorpMemberContacts(certKey, corpNum, checkCorpNum);
      System.out.println(result);
      return result;
  }

  public void ChangeCorpManager(String strManagerId) throws RemoteException {
      String certKey = this.ck;            //인증키
      String corpNum = this.cn;            //연계사업자 사업자번호 ('-' 제외, 10자리)
      String newManagerId = strManagerId;        //연계사업자 새 관리자 아이디
      setInstance();
      int result = barobillApiService.taxInvoice.changeCorpManager(certKey, corpNum, newManagerId);
      System.out.println(result);
  }
  /**
   * GetBalanceCostAmount - 잔여포인트 확인
   */
  public void GetBalanceCostAmount() throws RemoteException {
      String certKey = this.ck;            //인증키
      String corpNum = this.cn;            //연계사업자 사업자번호 ('-' 제외, 10자리)
      setInstance();
      long result = barobillApiService.taxInvoice.getBalanceCostAmount(certKey, corpNum);
      System.out.println(result);
  }

  /**
   * GetBalanceCostAmountOfInterOP - 연동사포인트 확인
   */
  public void GetBalanceCostAmountOfInterOP() throws RemoteException {
      String certKey = this.ck;            //인증키
      setInstance();
      long result = barobillApiService.taxInvoice.getBalanceCostAmountOfInterOP(certKey);
      System.out.println(result);
  }

  /**
   * GetChargeUnitCost - 요금 단가 확인
   */
  public void GetChargeUnitCost() throws RemoteException {
      String certKey = this.ck;    //인증키
      String corpNum = this.cn;    //연계사업자 사업자번호 ('-' 제외, 10자리)
      int chargeCode = 11;    //1:세금계산서 2:계산서 3:거래명세서 4:입금표 5:청구서 6:견적서 7:영수증 8:발주서 9:현금영수증 11:SMS전송 12:FAX전송 13:LMS전송 14:MMS전송
      setInstance();
      int result = barobillApiService.taxInvoice.getChargeUnitCost(certKey, corpNum, chargeCode);
      System.out.println(result);
  }

  /**
   * CheckChargeable - 과금 가능여부 확인
   */
  public void CheckChargeable() throws RemoteException {
      String certKey = this.ck;    //인증키
      String corpNum = this.cn;    //연계사업자 사업자번호 ('-' 제외, 10자리)
      int cType = 5;                //1:문서발행 2:발행+SMS전송 5:SMS전송 6:FAX전송 7:LMS전송 8:MMS전송
      int docType = 1;            //CType이 1,2 인 경우 = 1:세금계산서 2:계산서 3:거래명세서 4:입금표 5:청구서 6:견적서 7:영수증 8:발주서 9:현금영수증
      //CType이 5,6,7,8 인 경우 = 1
      setInstance();
      int result = barobillApiService.taxInvoice.checkChargeable(certKey, corpNum, cType, docType);
      System.out.println(result);
  }

  /**
   * GetCertificateRegistURL - 공인인증서 등록 URL
   */
  public String GetCertificateRegistURL() throws RemoteException {
      String certKey = this.ck;    //인증키
      String corpNum = this.cn;    //연계사업자 사업자번호 ('-' 제외, 10자리)
      String id = this.cid;        //연계사업자 아이디
      String pwd = this.cpw;       //연계사업자 비밀번호
      setInstance();
      String result = barobillApiService.taxInvoice.getCertificateRegistURL(certKey, corpNum, id, pwd);
      System.out.println(result);
      return result;
  }

  /**
   * GetCertificateExpireDate - 등록한 공인인증서 만료일 확인
   */
  public String GetCertificateExpireDate() throws RemoteException {
      String certKey = this.ck;    //인증키
      String corpNum = this.cn;    //연계사업자 사업자번호 ('-' 제외, 10자리)
      setInstance();
      String result = barobillApiService.taxInvoice.getCertificateExpireDate(certKey, corpNum);
      System.out.println(result);
      return result;
  }

  /**
   * RegistSMSFromNumber - 발신번호 추가
   */
  public void RegistSMSFromNumber(String fromNumber) throws RemoteException {
      String certKey = this.ck;    //인증키
      String corpNum = this.cn;    //연계사업자 사업자번호 ('-' 제외, 10자리)
      setInstance();
      int result = barobillApiService.taxInvoice.registSMSFromNumber(certKey, corpNum, fromNumber);
      System.out.println(result);
  }

  /**
   * CheckSMSFromNumber - 발신번호 확인
   */
  public void CheckSMSFromNumber(String fromNumber) throws RemoteException {
      String certKey = this.ck;    //인증키
      String corpNum = this.cn;    //연계사업자 사업자번호 ('-' 제외, 10자리)
      setInstance();
      int result = barobillApiService.taxInvoice.checkSMSFromNumber(certKey, corpNum, fromNumber);
      System.out.println(result);
  }

  /**
   * GetSMSFromNumberURL - 발신번호 관리 URL
   */
  public void GetSMSFromNumberURL() throws RemoteException {
      String certKey = this.ck;    //인증키
      String corpNum = this.cn;    //연계사업자 사업자번호 ('-' 제외, 10자리)
      String id = this.cid;        //연계사업자 아이디
      String pwd = this.cpw;       //연계사업자 비밀번호
      setInstance();
      String result = barobillApiService.taxInvoice.getSMSFromNumberURL(certKey, corpNum, id, pwd);
      System.out.println(result);
  }

  /**
   * GetBaroBillURL - URL
   */
  public String GetBaroBillURL() throws RemoteException {
      String certKey = this.ck;    //인증키
      String corpNum = this.cn;    //연계사업자 사업자번호 ('-' 제외, 10자리)
      String id = this.cid;        //연계사업자 아이디
      // String pwd = this.cpw;       //연계사업자 비밀번호 // 2023/12/20
      String togo = "MAIN";        //URL 코드
      setInstance();
      String result = barobillApiService.taxInvoice.getBaroBillURL(certKey, corpNum, id, "", togo);
      System.out.println(result);
      return result;
  }

  public String GetTaxInvoicePopUpURL(String strMgtKey) throws RemoteException {
      String certKey = this.ck;    //인증키
      String corpNum = this.cn;    //연계사업자 사업자번호 ('-' 제외, 10자리)
      String MgtKey  = strMgtKey;
      String id      = this.cid;        //연계사업자 아이디
      // String pwd  = this.cpw;       //연계사업자 비밀번호 // 2023/12/20
      // String togo = "MAIN";        //URL 코드
      setInstance();
      String result = StrUtil.nvl(barobillApiService.taxInvoice.getTaxInvoicePopUpURL(certKey, corpNum, MgtKey, id, ""));
      System.out.println(result);
      return result;
  }
  
  
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public List<Contact> getContacts() {
      List<Contact> l = null;
      try {
        ArrayOfContact ac = GetCorpMemberContacts();
        l = ac.getContact();
      } catch (Exception e) {}
      return l;
  }
  
  // 공인인증서등록
  public String getBaroBillCert() {
      String certKey = this.ck;    //인증키
      String corpNum = this.cn;    //연계사업자 사업자번호 ('-' 제외, 10자리)
      String id      = this.cid;        //연계사업자 아이디
      String togo    = "CERT";        //URL 코드
      setInstance();
      String result = barobillApiService.taxInvoice.getBaroBillURL(certKey, corpNum, id, "", togo);
      System.out.println(result);
      return result;
  }

  public static void main(String[] args) {

  }
}
