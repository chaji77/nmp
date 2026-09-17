package kr.co.soap.kibo.loan.emtnet;

import org.w3c.dom.Document;

import kr.co.soap.kibo.loan.Kibo_K3XX;

public class EmtNetB413 extends Kibo_K3XX {
	
	public EmtNetB413(Document doc) {
        super(doc);
    }

	public void executeB413() throws Exception {

        System.out.println("################ B413 START ################");
        processByK3XX();
        System.out.println("################ B413 END ################");
    }

    /**
     * Kibo_K3XX에서 상속받은 필수 구현 메소드
     */
    @Override
    protected void processByK3XX() throws Exception {

        System.out.println("processByK3XX - B413");
    }
}