package kr.co.soap.sender;

public class EmtNetSenderFactory {
	
	public static EmtNetSender getSender(String xmlGubn, String fund, EmtNetSenderVO vo) {
		
		if ("A181".equals(xmlGubn)) {
            if ("KODIT".equals(fund)) {
            	kr.co.soap.kodit.loan.emtnet.EmtNetA181OfB311 sender = new kr.co.soap.kodit.loan.emtnet.EmtNetA181OfB311(vo.ctId, vo.seqNo);
                return new EmtNetA181OfB311Adapter(sender);
            } else if ("KIBO".equals(fund)) {
            	kr.co.soap.kibo.loan.emtnet.EmtNetA181OfB311 sender = new kr.co.soap.kibo.loan.emtnet.EmtNetA181OfB311(vo.ctId, vo.seqNo);
                return new EmtNetA181OfB311Adapter(sender);
            }
        }

		if ("A311".equals(xmlGubn)) {
	        if ("KODIT".equals(fund)) {
	        	kr.co.soap.kodit.loan.emtnet.EmtNetA311 sender = new kr.co.soap.kodit.loan.emtnet.EmtNetA311(vo.cpyId, vo.bnkCd, vo.payId, vo.amt);
	            return new EmtNetA311Adapter(sender);
	        } else if ("KIBO".equals(fund)) {
	        	kr.co.soap.kibo.loan.emtnet.EmtNetA311 sender = new kr.co.soap.kibo.loan.emtnet.EmtNetA311(vo.cpyId, vo.bnkCd, vo.payId, vo.amt);
	            return new EmtNetA311Adapter(sender);
	        }
	    }
		
		if ("B311".equals(xmlGubn)) {
	        if ("KODIT".equals(fund)) {
	        	kr.co.soap.kodit.loan.emtnet.EmtNetB311 sender = new kr.co.soap.kodit.loan.emtnet.EmtNetB311();
	            return new EmtNetB311Adapter(sender, vo);
	        } else if ("KIBO".equals(fund)) {
	        	kr.co.soap.kibo.loan.emtnet.EmtNetB311 sender = new kr.co.soap.kibo.loan.emtnet.EmtNetB311();
	            return new EmtNetB311Adapter(sender, vo);
	        }
	    }
		
		if ("B315".equals(xmlGubn)) {
	        if ("KODIT".equals(fund)) {
	        	kr.co.soap.kodit.loan.emtnet.EmtNetB315 sender = new kr.co.soap.kodit.loan.emtnet.EmtNetB315();
	            return new EmtNetB315Adapter(sender, vo);
	        } else if ("KIBO".equals(fund)) {
	        	kr.co.soap.kibo.loan.emtnet.EmtNetB315 sender = new kr.co.soap.kibo.loan.emtnet.EmtNetB315();
	            return new EmtNetB315Adapter(sender, vo);
	        }
	    }

		throw new IllegalArgumentException("지원하지 않는 전문 또는 보증기관: " + xmlGubn + "/" + fund);
	
	}
}
