package kr.co.soap.sender;

import kr.co.soap.controll.CommonElement;

public class EmtNetB315Adapter implements EmtNetSender {

	private final Object sender; 
    private final int ctId;
    
    public EmtNetB315Adapter(Object sender, EmtNetSenderVO vo) {
        this.sender = sender;
        this.ctId = vo.ctId;
    }
    
	@Override
	public Object execute() throws Exception {
		
		System.out.println("Sender class: " + sender.getClass().getName());
		
		if (sender instanceof kr.co.soap.kodit.loan.emtnet.EmtNetB315) {
            return ((kr.co.soap.kodit.loan.emtnet.EmtNetB315) sender).executeB315(ctId);
        } else if (sender instanceof kr.co.soap.kibo.loan.emtnet.EmtNetB315) {
            return ((kr.co.soap.kibo.loan.emtnet.EmtNetB315) sender).executeB315(ctId);
        } else {
            return errorMsg();
        }
	}
	
	private CommonElement errorMsg() throws Exception {
        CommonElement commonElement = new CommonElement();
        commonElement.setResponseCode("4444");
        commonElement.setResponseMessage("지원하지 않는 B315 클래스입니다.");
        return commonElement;
    }
	
}
