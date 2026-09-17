package kr.co.soap.sender;

import kr.co.soap.controll.CommonElement;

public class EmtNetB311Adapter implements EmtNetSender {

	private final Object sender; 
    private final int ctId;
    private final String editGubun;
    
    public EmtNetB311Adapter(Object sender, EmtNetSenderVO vo) {
        this.sender = sender;
        this.ctId = vo.ctId;
        this.editGubun = vo.editGubun;
    }
	
	@Override
	public Object execute() throws Exception {
		if (sender instanceof kr.co.soap.kodit.loan.emtnet.EmtNetB311) {
            return ((kr.co.soap.kodit.loan.emtnet.EmtNetB311) sender).executeB311(ctId, editGubun);
        } else if (sender instanceof kr.co.soap.kibo.loan.emtnet.EmtNetB311) {
            return ((kr.co.soap.kibo.loan.emtnet.EmtNetB311) sender).executeB311(ctId, editGubun);
        } else {
            return errorMsg();
        }
	}
	
	private CommonElement errorMsg() throws Exception {
        CommonElement commonElement = new CommonElement();
        commonElement.setResponseCode("4444");
        commonElement.setResponseMessage("지원하지 않는 B311 클래스입니다.");
        return commonElement;
    }

}
