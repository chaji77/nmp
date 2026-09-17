package kr.co.mp.firstbill;

import java.net.MalformedURLException;
import java.rmi.RemoteException;
import java.util.ArrayList;

import com.baroservice.ws.ArrayOfEMAILPUBLICKEY;
import com.baroservice.ws.ArrayOfString;
import com.baroservice.ws.ArrayOfTaxInvoiceStateEX;
import com.baroservice.ws.ArrayOfTaxInvoiceTradeLineItem;
import com.baroservice.ws.InvoiceParty;
import com.baroservice.ws.NTSSendOption;
import com.baroservice.ws.PagedTaxInvoiceEx;
import com.baroservice.ws.TaxInvoice;
import com.baroservice.ws.TaxInvoiceStateEX;
import com.baroservice.ws.TaxInvoiceTradeLineItem;
import kr.co.funology.fw.util.StrUtil;

public class FirstBillCtrl extends BaroBill {

    public FirstBillCtrl(BillUserVO v) throws MalformedURLException {
        super(v);
    }

    /**
     * RegistAndIssueTaxInvoice - 일반(수정)세금계산서 "등록" 과 "발행" 을 한번에 처리
     */

    public int RegistAndIssueTaxInvoice(InvoiceVO vo, String strUserId) throws RemoteException {
      int intResult = 0;
      try {
        super.setInstance();
        String certKey = super.ck;                               //인증키
        TaxInvoice taxInvoice = new TaxInvoice();
        taxInvoice.setIssueDirection(vo.intIssueDirection);       //1-정발행, 2-역발행(위수탁 세금계산서는 정발행만 허용)
        taxInvoice.setTaxInvoiceType(vo.intInvoiceType);          //1-세금계산서, 2-계산서, 4-위수탁세금계산서, 5-위수탁계산서

        //-------------------------------------------
        //과세형태
        //-------------------------------------------
        //TaxInvoiceType 이 1,4 일 때 : 1-과세, 2-영세
        //TaxInvoiceType 이 2,5 일 때 : 3-면세
        //-------------------------------------------
        taxInvoice.setTaxType(vo.intTaxType);
        taxInvoice.setTaxCalcType(vo.intTaxCalcType);             //세율계산방법 : 1-절상, 2-절사, 3-반올림
        taxInvoice.setPurposeType(vo.intPurposeType);             //1-영수, 2-청구

        //-------------------------------------------
        //수정사유코드
        //-------------------------------------------
        //공백-일반세금계산서, 1-기재사항의 착오 정정, 2-공급가액의 변동, 3-재화의 환입, 4-계약의 해제, 5-내국신용장 사후개설, 6-착오에 의한 이중발행
        //-------------------------------------------
        taxInvoice.setModifyCode(vo.strModifyCode);

        taxInvoice.setKwon("");                              //별지서식 11호 상의 [권] 항목
        taxInvoice.setHo("");                                //별지서식 11호 상의 [호] 항목
        taxInvoice.setSerialNum(vo.strSerialNum);            //별지서식 11호 상의 [일련번호] 항목

        //-------------------------------------------
        //공급가액 총액
        //-------------------------------------------
        taxInvoice.setAmountTotal(vo.strAmountTotal);

        //-------------------------------------------
        //세액합계
        //-------------------------------------------
        //taxInvoice.TaxType 이 2 또는 3 으로 셋팅된 경우 0으로 입력
        //-------------------------------------------
        taxInvoice.setTaxTotal(vo.strTaxTotal);

        //-------------------------------------------
        //합계금액
        //-------------------------------------------
        //공급가액 총액 + 세액합계 와 일치해야 합니다.
        //-------------------------------------------
        taxInvoice.setTotalAmount(vo.strTotalAmount);

        taxInvoice.setCash(vo.strCash);                        //현금
        taxInvoice.setChkBill("");                            //수표
        taxInvoice.setNote("");                                //어음
        taxInvoice.setCredit("");                            //외상미수금

        taxInvoice.setRemark1(StrUtil.nvl(vo.strRemark));
        taxInvoice.setRemark2("");
        taxInvoice.setRemark3("");

        taxInvoice.setWriteDate(vo.strWriteDate); //작성일자 (YYYYMMDD), 공백입력 시 Today로 작성됨.

        //-------------------------------------------
        //공급자 정보 - 정발행시 세금계산서 작성자
        //-------------------------------------------
        taxInvoice.setInvoicerParty(new InvoiceParty());

        taxInvoice.getInvoicerParty().setMgtNum(vo.strSerialNum);  //필수입력 - 연동사부여 문서키
        taxInvoice.getInvoicerParty().setCorpNum(vo.INVOICER_CORP_NUM);        //필수입력 - 연계사업자 사업자번호 ('-' 제외, 10자리)
        taxInvoice.getInvoicerParty().setTaxRegID("");
        taxInvoice.getInvoicerParty().setCorpName(vo.INVOICER_CORP_NAME);        //필수입력
        taxInvoice.getInvoicerParty().setCEOName(vo.INVOICER_CEO_NAME);        //필수입력
        taxInvoice.getInvoicerParty().setAddr(vo.INVOICER_ADDR);
        taxInvoice.getInvoicerParty().setBizType(vo.INVOICER_BIZ_TYPE);
        taxInvoice.getInvoicerParty().setBizClass(vo.INVOICER_BIZ_CLASS);
        taxInvoice.getInvoicerParty().setContactID(strUserId);        //필수입력 - 담당자 바로빌 아이디
        taxInvoice.getInvoicerParty().setContactName(StrUtil.nvl(vo.INVOICER_CONTACT_NAME, "담당자"));    //필수입력
        taxInvoice.getInvoicerParty().setTEL(vo.INVOICER_TEL);
        taxInvoice.getInvoicerParty().setHP("");
        taxInvoice.getInvoicerParty().setEmail(vo.INVOICER_EMAIL);            //필수입력

        //-------------------------------------------
        //공급받는자 정보 - 역발행시 세금계산서 작성자
        //-------------------------------------------
        taxInvoice.setInvoiceeParty(new InvoiceParty());

        taxInvoice.getInvoiceeParty().setCorpNum(vo.strToBizNo);      //필수입력
        taxInvoice.getInvoiceeParty().setTaxRegID(vo.strToTaxRegId);
        taxInvoice.getInvoiceeParty().setCorpName(vo.strToCorpNm);    //필수입력
        taxInvoice.getInvoiceeParty().setCEOName(vo.strToCeo);        //필수입력
        taxInvoice.getInvoiceeParty().setAddr(vo.strToAddr);
        taxInvoice.getInvoiceeParty().setBizType(vo.strToBizType);
        taxInvoice.getInvoiceeParty().setBizClass(vo.strToBizClass);
        taxInvoice.getInvoiceeParty().setContactID("");
        taxInvoice.getInvoiceeParty().setContactName(StrUtil.nvl(vo.strToManager, "담당자")); //필수입력
        taxInvoice.getInvoiceeParty().setTEL(vo.strToTel);
        taxInvoice.getInvoiceeParty().setHP("");
        taxInvoice.getInvoiceeParty().setEmail(vo.strToEmail);

        //-------------------------------------------
        //수탁자 정보 - 입력하지 않음
        //-------------------------------------------
        taxInvoice.setBrokerParty(new InvoiceParty());

        taxInvoice.getBrokerParty().setCorpNum("");
        taxInvoice.getBrokerParty().setTaxRegID("");
        taxInvoice.getBrokerParty().setCorpName("");
        taxInvoice.getBrokerParty().setCEOName("");
        taxInvoice.getBrokerParty().setAddr("");
        taxInvoice.getBrokerParty().setBizType("");
        taxInvoice.getBrokerParty().setBizClass("");
        taxInvoice.getBrokerParty().setContactID("");
        taxInvoice.getBrokerParty().setContactName("");
        taxInvoice.getBrokerParty().setTEL("");
        taxInvoice.getBrokerParty().setHP("");
        taxInvoice.getBrokerParty().setEmail("");

        //-------------------------------------------
        //품목
        //-------------------------------------------
        ArrayOfTaxInvoiceTradeLineItem arrayOfTaxInvoiceTradeLineItem = new ArrayOfTaxInvoiceTradeLineItem();

        if (vo.arrTradeItem!=null && vo.arrTradeItem.size()>0) {
          for (InvoiceVO.TradeItem ti : vo.arrTradeItem) {
            TaxInvoiceTradeLineItem taxInvoiceTradeLineItem = new TaxInvoiceTradeLineItem();
            taxInvoiceTradeLineItem.setPurchaseExpiry(ti.strPurchaseExpiry);        //YYYYMMDD
            taxInvoiceTradeLineItem.setName(ti.strName);
            taxInvoiceTradeLineItem.setInformation(ti.strInformation);
            taxInvoiceTradeLineItem.setChargeableUnit(ti.strChargeableUnit);
            taxInvoiceTradeLineItem.setUnitPrice(ti.strUnitPrice);
            taxInvoiceTradeLineItem.setAmount(ti.strAmount);
            taxInvoiceTradeLineItem.setTax(ti.strTax);
            taxInvoiceTradeLineItem.setDescription(ti.strDescription);
            arrayOfTaxInvoiceTradeLineItem.getTaxInvoiceTradeLineItem().add(taxInvoiceTradeLineItem);
          }
          taxInvoice.setTaxInvoiceTradeLineItems(arrayOfTaxInvoiceTradeLineItem);
        }

        //-------------------------------------------
        boolean sendSms = false;                        //문자 발송여부 (공급받는자 정보의 HP 항목이 입력된 경우에만 발송됨)
        boolean forceIssue = false;                        //가산세가 예상되는 세금계산서 발행 여부
        String mailTitle = "";                            //전송되는 이메일의 제목 설정 (공백 시 바로빌 기본 제목으로 전송됨)

        //-------------------------------------------
        System.out.println(certKey);
        System.out.println(taxInvoice.toString());

        intResult = super.barobillApiService.taxInvoice.registAndIssueTaxInvoice(certKey, taxInvoice.getInvoicerParty().getCorpNum(), taxInvoice, sendSms, forceIssue, mailTitle);

        // 일반(수정)세금계산서 "등록" 과 "발행예정" 을 한번에 처리
        // intResult = barobillApiService.taxInvoice.registAndPreIssueTaxInvoice(certKey, taxInvoice.getInvoicerParty().getCorpNum(), taxInvoice, sendSms, issueTiming, mailTitle);
      } catch (Exception e) {
          e.printStackTrace();
      }
      return(intResult);
    }


    public ArrayList<String[]> getStatus(ArrayOfString mgtKeyList) {
        ArrayList<String[]> arr = new ArrayList<>();
        try {
            super.setInstance();
            ArrayOfTaxInvoiceStateEX taxInvoiceStates = super.barobillApiService.taxInvoice.getTaxInvoiceStatesEX(super.ck, super.cn, mgtKeyList);
            if (taxInvoiceStates==null) return arr;
            /*
            getBarobillState
            1000	// 임시저장 상태
            5031	// [완료] 발급취소 상태
            3014	// 발급완료 상태
            getNTSSendState
            1		// 국세청전송전
            2, 3	// 국세청전송중
            4		// [완료]국세청 전송성공
            5		// [완료]국세청 전송실패

            */
            for (TaxInvoiceStateEX r : taxInvoiceStates.getTaxInvoiceStateEX()) {
                String[] s = new String[3];
                int intStatus = r.getBarobillState();
                if (intStatus<0) {
                    s[0] = Integer.toString(intStatus); // fail
                    s[1] = "";
                    s[2] = "";
                }
                else {
                    int intResult = r.getNTSSendState();
                    s[0] = Integer.toString(intResult);
                    s[1] = r.getMgtKey();
                    s[2] = r.getInvoiceKey();
                }
                arr.add(s);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return arr;
    }


    //홈택스 조회

    /**
     * GetTaxInvoiceScrapRequestURL - 국세청 세금계산서 조회서비스 신청 URL
     */

    public void GetTaxInvoiceScrapRequestURL() throws RemoteException {
        String certKey = super.ck;           //인증키
        String corpNum = super.cn;           //연계사업자 사업자번호 ('-' 제외, 10자리)
        String userId = super.cid;           //연계사업자 아이디
        String pwd = super.cpw;              //연계사업자 비밀번호
        String result = barobillApiService.taxInvoice.getTaxInvoiceScrapRequestURL(certKey, corpNum, userId, pwd);
        System.out.println(result);
    }

    /**
     * GetTaxInvoiceSalesList - 매출 세금계산서 조회 [국세청 전송완료 건만]
     */

    public void GetDailyTaxInvoiceSalesList() throws RemoteException {
        String certKey = super.ck;           //인증키
        String corpNum = super.cn;           //연계사업자 사업자번호 ('-' 제외, 10자리)
        String userId = super.cid;           //연계사업자 아이디
        int taxType = 1;                //과세형태, 1:과세 2:영세 3:면세
        int dateType = 1;                //조회기준, 1:작성일자 2:발행일자
        String baseDate = "";           //기준날짜
        int countPerPage = 10;             //페이지당 갯수
        int currentPage = 1;            //현재페이지
        PagedTaxInvoiceEx result = barobillApiService.taxInvoice.getDailyTaxInvoiceSalesList(certKey, corpNum, userId, taxType, dateType, baseDate, countPerPage, currentPage);

        if (result.getCurrentPage() < 0) {
            System.out.println(result.getCurrentPage());
        } else {
            System.out.println(result);
        }
    }

    /**
     * GetTaxInvoiceSalesListEx - 매출 세금계산서 조회 [국세청 전송완료 건만] (대표품목 포함)
     */

    public void GetMonthlyTaxInvoiceSalesList() throws RemoteException {
        String certKey = super.ck;           //인증키
        String corpNum = super.cn;           //연계사업자 사업자번호 ('-' 제외, 10자리)
        String userId = super.cid;           //연계사업자 아이디
        int taxType = 1;                //과세형태, 1:과세 2:영세 3:면세
        int dateType = 1;            //조회기준, 1:작성일자 2:발행일자
        String baseMonth = "";            //기준월
        int countPerPage = 10;            //페이지당 갯수
        int currentPage = 1;            //현재페이지
        int orderDirection = 2;            //1:ASC 2:DESC
        PagedTaxInvoiceEx result = barobillApiService.taxInvoice.getMonthlyTaxInvoiceSalesList(certKey, corpNum, userId, taxType, dateType, baseMonth, countPerPage, currentPage, orderDirection);

        if (result.getCurrentPage() < 0) {
            System.out.println(result.getCurrentPage());
        } else {
            System.out.println(result);
        }
    }

    /**
     * ProcTaxInvoice - 프로세스 처리
     */

    public void ProcTaxInvoice() throws RemoteException {
        String certKey = super.ck;           //인증키
        String corpNum = super.cn;           //연계사업자 사업자번호 ('-' 제외, 10자리)
        String mgtKey = "";                //연동사부여 문서키
        String procType = "";            //프로세스 타입
        //CANCEL : 승인(발행)요청 취소
        //ACCEPT : 승인
        //REFUSE : 거부
        //ISSUE_CANCEL : 발행완료된 매출 세금계산서의 발행을 취소
        String memo = "";                //프로세스 처리시 거래처에 전달할 메모.

        int result = barobillApiService.taxInvoice.procTaxInvoice(certKey, corpNum, mgtKey, procType, memo);

        System.out.println(result);
    }

    /**
     * SendToNTS - 세금계산서 국세청 즉시 전송
     */

    public void SendToNTS() throws RemoteException {
        String certKey = super.ck;           //인증키
        String corpNum = super.cn;           //연계사업자 사업자번호 ('-' 제외, 10자리)
        String mgtKey = "";                //연동사부여 문서키

        int result = barobillApiService.taxInvoice.sendToNTS(certKey, corpNum, mgtKey);

        System.out.println(result);
    }

    //부가서비스

    /**
     * ReSendEmail - 이메일 전송
     */

    public void ReSendEmail() throws RemoteException {
        String certKey = super.ck;           //인증키
        String corpNum = super.cn;           //연계사업자 사업자번호 ('-' 제외, 10자리)
        String mgtKey = "";                //연동사부여 문서키
        String toEmailAddress = "";        //수신자 메일 주소

        int result = barobillApiService.taxInvoice.reSendEmail(certKey, corpNum, mgtKey, toEmailAddress);

        System.out.println(result);
    }

    /**
     * ReSendSMS - 문자 재전송
     */

    public void ReSendSMS() throws RemoteException {
        String certKey = super.ck;           //인증키
        String corpNum = super.cn;           //연계사업자 사업자번호 ('-' 제외, 10자리)
        String senderId = "";            //연계사업자 아이디
        String fromNumber = "";            //발신자 휴대폰 번호
        String toCorpName = "";            //수신자 회사명
        String toName = "";                //수신자 이름
        String toNumber = "";            //수신자 휴대폰 번호
        String contents = "";            //문자메세지 내용

        int result = barobillApiService.taxInvoice.reSendSMS(certKey, corpNum, senderId, fromNumber, toCorpName, toName, toNumber, contents);

        System.out.println(result);
    }

    /**
     * SendInvoiceSMS - 문자 전송 (문서이력에 기록됨)
     */

    public void SendInvoiceSMS() throws RemoteException {
        String certKey = super.ck;           //인증키
        String corpNum = super.cn;           //연계사업자 사업자번호 ('-' 제외, 10자리)
        String senderId = "";            //연계사업자 아이디
        String mgtKey = "";                //연동사부여 문서키
        String fromNumber = "";            //발신자 휴대폰 번호
        String toNumber = "";            //수신자 휴대폰 번호
        String contents = "";            //문자메세지 내용

        int result = barobillApiService.taxInvoice.sendInvoiceSMS(certKey, corpNum, senderId, mgtKey, fromNumber, toNumber, contents);

        System.out.println(result);
    }

    //국세청 전송설정
    /**
     * GetNTSSendOption - 국세청 전송설정 확인
     */

    public void GetNTSSendOption() throws RemoteException {
        String certKey = super.ck;           //인증키
        String corpNum = super.cn;           //연계사업자 사업자번호 ('-' 제외, 10자리)

        NTSSendOption result = barobillApiService.taxInvoice.getNTSSendOption(certKey, corpNum);

        if (result.getTaxationOption() < 0) { //실패
            System.out.println(result.getTaxationOption());
        } else { //성공
            System.out.println(result);
        }
    }

    /**
     * ChangeNTSSendOption - 국세청 전송설정 변경
     */

    public void ChangeNTSSendOption() throws RemoteException {
        String certKey = super.ck;           //인증키
        String corpNum = super.cn;           //연계사업자 사업자번호 ('-' 제외, 10자리)
        String id = super.cid;               //연계사업자 아이디

        NTSSendOption ntsSendOption = new NTSSendOption();

        //-------------------------------------------
        //과세, 영세 국세청 전송설정
        //-------------------------------------------
        //1-발행 익일 자동전송, 2-발행 즉시 전송
        //-------------------------------------------
        ntsSendOption.setTaxationOption(1);

        //-------------------------------------------
        //과세, 영세 가산세 허용여부
        //-------------------------------------------
        //1-허용, 0-차단
        //-------------------------------------------
        ntsSendOption.setTaxationAddTaxAllowYN(1);

        //-------------------------------------------
        //면세 국세청 전송설정
        //-------------------------------------------
        //1-발행 익일 자동전송, 2-발행 즉시 전송, 3-수동 전송
        //-------------------------------------------
        ntsSendOption.setTaxExemptionOption(1);

        //-------------------------------------------
        //면세 가산세 허용여부
        //-------------------------------------------
        //1-허용, 0-차단
        //-------------------------------------------
        ntsSendOption.setTaxExemptionAddTaxAllowYN(1);

        int result = barobillApiService.taxInvoice.changeNTSSendOption(certKey, corpNum, id, ntsSendOption);

        System.out.println(result);
    }


    //기타

    /**
     * CheckMgtNumIsExists - 연동사부여 문서키 사용여부 확인
     */

    public void CheckMgtNumIsExists() throws RemoteException {

        String certKey = "";            //인증키
        String corpNum = "";            //연계사업자 사업자번호 ('-' 제외, 10자리)
        String mgtKey = "";                //연동사부여 문서키

        int result = barobillApiService.taxInvoice.checkMgtNumIsExists(certKey, corpNum, mgtKey);

        System.out.println(result);
    }

    /**
     * GetTaxInvoicePopUpURL - 문서 내용보기 팝업 URL (연동사부여 문서키)
     */

    public String GetTaxInvoicePopUpURL(String strMgtKey) {
        try {
            String certKey = super.ck;           //인증키
            String corpNum = super.cn;           //연계사업자 사업자번호 ('-' 제외, 10자리)
            // String mgtKey = "";                //연동사부여 문서키
            String id = super.cid;                    //연계사업자 아이디
            // String pwd = super.cpw;                //연계사업자 비밀번호
            System.out.println(certKey);
            System.out.println(corpNum);
            System.out.println(strMgtKey);
            System.out.println(id);
            return StrUtil.nvl(barobillApiService.taxInvoice.getTaxInvoicePopUpURL(certKey, corpNum, strMgtKey, id, ""));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }

    /**
     * GetTaxInvoicePrintURL - 인쇄 팝업 URL (연동사부여 문서키)
     */

    public void GetTaxInvoicePrintURL() throws RemoteException {
        String certKey = super.ck;           //인증키
        String corpNum = super.cn;           //연계사업자 사업자번호 ('-' 제외, 10자리)
        String mgtKey = "";                //연동사부여 문서키
        String id = "";                    //연계사업자 아이디
        String pwd = "";                //연계사업자 비밀번호

        String result = barobillApiService.taxInvoice.getTaxInvoicePrintURL(certKey, corpNum, mgtKey, id, pwd);

        System.out.println(result);
    }

    /**
     * GetTaxInvoicesPrintURL - 대량인쇄 팝업 URL
     */

    public void GetTaxInvoicesPrintURL() throws RemoteException {
        String certKey = super.ck;           //인증키
        String corpNum = super.cn;           //연계사업자 사업자번호 ('-' 제외, 10자리)
        String id = "";                            //연계사업자 아이디
        String pwd = "";                        //연계사업자 비밀번호

        ArrayOfString mgtKeyList = new ArrayOfString();    //연동사부여 문서키 배열
        mgtKeyList.getString().add("");
        mgtKeyList.getString().add("");

        String result = barobillApiService.taxInvoice.getTaxInvoicesPrintURL(certKey, corpNum, mgtKeyList, id, pwd);

        System.out.println(result);
    }

    /**
     * GetTaxInvoiceMailURL - 이메일의 보기버튼 URL
     */

    public void GetTaxInvoiceMailURL() throws RemoteException {
        String certKey = super.ck;           //인증키
        String corpNum = super.cn;           //연계사업자 사업자번호 ('-' 제외, 10자리)
        String mgtKey = "";                //연동사부여 문서키

        String result = barobillApiService.taxInvoice.getTaxinvoiceMailURL(certKey, corpNum, mgtKey);

        System.out.println(result);
    }

    /**
     * GetEmailPublicKeys - ASP업체 Email 목록확인
     */

    public void GetEmailPublicKeys() throws RemoteException {
        String certKey = super.ck;           //인증키
        ArrayOfEMAILPUBLICKEY result = barobillApiService.taxInvoice.getEmailPublicKeys(certKey);
        int intResult = 0;
        try {
            if (result.getEMAILPUBLICKEY().size() == 1) {
                intResult = Integer.parseInt(result.getEMAILPUBLICKEY().get(0).getPK());
            }
        } catch (NumberFormatException e) {
        }

        if (intResult < 0) { //실패
            System.out.println(intResult);
        } else { //성공
            System.out.println(result);
        }
    }
}
