package kr.co.soap.sender;

import kr.co.soap.controll.CommonElement;

public class EmtNetA181OfB311Adapter implements EmtNetSender {
	
	private final Object sender; 
    
    public EmtNetA181OfB311Adapter(Object sender) {
        this.sender = sender;
    }

    @Override
	public Object execute() throws Exception {
        if (sender instanceof kr.co.soap.kodit.loan.emtnet.EmtNetA181OfB311) {
            return ((kr.co.soap.kodit.loan.emtnet.EmtNetA181OfB311) sender).executeA181OfB311();
        } else if (sender instanceof kr.co.soap.kibo.loan.emtnet.EmtNetA181OfB311) {
            return ((kr.co.soap.kibo.loan.emtnet.EmtNetA181OfB311) sender).executeA181OfB311();
        } else {
        	return errorMsg();
        }
	}
    
    private CommonElement errorMsg() throws Exception {
        CommonElement commonElement = new CommonElement();
        commonElement.setResponseCode("4444");
        commonElement.setResponseMessage("지원하지 않는 A181 클래스입니다.");
        return commonElement;
    }
}
