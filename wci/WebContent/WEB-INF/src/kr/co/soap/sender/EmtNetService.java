package kr.co.soap.sender;

import kr.co.soap.controll.A312VO;
import kr.co.soap.controll.CommonElement;
import kr.co.soap.controll.SoapCommonBean;

public class EmtNetService {
	
	public static Object execute(EmtNetSenderVO vo) throws Exception {
		SoapCommonBean bean = new SoapCommonBean();
		String gubun = "A311".equals(vo.xmlGubn) ? "N" : "Y";
        String fund = bean.GET_FUND_PROC(vo.ctId, gubun, vo.payId);
        EmtNetSender sender = EmtNetSenderFactory.getSender(vo.xmlGubn, fund, vo);
        return sender.execute();
    }
	
	public static void main(String[] agrs) throws Exception {
		EmtNetSenderVO vo = new EmtNetSenderVO();
		//vo.xmlGubn = "A311";
		//vo.xmlGubn = "A181";
		vo.xmlGubn = "B311";
		vo.ctId = 2024383;
		vo.cpyId = 122300;
		vo.bnkCd = "SB";
		vo.payId = 14;
		vo.amt = 0.0;
		vo.seqNo = "00001";
		vo.editGubun = "N";

		Object response = EmtNetService.execute(vo);
		
		if(response instanceof CommonElement) {
			CommonElement tranVo = (CommonElement) response;
			System.out.println(tranVo.getResponseCode());
		}
		
		/*
		if(response instanceof A312VO) {
			A312VO tranVo = (A312VO) response;
			System.out.println(tranVo.getCommonElement().getResponseCode());
			System.out.println(tranVo.getBankLimitAMT());
		}
		*/
	}
	
}
