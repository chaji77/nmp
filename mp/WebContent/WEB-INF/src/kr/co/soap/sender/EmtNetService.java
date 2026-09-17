package kr.co.soap.sender;

import kr.co.soap.controll.A312VO;
import kr.co.soap.controll.CommonElement;
import kr.co.soap.controll.SoapCommonBean;

public class EmtNetService {
	
	public static Object execute(EmtNetSenderVO vo) throws Exception {
		SoapCommonBean bean = new SoapCommonBean();

		String fund;
		// ★ C211(담보보증)은 신보 고정 → GET_FUND_PROC 우회
		//   TODO(4): 향후 다기관 대응 필요 시 분기 추가
		if ("C211".equals(vo.xmlGubn)) {
			fund = "KODIT";
		} else {
			String gubun = ("A311".equals(vo.xmlGubn) || "A311S".equals(vo.xmlGubn)) ? "N" : "Y";
			fund = bean.GET_FUND_PROC(vo.ctId, gubun, vo.payId);
		}

        EmtNetSender sender = EmtNetSenderFactory.getSender(vo.xmlGubn, fund, vo);
        return sender.execute();
    }
	
	public static void main(String[] agrs) throws Exception {
		EmtNetSenderVO vo = new EmtNetSenderVO();
		vo.xmlGubn = "C211";
		vo.applNo  = "EMTNET-20260604-0001";
		vo.creUser = "tester";

		Object response = EmtNetService.execute(vo);

		if (response instanceof kr.co.soap.controll.C212VO) {
			kr.co.soap.controll.C212VO tranVo = (kr.co.soap.controll.C212VO) response;
			System.out.println(tranVo.getCommonElement().getResponseCode());
			System.out.println(tranVo.getCommonElement().getResponseMessage());
		}
	}
	
}
