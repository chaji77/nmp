package kr.co.mp.c.qna;

import kr.co.mp.common.CommonVO;

public class QnaVO extends CommonVO {
	
	public int    SEQ;
	public int    CPY_ID;
	public String REG_NM;
	public int    MGR_ID;
	public String Q_TITLE;
	public String Q_CONTENTS;
	public String A_CONTENTS;
	public String ANS_YN;
	public String REG_DT;
	
	public String CPY_NAME;
	
	@Override
	public String toString() {
     return "QnaVO {" +
             "SEQ=" + SEQ +
           ", CPY_ID=" + CPY_ID +
           ", REG_NM='" + REG_NM + '\'' +
           ", MGR_ID=" + MGR_ID +
           ", Q_TITLE='" + Q_TITLE + '\'' +
           ", Q_CONTENTS='" + Q_CONTENTS + '\'' +
           ", A_CONTENTS='" + A_CONTENTS + '\'' +
           ", ANS_YN='" + ANS_YN + '\'' +
           ", REG_DT=" + REG_DT +
           '}';
    }
}