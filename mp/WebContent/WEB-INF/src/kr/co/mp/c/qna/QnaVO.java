package kr.co.mp.c.qna;

import java.util.LinkedHashMap;
import java.util.Map;

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
  	public String Q_CODE;

	public String CPY_NAME;

	private static final Map<String, String> Q_TYPE_MAP = new LinkedHashMap<>();
	static {
		Q_TYPE_MAP.put("10", "일반문의");
		Q_TYPE_MAP.put("20", "거래문의");
		Q_TYPE_MAP.put("30", "오류문의");
		Q_TYPE_MAP.put("40", "기타문의");
	}

	public static Map<String, String> getQTypeMap() {
		return Q_TYPE_MAP;
	}

	public static String getQCodeLabel(String code) {
		String label = Q_TYPE_MAP.get(code);
		return (label != null) ? label : kr.co.funology.fw.util.StrUtil.nvl(code);
	}
	
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
           ", Q_CODE='" + Q_CODE + '\'' +
           '}';
    }
}