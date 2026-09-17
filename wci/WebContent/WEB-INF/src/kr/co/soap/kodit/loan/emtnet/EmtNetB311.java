package kr.co.soap.kodit.loan.emtnet;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.List;

import kr.co.funology.fw.mgr.ConfigurationMgr;
import kr.co.funology.fw.util.DateTimeUtil;
import kr.co.funology.fw.util.StrUtil;
import kr.co.mp.kakaotalk.TalkCtrl;
import kr.co.mp.mgr.sales.MpFeeCalcurator;
import kr.co.mp.trade.TradeBean;
import kr.co.soap.controll.B311ItemVO;
import kr.co.soap.controll.CommonElement;
import kr.co.soap.controll.EnumData;
import kr.co.soap.controll.LoanUtil;
import kr.co.soap.controll.SequenceGenerator;
import kr.co.soap.controll.SoapCommonBean;
import kr.co.soap.controll.SoapCommonVO;
import kr.co.soap.kodit.loan.Kodit_B311;

public class EmtNetB311 extends Kodit_B311 {
    
    private SoapCommonVO.XmlB311VO xmlB311VO  = null;
    private SoapCommonVO xmlItemVO  = null;
    private SoapCommonVO.SendXmlB311VO sendXmlB311VO = null;
    //private SoapCommonVO.CtHeaderEtcVO ctHeaderEtcVO  = null;
    private String strEditYn = null;
    //private String auto_app = null;
    
    SoapCommonBean bean;
    
    public EmtNetB311() {
        super("");
        super.kind = "R";
        this.bean = new SoapCommonBean(); // 생성자에서 한 번만 초기화
    }
    
    public CommonElement executeB311(int intCtId, String strEdit) {
        this.strEditYn = (strEdit==null) ? "N" : strEdit.trim();
        return super.executeB31X(intCtId);
    }
    
    @Override
    protected CommonElement readSyncTableData(int intCtId) throws Exception {
         CommonElement commonElement = new CommonElement();
         commonElement.setResponseCode("0000");
         
         //basic main data set.
         this.xmlB311VO = bean.GET_XML_B311_PROC(intCtId);
         this.xmlItemVO = new SoapCommonBean().GET_XML_B311_ITEM_PROC(this.xmlB311VO.CTID);
         
         // MPCode, 구매사 아이디를 이 시점에 세팅
         super.MPCode = this.xmlB311VO.MP_CODE; 
         super.strUser = this.xmlB311VO.PRS_LOGIN;
         //super.SetXmlB311VO = this.xmlB311VO;

         // 매매계약 정보 읽기, 주문 품목 정보 읽기, 구매기업 정보 읽기, 판매기업 정보 읽기, 은행 정보 읽기, 은행 대출 상품 정보 읽기
         if (this.xmlB311VO == null) 
             return setErrorResponse(commonElement, "0090", "매매계약정보를 읽을 수 없습니다.");
         if (this.xmlItemVO == null) 
             return setErrorResponse(commonElement, "0080", "주문품목정보를 읽을 수 없습니다.");
         if (EnumData.longNull == this.xmlB311VO.CPYBUYER) 
             return setErrorResponse(commonElement, "0081", "구매기업정보를 읽을 수 없습니다.");
         if (EnumData.longNull == this.xmlB311VO.CPYSELLER) 
             return setErrorResponse(commonElement, "0081", "판매기업정보를 읽을 수 없습니다.");
         if (this.xmlB311VO.BNK_CD == null) 
             return setErrorResponse(commonElement, "0082", "은행정보를 읽을 수 없습니다.");
         if (this.xmlB311VO.TAXISSUEYN == null) 
             return setErrorResponse(commonElement, "0091", "은행 대출상품정보를 읽을 수 없습니다.");
         if (!new MpFeeCalcurator().isCommissionInfo(intCtId)) // RYAN-MIN : 수수료정보가 있는지 확인
            return setErrorResponse(commonElement, "0092", "수수료정보를 읽을 수 없습니다.");

         super.taxIssueYN            = this.xmlB311VO.TAXISSUEYN;                    //세금계산서 발행여부
         super.paymentApprovalTypeYN = this.xmlB311VO.PAYMENTAPPROVALTYPEYN;            //지급승인 여부
         super.expirationDateYN      = this.xmlB311VO.EXPIRATIONDATEYN;                 //만기일 사용 여부
         super.paymentDueDateYN      = this.xmlB311VO.PAYMENTDUEDATEYN;                //대금지급예정일 사용여부

         /*
         //계산서 첨부형태 및 아이피 체크, 구리스크랩?
         this.ctHeaderEtcVO = bean.GET_CT_HEADER_ETC_INFO_PROC(intCtId);
        
         //20170809 조명희M요청 구매사 앨파스 적용유형 WRT로 박기
         if(this.xmlB311VO.CPYBUYER == 40623){
             this.ctHeaderEtcVO.TAX_SECTION = "WRT";
         }
         */
        
        //PAY_ID CODE 신보일경우
        List<Integer> koditPayIds = Arrays.asList(1, 2, 3, 4, 6, 21, 23, 24, 26, 54, 56);
         
        if (koditPayIds.contains(this.xmlB311VO.PAY_ID)) {

            if(StrUtil.isEmpty(this.xmlB311VO.TAXAPPROVALNO)){ return setErrorResponse(commonElement, "0080", "승인번호를 읽을 수 없습니다."); }
            if(StrUtil.isEmpty(this.xmlB311VO.SBILL_SEQ)){     return setErrorResponse(commonElement, "0081", "세금계산서 정보가 없습니다.");  }
            if(StrUtil.isEmpty(this.xmlB311VO.BILL_DT) || StrUtil.nvl(this.xmlB311VO.BILL_DT).length() < 8){  return setErrorResponse(commonElement, "0082", "작성일자가 없거나 잘못된 작성일입니다."); }

            //TAX TOTALAMT CHK
            // double tax_total_amt = Double.parseDouble(this.xmlB311VO.TOTALAMT);
            double totalContractAmt = Double.parseDouble(this.xmlB311VO.TOTALCONTRACTAMT);
            double sumItemTotalAmt = Double.parseDouble(this.xmlB311VO.ITEM_TOTALAMT);
            
            /* RYAN-MIN : 아래로 대체 (검증요망)
            String strTotAmt = StrUtil.nvl(bean.GET_TAX_MONEY_LIMIT_CHK_PROC(intCtId, this.xmlB311VO.TAXAPPROVALNO, "S"), "0");
            if(tax_total_amt < Double.parseDouble(strTotAmt) + totalContractAmt){
                return setErrorResponse(commonElement, "0058", "계산서 총액을 초과하였습니다.");
            }
            //구매자금일때 세금계산서의 작성일 유효성 체크
            List<Integer> koditFundPayIds = Arrays.asList(4, 24, 54);
            
            //작성일 31일 체크 은행
            List<String> chkBnkcd = Arrays.asList("HN","SB","KB","UR","BS","KE","KN","KU","SC");
            
            //CT_BILL_MASTER INFO
            String bill_dt = this.xmlB311VO.BILL_DT;
            
            if (koditFundPayIds.contains(this.xmlB311VO.PAY_ID)) {
                //작성일 유효성 체크
                if (Integer.parseInt(bill_dt) < Integer.parseInt(DateTimeUtil.diff(DateTimeUtil.getCurrentDate(""), -30))) {    //30 일 이전 
                    if(chkBnkcd.contains(this.xmlB311VO.BNK_CD)){ //작성일 31일 체크 은행
                        if (checkAfterAddOneDate(bill_dt, 30)==false) {
                            return setErrorResponse(commonElement, "0094", "전자세금계산서 작성일자가 31일을 초과한 계산서입니다.");
                        }
                    } else {
                        return setErrorResponse(commonElement, "0094", "전자세금계산서 작성일자가 31일을 초과한 계산서입니다.");
                    }
                }
            }
            */
            // RYAN-MIN : 매매계약작성단계에서 검증하지만, 최종검증추가
           
            if (!new TradeBean().CHECK_SETTLED_SUM_PROC(this.xmlB311VO.TAXAPPROVALNO, this.xmlB311VO.TOTALCONTRACTAMT, this.xmlB311VO.CTID)) {
                return setErrorResponse(commonElement, "0058", "매매계약서의 결제금액 합계액이 세금계산서의 발행금액을 초과하였습니다.");
            }
            
            if (totalContractAmt != sumItemTotalAmt) {
                return setErrorResponse(commonElement, "1230", "거래총액과 품목 합계가 일치하지 않습니다.");
            }
            
            // RYAN-MIN (2025-03-28) : 세금계산서 작성일이 은행 결제신청마감일 기준을 초과하는지 검증(검증요망)
            List<Integer> koditFundPayIds = Arrays.asList(4, 24, 54); // 구매자금
            List<String> excludeBankAndPayCodes = Arrays.asList("HN____24", "KE____24","HN____104","KE____104","HN____124","KE____124"); // 구매자금 중에서도 예외인 은행
            if (koditFundPayIds.contains(this.xmlB311VO.PAY_ID)) { // 구매자금이면
               if (!excludeBankAndPayCodes.contains(this.xmlB311VO.BNK_CD + "____" + Integer.toString(this.xmlB311VO.PAY_ID))) { // 예외인 은행 및 결제수단이면
                   String today   = DateTimeUtil.getCurrentDate("");
                   String valDate = TradeBean.getPermittedDateOfTaxInvoice(StrUtil.extractInteger(this.xmlB311VO.BILL_DT), StrUtil.nvl(this.xmlB311VO.BNK_CD)); // 은행별 결제신청 마감일 가져옴
                   if (Integer.parseInt(today) > Integer.parseInt(valDate)) { // 마감일 기준이 지났으면
                       return setErrorResponse(commonElement, "0094", "(전자)세금계산서의 작성일이 은행의 결제신청 마감일 기준을 지났습니다.");
                   }
               }
            }
        }
        return commonElement;
    }
    
    
    /**
     * validate check
     */
    protected CommonElement validateProcess() throws Exception {
        CommonElement commonElement = new CommonElement();
        commonElement.setResponseCode("0000");
        // 거래제한프로세스는 매매계약서작성단계에서 검증되므로 생략. 필요하면 kr.co.mp.trade.ValidateCheck 실행
        // 거래불가
        // 보증서미등록
        // 구매기업 휴폐업
        // 판매기업 휴폐업
        return commonElement;
    }
    
    /**
     * this.xmlB311VO / basic data
     * this.xml_b311 / make xml date
     */
    protected void makeB31X(int intCtId, String p_user) throws Exception {
        
        LoanUtil loanUtil = new LoanUtil();

        String p_pay_id = Integer.toString(this.xmlB311VO.PAY_ID);
        // String pay_id = p_pay_id.substring(p_pay_id.length() - 1, p_pay_id.length());

        
        this.xmlB311VO.TRADEDATE = DateTimeUtil.getCurrentDate("");

        //계산서 승인번호 없으면 당일, 있으면 bill_dt
        this.xmlB311VO.CONTRACTDATE = StrUtil.isEmpty(this.xmlB311VO.TAXAPPROVALNO) ?  DateTimeUtil.getCurrentDate("") : this.xmlB311VO.BILL_DT;

        // 결제예정일
        if ("N".equalsIgnoreCase(this.strEditYn)) {
            this.xmlB311VO.SETTLEDUEDATE = bean.GET_BIZ_DATE_PROC(this.xmlB311VO.TRADEDATE, this.xmlB311VO.SETTLEMENTDUEDAYS, this.xmlB311VO.BNK_CD, this.xmlB311VO.BILL_DT);
            /*
            if (("HN".equals(this.xmlB311VO.BNK_CD)) || ("KE".equals(this.xmlB311VO.BNK_CD))) {
                this.xmlB311VO.SETTLEDUEDATE = bean.GET_BIZ_DATE_PROC(this.xmlB311VO.TRADEDATE, 6);    // 6일로
            }
            */
        } else { // RYAN-MIN : 일부은행의 요건에 따라 결제예정일을 오늘로 설정해서 전송(관리자전용)
            this.xmlB311VO.SETTLEDUEDATE = this.xmlB311VO.TRADEDATE;
        }
        
        this.xmlB311VO.APPRTIME = StrUtil.isEmpty(this.xmlB311VO.APPRTIME) ? DateTimeUtil.getCurrentDateTime() : this.xmlB311VO.APPRTIME;
        this.xmlB311VO.APRUSER = StrUtil.isEmpty(this.xmlB311VO.APRUSER) ? p_user : this.xmlB311VO.APPRTIME;

        this.xml_b311.setCtId(intCtId);
        this.xml_b311.setFund("KODIT");
        
        //xml_b311 Set
        this.xml_b311.setSender(this.MPCode);
        this.xml_b311.setTransactionSEQNO(SequenceGenerator.getInstance().getTransSeqNO());

        this.xml_b311.setReceiver(this.xmlB311VO.BNK_NO);

        this.xml_b311.setTransactionNO("B311");
        this.xml_b311.setTransactionDate(DateTimeUtil.getCurrentDate(""));
        this.xml_b311.setTransactionTime(DateTimeUtil.getCurrentDateTime().substring(8, 14));
        this.xml_b311.setResponseCode("0000");
        this.xml_b311.setResponseMessage(null);
        
        this.xml_b311.setUserField(StrUtil.isEmpty(this.xmlB311VO.USERFIELD) ? "" : this.xmlB311VO.USERFIELD);

        this.xml_b311.setSeqNO(loanUtil.getSeqNO_Kodit_xml_b311(this.xmlB311VO.CTNO));

        this.xml_b311.setTradeDate(this.xmlB311VO.TRADEDATE);
        this.xml_b311.setOrderNO(this.xmlB311VO.CTNO);
        this.xml_b311.setContractDate(this.xmlB311VO.CONTRACTDATE);
        this.xml_b311.setHandAcceptYN(this.xmlB311VO.HANDACCEPTYN); //수기접수여부(1.XML 2.수기)

        if (!"0".equals(this.xmlB311VO.TRADETYPE)) this.xml_b311.setContractType(this.xmlB311VO.TRADETYPE); //매매계약구분(1: 보호거래 2: 일반거래 3: 혼합거래)
        
        this.xml_b311.setBuyerID(StrUtil.isEmpty(this.xmlB311VO.CPYBUYER_INCORPORATE_NO) ? "0000000000000": this.xmlB311VO.CPYBUYER_INCORPORATE_NO.trim());
        this.xml_b311.setBuyerBusinessNO(this.xmlB311VO.CPYBUYER_BIZNO.trim());
        this.xml_b311.setSellerID(StrUtil.isEmpty(this.xmlB311VO.CPYSELLER_INCORPORATE_NO) ? "0000000000000": this.xmlB311VO.CPYSELLER_INCORPORATE_NO.trim());
        this.xml_b311.setSellerBusinessNO(this.xmlB311VO.CPYSELLER_BIZNO.trim());

        this.xml_b311.setTotalContractAMT(this.xmlB311VO.TOTALCONTRACTAMT);
        this.xml_b311.setSellerName(this.xmlB311VO.CPYSELLER_NM);

        if ("2".equalsIgnoreCase(this.xmlB311VO.MPPAYCPY)) {
            if ("Y".equals(this.xmlB311VO.FEETRANSFERYN)) {
                this.xml_b311.setBuyerFee(this.xmlB311VO.MPFEE_TOTALAMT);
                this.xml_b311.setSellerFee("0");
                this.xml_b311.setFeeType(this.xmlB311VO.MPPAYCPY);
            } else {
                this.xml_b311.setBuyerFee("0");
                this.xml_b311.setSellerFee("0");
                this.xml_b311.setFeeType("1");
            }
        } else if ("1".equalsIgnoreCase(this.xmlB311VO.MPPAYCPY)) {
            this.xml_b311.setBuyerFee("0");
            this.xml_b311.setSellerFee(this.xmlB311VO.MPFEE_TOTALAMT);
            this.xml_b311.setFeeType(this.xmlB311VO.MPPAYCPY);
        }

        //지급승인 코드 : (구매자금대출 only) 1. 자동승인 2. 지급승인 3. 추심등록 / (구매카드(구매론)) 4.결제처리완료 5.인수처리완료 6.자동할인구매론
        if ("Y".equals(this.paymentApprovalTypeYN)) {
            this.xml_b311.setPaymentApprovalType(this.xmlB311VO.PAYMENTAPPROVALTYPE);
            String strExceptionalTest           = (this.xmlB311VO.BNK_CD+"____"+Integer.toString(this.xmlB311VO.CPYBUYER)+"____"+Integer.toString(this.xmlB311VO.CPYSELLER)).toUpperCase();
            String strExceptionalTestOnlyBuyer  = (this.xmlB311VO.BNK_CD+"____"+Integer.toString(this.xmlB311VO.CPYBUYER)+"____X").toUpperCase();
            String strExceptionalTestOnlySeller = (this.xmlB311VO.BNK_CD+"____X____"+Integer.toString(this.xmlB311VO.CPYSELLER)).toUpperCase();
            String strExceptionalType1          = ConfigurationMgr.getInstance().getString("EXCEPTIONAL_APPROVAL_TYPE_1");
            String strExceptionalType2          = ConfigurationMgr.getInstance().getString("EXCEPTIONAL_APPROVAL_TYPE_2");
            
            if (strExceptionalType2.contains(strExceptionalTest) || strExceptionalType2.contains(strExceptionalTestOnlyBuyer) || strExceptionalType2.contains(strExceptionalTestOnlySeller)) {
                this.xml_b311.setPaymentApprovalType("2");
                this.xml_b311.setBuyerFee("0");
                this.xml_b311.setSellerFee(this.xmlB311VO.MPFEE_TOTALAMT);
                this.xml_b311.setFeeType("1");
            } else if (strExceptionalType1.contains(strExceptionalTest) || strExceptionalType1.contains(strExceptionalTestOnlyBuyer) || strExceptionalType1.contains(strExceptionalTestOnlySeller)) {
                this.xml_b311.setPaymentApprovalType("1");
            }
        }
        
        String billNo = this.xmlB311VO.BILL_NO;

        // BILL_NO 12자리 체크
        if(StrUtil.isEmpty(billNo)) {
            this.xml_b311.setTaxBillNO("000000000000");
        } else {
            this.xml_b311.setTaxBillNO(billNo.length() > 12 ? billNo.substring(billNo.length() - 12) : billNo);
        }
        
        this.xml_b311.setContractDate(this.xmlB311VO.BILL_DT);
        
        //get ct_item data
        xmlItemVO = new SoapCommonBean().GET_XML_B311_ITEM_PROC(this.xmlB311VO.CTID);
        
        //main item (last remove "외")
        String main_item = this.xmlItemVO.mainItem.ITEMNAME.trim();
        main_item = main_item.endsWith("외") ? main_item.substring(0, main_item.length() - 1).trim() : main_item.trim();
        
        //main item 30byte
        byte[] strByte = main_item.getBytes();
        String sub_item;

        // 30바이트 기준으로 자르기
        if (strByte.length <= 30) {
            sub_item = main_item;  // 길이가 30바이트 이하이면 그대로 사용
        } else {
            // 30바이트를 기준으로 잘라서 사용
            sub_item = new String(strByte, 0, 30);
        }
        
        this.xml_b311.setTaxBillDate(this.xmlB311VO.BILL_DT);
        this.xml_b311.setTaxBillAMT(this.xmlB311VO.TOTALAMT);
        this.xml_b311.setTaxBillSupplyAMT(this.xmlB311VO.PAY_SUM_AMOUNT);
        this.xml_b311.setMainItem(sub_item);
        this.xml_b311.setTaxApprovalNO(this.xmlB311VO.TAXAPPROVALNO);
    
        this.xml_b311.setSettlementScheduleCount(1);
        this.xml_b311.setScheduleSEQNO(1);
        this.xml_b311.setTradeType(this.xmlB311VO.TRADETYPE);
        this.xml_b311.setSettlementType(this.xmlB311VO.SETTLEMENTTYPE);
        this.xml_b311.setSettlementDueAMT(this.xmlB311VO.SETTLEAMT);
        this.xml_b311.setRefundAMT("0");
        this.xml_b311.setSettlementDueDate(this.xmlB311VO.SETTLEDUEDATE);
        this.xml_b311.setSettlementDueTime("2300");

        if ("Y".equals(this.xmlB311VO.PAYMENTDUEDATEYN)) 
            this.xml_b311.setPaymentDueDate(bean.GET_BIZ_DATE_PROC(this.xml_b311.getTradeDate(), Integer.parseInt(this.xmlB311VO.PAYMENTDUEDAYS), this.xmlB311VO.BNK_CD, this.xmlB311VO.BILL_DT));
        
        if ("Y".equals(this.xmlB311VO.EXPIRATIONDATEYN)) 
            this.xml_b311.setExpirationDate(this.xmlB311VO.MTYDATE);

        this.xml_b311.setOrderCount(this.xmlItemVO.allItems.size());
        this.xml_b311.setCreUser(p_user);
        this.xml_b311.setCreateTime(DateTimeUtil.getCurrentDateTime());

        for (int i = 0; i < this.xmlItemVO.allItems.size(); i++) {
            SoapCommonVO.XmlB311ItemVO ct_item = (SoapCommonVO.XmlB311ItemVO)this.xmlItemVO.allItems.get(i);

            B311ItemVO xml_b311_item = new B311ItemVO();
            xml_b311_item.setOrderno(this.xml_b311.getOrderNO());
            xml_b311_item.setSeqno(this.xml_b311.getSeqNO());
            xml_b311_item.setOrderseqno(i + 1);
            xml_b311_item.setItem(ct_item.ITEMNAME);

            if ("KE".equals(this.xmlB311VO.BNK_CD))
                xml_b311_item.setSize("개");
            else 
                xml_b311_item.setSize(ct_item.SIZE);
            
            xml_b311_item.setQuantity(ct_item.QTY);
            xml_b311_item.setQuantityunit(ct_item.UNIT);
            xml_b311_item.setUnitprice(ct_item.UNITPRICE);
            xml_b311_item.setSupplyamt(ct_item.SUPPLYAMT);
            xml_b311_item.setTaxamt(ct_item.TAXAMT);
            xml_b311_item.setTotalamt(ct_item.TOTALAMT);

            this.xml_b311_itemList.add(xml_b311_item);
        }
    }    
    
    /**
     * final ct_header / send_xml_b311 update 
     */
    protected void updateDBWithResponse(CommonElement p_commonElement) throws Exception {
        
        System.out.println("Response Code: " + p_commonElement.getResponseCode());
        System.out.println("Response Message: " + p_commonElement.getResponseMessage());
        
        sendXmlB311VO = new SoapCommonVO().new SendXmlB311VO();
        sendXmlB311VO.CTID = this.xml_b311.getCtId();
        sendXmlB311VO.STATUS = p_commonElement.getResponseCode().equals("0000") ? "040" : "030";
        sendXmlB311VO.SEQNO = this.xml_b311.getSeqNO();
        sendXmlB311VO.FUND = this.xml_b311.getFund();
        sendXmlB311VO.RESRESPONSECODE = p_commonElement.getResponseCode();
        sendXmlB311VO.RESRESPONSEMSG = p_commonElement.getResponseMessage();
        
        sendXmlB311VO.CONTRACTDATE = this.xml_b311.getContractDate();
        sendXmlB311VO.TRADEDATE = this.xml_b311.getTradeDate();
        sendXmlB311VO.SETTLEDUEDATE = this.xml_b311.getSettlementDueDate();
        
        sendXmlB311VO.TRANSACTIONNO = p_commonElement.getTransactionNO();
        
        bean.SEND_XML_B311_MOD_PROC(sendXmlB311VO);
        
        /**
         * 이 부분에 SMS 전송 넣기
         * 이 부분에 SMS 전송 넣기
         * 이 부분에 SMS 전송 넣기
         * 이 부분에 SMS 전송 넣기
         * 이 부분에 SMS 전송 넣기
         */
        String p_pay_id = Integer.toString(this.xmlB311VO.PAY_ID);
        String pay_id = p_pay_id.substring(p_pay_id.length() - 1, p_pay_id.length());
        if (sendXmlB311VO.STATUS.equals("040")) {
            if (("KB".equalsIgnoreCase(this.xmlB311VO.BNK_CD) || "SH".equalsIgnoreCase(this.xmlB311VO.BNK_CD) || "NH".equalsIgnoreCase(this.xmlB311VO.BNK_CD)) && "4".equalsIgnoreCase(pay_id)) {
                TalkCtrl.sendBySystem("M010", 0, sendXmlB311VO.CTID, 0);
            } else TalkCtrl.sendBySystem("M017", 0, sendXmlB311VO.CTID, 0);
        }
    }

    /**
     * 날짜 확인(영업일수 반영)
     * @param strCheckDate
     * @param intDays
     * @return
     */
    private boolean checkAfterAddOneDate(String strCheckDate, int intDays) {
        try {
        
            String bizdate = bean.GET_BIZ_DATE_PROC(strCheckDate, intDays, "XX", "");
            String nowdate = DateTimeUtil.getCurrentDate(""); // 20250101형식
        
            //DateTimeFormatter 정의
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
    
            LocalDate currentDate = LocalDate.parse(nowdate, formatter);
            LocalDate bizDate = LocalDate.parse(bizdate, formatter);
    
            return !currentDate.isAfter(bizDate);
    
        } catch (Exception e) {
            e.toString();
            return false;
        }
    }

    private CommonElement setErrorResponse(CommonElement commonElement, String responseCode, String responseMessage) {
        commonElement.setResponseCode(responseCode);
        commonElement.setResponseMessage(responseMessage);
        return commonElement;
    }

}
