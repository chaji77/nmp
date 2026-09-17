package kr.co.soap.kibo.loan.emtnet;

import java.text.ParseException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.List;

import kr.co.funology.fw.util.DateTimeUtil;
import kr.co.funology.fw.util.StrUtil;
import kr.co.mp.kakaotalk.TalkCtrl;
import kr.co.soap.controll.B311ItemVO;
import kr.co.soap.controll.EnumData;
import kr.co.soap.controll.LoanUtil;
import kr.co.soap.controll.SequenceGenerator;
import kr.co.soap.controll.SoapCommonBean;
import kr.co.soap.controll.SoapCommonVO;
import kr.co.soap.controll.XmlEnum;
import kr.co.soap.controll.CommonElement;
import kr.co.soap.kibo.loan.Kibo_b311;

public class EmtNetB311 extends Kibo_b311 {
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
    
    public CommonElement executeB311(int intCtId, String strEdit)
    {
        this.strEditYn = (strEdit==null) ? "N" : strEdit.trim();
        return super.executeB31X(intCtId);
    }
    
    @Override
    protected CommonElement readSyncTableData(int intCtId) throws Exception
    {
        
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
             return setErrorResponse(commonElement, "0080", "주문 품목정보를 읽을 수 없습니다.");
         if (EnumData.longNull == this.xmlB311VO.CPYBUYER) 
             return setErrorResponse(commonElement, "0081", "구매기업정보를 읽을 수 없습니다.");
         if (EnumData.longNull == this.xmlB311VO.CPYSELLER) 
             return setErrorResponse(commonElement, "0081", "판매기업정보를 읽을 수 없습니다.");
         if (null == this.xmlB311VO.BNK_CD) 
             return setErrorResponse(commonElement, "0082", "은행정보를 읽을 수 없습니다.");
         if (null == this.xmlB311VO.TAXISSUEYN) 
             return setErrorResponse(commonElement, "0091", "은행 대출상품정보를 읽을 수 없습니다.");
         
         /**
          * 기보거래제한 추가 해야됨....
          */

         super.taxIssueYN                 = this.xmlB311VO.TAXISSUEYN;                    //세금계산서 발행여부
         super.paymentApprovalTypeYN     = this.xmlB311VO.PAYMENTAPPROVALTYPEYN;            //지급승인 여부
         super.expirationDateYN         = this.xmlB311VO.EXPIRATIONDATEYN;                 //만기일 사용 여부
         super.paymentDueDateYN         = this.xmlB311VO.PAYMENTDUEDATEYN;                //대금지급예정일 사용여부

         /*
         //계산서 첨부형태 및 아이피 체크, 구리스크랩?
         this.ctHeaderEtcVO = bean.GET_CT_HEADER_ETC_INFO_PROC(intCtId);
        
         //20170809 조명희M요청 구매사 앨파스 적용유형 WRT로 박기
         if(this.xmlB311VO.CPYBUYER == 40623){
             this.ctHeaderEtcVO.TAX_SECTION = "WRT";
         }
         */
        
        //PAY_ID CODE 신보일경우
        List<Integer> kiboPayIds = Arrays.asList(11, 12, 13, 14, 16, 104, 124);
         
        if (kiboPayIds.contains(this.xmlB311VO.PAY_ID)) {

            if(StrUtil.isEmpty(this.xmlB311VO.TAXAPPROVALNO)){ return setErrorResponse(commonElement, "0080", "승인번호를 읽을 수 없습니다."); }
            if(StrUtil.isEmpty(this.xmlB311VO.SBILL_SEQ)){    return setErrorResponse(commonElement, "0081", "세금계산서 정보가 없습니다."); }
            if(StrUtil.isEmpty(this.xmlB311VO.BILL_DT) || StrUtil.nvl(this.xmlB311VO.BILL_DT).length() < 8){  return setErrorResponse(commonElement, "0082", "작성일자가 없거나 잘못된 작성일입니다."); }

            //TAX TOTALAMT CHK
            double tax_total_amt = Double.parseDouble(this.xmlB311VO.TOTALAMT);
            double totalContractAmt = Double.parseDouble(this.xmlB311VO.TOTALCONTRACTAMT);
            double sumItemTotalAmt = Double.parseDouble(this.xmlB311VO.ITEM_TOTALAMT);
            
            String strTotAmt = StrUtil.nvl(bean.GET_TAX_MONEY_LIMIT_CHK_PROC(intCtId, this.xmlB311VO.TAXAPPROVALNO, "S"), "0");
            if(tax_total_amt < Double.parseDouble(strTotAmt) + totalContractAmt){
                return setErrorResponse(commonElement, "0058", "계산서 총액을 초과하였습니다.");
            }
            
            if (totalContractAmt != sumItemTotalAmt) {
                return setErrorResponse(commonElement, "1230", "거래총액과 품목 합계가 일치하지 않습니다.");
            }
             
            //구매자금일때 세금계산서의 작성일 유효성 체크
            List<Integer> koditFundPayIds = Arrays.asList(14, 104, 124);
            
            //작성일 31일 체크 은행
            //List<String> chkBnkcd = Arrays.asList("HN","SB","KB","UR","BS","KE","KN","KU","SC");
            List<String> chkBnkcd = Arrays.asList("HN","SB","KB","UR","BS","KE","KU","SC","TB","NH");
            
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
            
        }                

        return commonElement;
    }
    
    /**
     * this.xmlB311VO / basic data
     * this.xml_b311 / make xml date
     */
    protected void makeB31X(int intCtId, String p_user) throws Exception {
        
        LoanUtil loanUtil = new LoanUtil();

        String p_pay_id = Integer.toString(this.xmlB311VO.PAY_ID);
        String pay_id = p_pay_id.substring(p_pay_id.length() - 1, p_pay_id.length());

        
        this.xmlB311VO.TRADEDATE = DateTimeUtil.getCurrentDate("");

        //계산서 승인번호 없으면 당일, 있으면 bill_dt
        this.xmlB311VO.CONTRACTDATE = StrUtil.isEmpty(this.xmlB311VO.TAXAPPROVALNO) ?  DateTimeUtil.getCurrentDate("") : this.xmlB311VO.BILL_DT;

        if ("N".equalsIgnoreCase(this.strEditYn)) {
            this.xmlB311VO.SETTLEDUEDATE = bean.GET_BIZ_DATE_PROC(this.xmlB311VO.TRADEDATE, this.xmlB311VO.SETTLEMENTDUEDAYS, this.xmlB311VO.BNK_CD, this.xmlB311VO.BILL_DT);
            /*
            if (("HN".equals(this.xmlB311VO.BNK_CD)) || ("KE".equals(this.xmlB311VO.BNK_CD))) {
                this.xmlB311VO.SETTLEDUEDATE = bean.GET_BIZ_DATE_PROC(this.xmlB311VO.TRADEDATE, 6);    // 6일로
            }
            */
        }
        
        this.xmlB311VO.APPRTIME = StrUtil.isEmpty(this.xmlB311VO.APPRTIME) ? DateTimeUtil.getCurrentDateTime() : this.xmlB311VO.APPRTIME;
        this.xmlB311VO.APRUSER = StrUtil.isEmpty(this.xmlB311VO.APRUSER) ? p_user : this.xmlB311VO.APPRTIME;

        this.xml_b311.setCtId(intCtId);
        this.xml_b311.setFund("KIBO");
        
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
        //this.xml_b311.setContractDate(this.xmlB311VO.CONTRACTDATE);
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
            if (("SB".equalsIgnoreCase(this.xmlB311VO.BNK_CD)) && (289 == this.xmlB311VO.CPYBUYER) && (327 == this.xmlB311VO.CPYSELLER)) {
                this.xml_b311.setPaymentApprovalType("2");
                this.xml_b311.setBuyerFee("0");
                this.xml_b311.setSellerFee(this.xmlB311VO.MPFEE_TOTALAMT);
                this.xml_b311.setFeeType("1");
            } else if ((("CB".equalsIgnoreCase(this.xmlB311VO.BNK_CD)) && (47194 == this.xmlB311VO.CPYSELLER)) || (("CB".equalsIgnoreCase(this.xmlB311VO.BNK_CD)) && (62020 == this.xmlB311VO.CPYBUYER) && (10117 == this.xmlB311VO.CPYSELLER)) || (("CB".equalsIgnoreCase(this.xmlB311VO.BNK_CD)) && (60120 == this.xmlB311VO.CPYBUYER) && (10117 == this.xmlB311VO.CPYSELLER)) || (("CB".equalsIgnoreCase(this.xmlB311VO.BNK_CD)) && (32211 == this.xmlB311VO.CPYBUYER) && (952 == this.xmlB311VO.CPYSELLER)) || (("CB".equalsIgnoreCase(this.xmlB311VO.BNK_CD)) && (14300 == this.xmlB311VO.CPYBUYER) && (10117 == this.xmlB311VO.CPYSELLER)) || (("CB".equalsIgnoreCase(this.xmlB311VO.BNK_CD)) && (14300 == this.xmlB311VO.CPYBUYER) && (79885 == this.xmlB311VO.CPYSELLER)) || (("CB".equalsIgnoreCase(this.xmlB311VO.BNK_CD)) && (56062 == this.xmlB311VO.CPYBUYER) && (32120 == this.xmlB311VO.CPYSELLER)) || (("CB".equalsIgnoreCase(this.xmlB311VO.BNK_CD)) && (14300 == this.xmlB311VO.CPYBUYER) && (109734 == this.xmlB311VO.CPYSELLER))) {
                this.xml_b311.setPaymentApprovalType("1");
            } else if (("SC".equalsIgnoreCase(this.xmlB311VO.BNK_CD)) && (71704L == this.xmlB311VO.CPYBUYER)) {
                this.xml_b311.setPaymentApprovalType("1");
            }
        } else if (("1".equalsIgnoreCase(pay_id)) && ("SB".equalsIgnoreCase(this.xmlB311VO.BNK_CD)) && (289L == this.xmlB311VO.CPYBUYER) && (442L == this.xmlB311VO.CPYSELLER)) {
            if ("1".equals(this.xmlB311VO.TRADETYPE)) this.xml_b311.setPaymentApprovalType("4");
            else this.xml_b311.setPaymentApprovalType("5");
            this.paymentApprovalTypeYN = "Y";
        }
        
        
        /**
         *    승인번호관련하여 무조건 있는지 다시 한번 체크 
         */
        /*
        if (!StrUtil.isEmpty(this.xmlB311VO.TAXAPPROVALNO)) {
            long chk_sbill_seq = 0L;
            String direct_input_flag = "";
            ReadTable rt = null;
    
            SelectManager sm = new SelectManager("CT_BILL_MASTER_DATE");
            sm.setBindString(":APP_NO", this.xmlB311VO.getTaxapprovalno());
            ArrayList arr_dt = sm.execute();
    
            CT_BILL_MASTER_DATE ct_send_dt = (CT_BILL_MASTER_DATE)arr_dt.get(0);
    
            chk_sbill_seq = ct_send_dt.getSbill_seq();
            Ct_bill_masterPK ct_bill_masterPK = new Ct_bill_masterPK(Double.parseDouble(Long.toString(chk_sbill_seq)));
            rt = new ReadTable(ct_bill_masterPK);
            Ct_bill_master ct_bill_master = (Ct_bill_master)rt.execute();
            direct_input_flag = StrUtil.clean(ct_bill_master.getEtc_col3());

            //기업은행 AND 구매자금 일때
            //35일 더함 BILL_DT 작성일자에
            //결제예정일이 36일 초과건인지 체크
            if (("KU".equals(this.xmlB311VO.BNK_CD)) && (
                    (this.xmlB311VO.getPay_id() == 4L) || (this.xmlB311VO.getPay_id() == 54L) || (this.xmlB311VO.getPay_id() == 24L))) {
                String check_bill_dt = DateUtil.afterSpecDay(ct_bill_master.getBill_dt(), 35);
                String settleduedate = this.xmlB311VO.getSettleduedate();

                if (Long.parseLong(settleduedate) > Long.parseLong(check_bill_dt)) {
                    System.out.println("=============기업은행 계산서 36일 초과건==============");

                    MP1_PRE_BIZDAYDAO dao = new MP1_PRE_BIZDAYDAO();
                    ArrayList list = new ArrayList();
                    list = dao.MP1_PRE_BIZDAY(settleduedate);
        
                    if ((list != null) && (list.size() > 0)) {
                        MP1_PRE_BIZDAYVO listVO = new MP1_PRE_BIZDAYVO();
                        listVO = (MP1_PRE_BIZDAYVO)list.get(0);
                        settleduedate = listVO.DATE;
                        this.xmlB311VO.setSettleduedate(settleduedate);
                    }
                }
            }

            System.out.println("결제예정일 : " + this.xmlB311VO.getSettleduedate());

            sm = new SelectManager("TAX_WRITE_DATEVO");
            sm.setBindString(":APP_NO", this.xmlB311VO.getTaxapprovalno());
            ArrayList arr_taxdate = sm.execute();

            TAX_WRITE_DATEVO dt_value = (TAX_WRITE_DATEVO)arr_taxdate.get(0);

            //영세 이고 direct_input_flag ??
            if (("E".equals(this.xmlB311VO.getTaxbiztype())) && (!StrUtil.isEmpty(direct_input_flag))) {
                sm = new SelectManager("CT_BILL_MASTER_FREE_DATE");
                sm.setBindString(":APP_NO", this.xmlB311VO.getTaxapprovalno());
                sm.setBindString(":CTID", String.valueOf(this.xmlB311VO.getCtid()));
                ArrayList free_taxdate = sm.execute();

                CT_BILL_MASTER_FREE_DATE free_send_dt = (CT_BILL_MASTER_FREE_DATE)free_taxdate.get(0);

                this.xmlB311VO.setContractdate(free_send_dt.getSend_date().substring(0, 8));
                this.xml_b311.setContractdate(free_send_dt.getSend_date().substring(0, 8));

                this.xml_b311.setContractdate(free_send_dt.getBill_dt());

                if ((free_send_dt.getBill_no().trim().length() > 12) && (!StrUtil.isEmpty(free_send_dt.getBill_no())))
                    this.xml_b311.setTaxbillno(free_send_dt.getBill_no().substring(free_send_dt.getBill_no().length() - 12, free_send_dt.getBill_no().length()));
                else if ((free_send_dt.getBill_no().trim().length() <= 12) && (!StrUtil.isEmpty(free_send_dt.getBill_no())))
                    this.xml_b311.setTaxbillno(free_send_dt.getBill_no());
                else if (StrUtil.isEmpty(free_send_dt.getBill_no())) 
                    this.xml_b311.setTaxbillno("000000000000");

                this.xml_b311.setTaxbilldate(free_send_dt.getSend_date().substring(0, 8));
                this.xml_b311.setTaxbillamt(free_send_dt.getTotalamt());
                this.xml_b311.setTaxbillsupplyamt(free_send_dt.getPay_sum_amount());
            } else {
                this.xmlB311VO.setContractdate(dt_value.getTax_dt());
                this.xml_b311.setContractdate(dt_value.getTax_dt());
            }
            */
            
        String billNo = this.xmlB311VO.BILL_NO;
        
        /**
         * 영세일때 데이터 확인..
         */
        /*
        if("E".equals(this.xmlB311VO.TAXBIZTYPE)) {
            if (!StrUtil.isEmpty(billNo)) {
                billNo = billNo.trim();
                this.xml_b311.setTaxBillNO(billNo.length() > 12 ? billNo.substring(billNo.length() - 12) : billNo);
            } else {
                this.xml_b311.setTaxBillNO("000000000000");
            }
            
            //this.xml_b311.setTaxbilldate(free_send_dt.getSend_date().substring(0, 8));
            this.xml_b311.setTaxBillDate(this.xmlB311VO.BILL_DT);
            this.xml_b311.setTaxBillAMT(this.xmlB311VO.TOTALAMT);
            this.xml_b311.setTaxBillSupplyAMT(this.xmlB311VO.PAY_SUM_AMOUNT);

        }
        */
        
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

        if ("Y".equals(this.xmlB311VO.PAYMENTDUEDATEYN)) this.xml_b311.setPaymentDueDate(bean.GET_BIZ_DATE_PROC(this.xmlB311VO.TRADEDATE, Integer.parseInt(this.xmlB311VO.PAYMENTDUEDAYS), this.xmlB311VO.BNK_CD, this.xmlB311VO.BILL_DT));
        if ("Y".equals(this.xmlB311VO.EXPIRATIONDATEYN)) this.xml_b311.setExpirationDate(this.xmlB311VO.MTYDATE);

        this.xml_b311.setOrderCount(this.xmlItemVO.allItems.size());
        this.xml_b311.setCreUser(p_user);
        this.xml_b311.setCreateTime(DateTimeUtil.getCurrentDateTime());
        
        //재단 추가..
        if (this.xmlB311VO.PAY_ID > 100)
        {
            this.xml_b311.setOrgCode(XmlEnum.getOrgCode(this.xmlB311VO.PAY_ID));
        }
        else {
            this.xml_b311.setOrgCode("");
        }

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
        
        /**
         * 기보예외 추가 여부 확인
         */
        
        bean.SEND_XML_B311_MOD_PROC(sendXmlB311VO);
        
        /**
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
    
    
    /**
     * validate check
     */
    protected CommonElement validateProcess() throws Exception {
        
        CommonElement commonElement = new CommonElement();
        commonElement.setResponseCode("0000");

        return commonElement;
    }
    
    private CommonElement setErrorResponse(CommonElement commonElement, String responseCode, String responseMessage) {
        commonElement.setResponseCode(responseCode);
        commonElement.setResponseMessage(responseMessage);
        return commonElement;
    }
    
public static void main(String[] agrs) throws ParseException {
        
        try
        {
          EmtNetB311 b311 = new EmtNetB311();
          CommonElement commonElement = b311.executeB311(2024090, "N");
          System.out.println(commonElement.getResponseCode() + ":" + commonElement.getResponseMessage());
        }
        catch (Exception ex)
        {
          ex.printStackTrace();
        }
        /*
        System.out.println(DateTimeUtil.getCurrentDate(""));
        
        System.out.println(DateTimeUtil.diff(DateTimeUtil.getCurrentDate(""), 30));
        System.out.println(DateTimeUtil.diff(DateTimeUtil.getCurrentDate(""), -30));
        System.out.println("1111".length());
        System.out.println(StrUtil.isEmpty(""));
        System.out.println(DateTimeUtil.getCurrentDateTime());
        
        this.header.setTradedate(DateUtil.getCurrentDate());
        
        if (StringUtil.isEmpty(this.header.getTaxapprovalno())) {
              this.header.setContractdate(DateUtil.getCurrentDate());
            }
        
        this.header.setSettleduedate(getsettle.getDate()); if 조건
        
        # 최초에 넣는지 확인
        this.header.setApprtime(DateUtil.getCurrentDateTime()); 
        this.header.setApruser(p_user);
                */
    }
    
}
