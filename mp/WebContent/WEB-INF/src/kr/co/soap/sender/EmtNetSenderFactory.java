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
		
		if ("A311S".equals(xmlGubn)) {
		    if ("KODIT".equals(fund)) {
		        kr.co.soap.kodit.loan.emtnet.EmtNetA311S sender =
		            new kr.co.soap.kodit.loan.emtnet.EmtNetA311S(
		                vo.cpyId, vo.bnkCd, vo.payId, vo.amt,
		                vo.sellerBizNo, vo.sellerCorpNo);
		        return new EmtNetA311SAdapter(sender);
		    }
		}

		// ★ C211 담보보증 신청 분기 추가
		if ("C211".equals(xmlGubn)) {
		    if ("KODIT".equals(fund)) {
		        kr.co.soap.kodit.loan.emtnet.EmtNetC211 sender =
		            new kr.co.soap.kodit.loan.emtnet.EmtNetC211(vo.applNo, vo.creUser);
		        return new EmtNetC211Adapter(sender);
		    }
		}

		// ★ B211 매매계약서 발송 분기 추가
		if ("B211".equals(xmlGubn)) {
		    if ("KODIT".equals(fund)) {
		        kr.co.soap.kodit.loan.emtnet.EmtNetB211 sender =
		            new kr.co.soap.kodit.loan.emtnet.EmtNetB211(vo.orderNo, vo.b211SeqNo);
		        return new EmtNetB211Adapter(sender);
		    }
		}

		// ★ K231 결제전문 발송 분기 추가
		if ("K231".equals(xmlGubn)) {
		    if ("KODIT".equals(fund)) {
		        kr.co.soap.kodit.loan.emtnet.EmtNetK231 sender =
		            new kr.co.soap.kodit.loan.emtnet.EmtNetK231(vo.orderNo, vo.k231SeqNo);
		        return new EmtNetK231Adapter(sender);
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
