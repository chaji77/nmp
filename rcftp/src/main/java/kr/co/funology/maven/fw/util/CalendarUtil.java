package kr.co.funology.maven.fw.util;

import java.text.ParseException;
import java.util.Calendar;
import java.util.HashMap;

import kr.co.funology.maven.fw.GlobalEnv;


/**
 * Calendar Utility
 * 
 * <pre>
 * 
 * 1. Usage
 * 
 *    &lt;body&gt;
 *    &lt;script&gt;
 *    &lt;!--
 *    function viewCalendar(calendar) {
 *      var j = 0;
 *      document.write("&lt;table border=0 cellpadding=3 cellspacing=1 bgcolor=#cccccc&gt;");
 *      document.write("&lt;tr bgcolor='white'&gt;");
 *      document.write("&lt;td colspan=7 align='center'&gt;");
 *      document.write(calendar.title);
 *      document.write("&lt;/td&gt;");
 *      document.write("&lt;/tr&gt;");
 *      document.write("&lt;tr bgcolor='white'&gt;");
 *      for (var i=0; i&lt;calendar.content.length; i++) {
 *        if (j%7==0 &amp;&amp; i&gt;0) document.write("&lt;/tr&gt;&lt;tr bgcolor='white'&gt;");
 *        document.write("&lt;td width=150&gt;&lt;ul&gt;");
 *        if (calendar.content[i].week==6) document.write("&lt;font color='blue'&gt;");
 *        if (calendar.content[i].holiday==true || calendar.content[i].week==0) document.write("&lt;font color='red'&gt;");
 *        document.write("&lt;li class='solar'&gt;" + calendar.content[i].solar.substring(3) + "&lt;/li&gt;");
 *        document.write("&lt;li class='lunar'&gt;" + calendar.content[i].lunar + "&lt;/li&gt;");
 *        document.write("&lt;li class='name'&gt;"  + calendar.content[i].name  + "&lt;/li&gt;");
 *        document.write("&lt;/ul&gt;&lt;/td&gt;");
 *        j++;
 *      }
 *      document.write("&lt;/tr&gt;");
 *      document.write("&lt;/table&gt;");
 *    }
 *    
 *    viewCalendar(&lt;%=CalendarUtil.getCalendar(2012, 4, ".")%&gt;);
 *    viewCalendar(&lt;%=CalendarUtil.getCalendar(2012, 8, ".")%&gt;);
 *    //--&gt;
 *    &lt;/script&gt;
 *    &lt;/body&gt;
 * 
 * </pre>
 * 
 * @author DOLGAMZA
 * @version 1.0
 * @since 2012.08
 *
 */
public class CalendarUtil {
	
	
	private CalendarUtil() {}
	
	/**
	 * 양력국경일
	 * 
	 * @return 양력국경일정보
	 */
	private static HashMap<String, String> getSolarHoliday() {
		HashMap<String, String> h = new HashMap<String, String>();
		h.put("0101", "신정");
		h.put("0301", "삼일절");
		h.put("0501", "근로자의 날");
		h.put("0505", "어린이날");
		h.put("0606", "현충일");
		h.put("0815", "광복절");
		h.put("1003", "개천절");
		h.put("1009", "한글날");
		h.put("1225", "성탄절");
		return h;
	}
	
	/**
	 * 음력국경일
	 * 
	 * @return 음력국경일정보
	 */
	private static HashMap<String, String> getLunarHoliday() {
		HashMap<String, String> h = new HashMap<String, String>();
		h.put("0101", "설날");
		h.put("0102", "");
		h.put("0408", "석가탄신일");
		h.put("0814", "");
		h.put("0815", "추석");
		h.put("0816", "");
		return h;
	}
	
	
	/**
	 * 조회대상 날짜의 요일
	 * 
	 * @param strDate      조회대상 날짜
	 * @param strSeparator 년월일의 구분자
	 * @return Week(Numeric-Style)
	 */
	public static int getWeekDay(String strDate, String strSeparator) {
		strSeparator = StrUtil.nvl(strSeparator, GlobalEnv.GLOBAL_DATE_SEPERATOR);
		strDate      = (strSeparator.equals(".")) ? strDate.replaceAll("[.]", "-") : strDate.replaceAll(strSeparator, "-");
		String[] arr       = strDate.split("-");
		Calendar oCalendar = Calendar.getInstance();
		oCalendar.set(Integer.parseInt(arr[0]), Integer.parseInt(arr[1])-1, Integer.parseInt(arr[2]));
		return oCalendar.get(Calendar.DAY_OF_WEEK)-1;
	}
	

	/**
	 * 양력국경일이면 명칭을 리턴
	 * 
	 * @param strDate      조회대상 날짜
	 * @param strSeparator 년월일의 구분자
	 * @return 양력국경일명칭
	 */
	private static String getSolarHoliday(String strDate, String strSeparator) {
		String[] arr  = (strSeparator.equals(".")) ? strDate.replaceAll("[.]", "-").split("-") : strDate.replaceAll(strSeparator, "-").split("-");
		String   str  = "";
		HashMap<String, String> hmSolarHoliday = getSolarHoliday();
		for (int i=0; i<hmSolarHoliday.size(); i++) {
			if (hmSolarHoliday.get(arr[1]+arr[2]) != null) {
				str = hmSolarHoliday.get(arr[1]+arr[2]);
				break;
			}
		}
		return str;
	}
	
	/**
	 * 음력국경일이면 명칭을 리턴
	 * 
	 * @param strDate      조회대상 날짜
	 * @param strSeparator 년월일의 구분자
	 * @return 음력국경일명칭
	 */
	private static String getLunarHoliday(String strDate, String strSeparator) {
		String[] arr  = (strSeparator.equals(".")) ? strDate.replaceAll("[.]", "-").split("-") : strDate.replaceAll(strSeparator, "-").split("-");
		String   str  = "";
		HashMap<String, String> hmLunarHoliday = getLunarHoliday();
		for (int i=0; i<hmLunarHoliday.size(); i++) {
			if (hmLunarHoliday.get(arr[1]+arr[2]) != null) {
				str = hmLunarHoliday.get(arr[1]+arr[2]);
				break;
			}
		}
		return str;
	}
	
	/**
	 * 조회대상 날짜가 국경일이면 명칭을 리턴
	 * 
	 * @param strDate      조회대상 날짜
	 * @param strSeparator 년월일의 구분자
	 * @return 국경일명칭
	 * @throws ParseException
	 */
	private static String getDateName(String strDate, String strSeparator) throws ParseException {
		String strSolarHoliday = getSolarHoliday(strDate, strSeparator);
		String strLunarHoliday = getLunarHoliday(DateTimeUtil.convertSolarToLunar(strDate, strSeparator), strSeparator);
		return (strSolarHoliday.length()<1) ? strLunarHoliday : strSolarHoliday;
	}

	/**
	 * 조회대상 날짜가 휴일인지 아닌지 조회
	 * 
	 * @param strDate      날짜
	 * @param strSeparator 년월일 구분자
	 * @return 휴일여부
	 * @throws ParseException
	 */
	private static boolean isDayOff(String strDate, String strSeparator) throws ParseException {
		boolean isDayOff = false;
		String[] arr  = (strSeparator.equals(".")) ? strDate.replaceAll("[.]", "-").split("-") : strDate.replaceAll(strSeparator, "-").split("-");
		
		// 양력휴일검색
		HashMap<String, String> hmSolarHoliday = getSolarHoliday();
		for (int i=0; i<hmSolarHoliday.size(); i++) {
			if (hmSolarHoliday.get(arr[1]+arr[2]) != null) {
				isDayOff = true;
				break;
			}
		}

		// 음력휴일검색
		if (isDayOff == false) {
			String   strLunarDate = DateTimeUtil.convertSolarToLunar(strDate, strSeparator);
			arr  = (strSeparator.equals(".")) ? strLunarDate.replaceAll("[.]", "-").split("-") : strLunarDate.replaceAll(strSeparator, "-").split("-");
			HashMap<String, String> hmLunarHoliday = getLunarHoliday();
			for (int i=0; i<hmLunarHoliday.size(); i++) {
				if (hmLunarHoliday.get(arr[1]+arr[2]) != null) {
					isDayOff = true;
					break;
				}
			}
		}

		// 음력 연말일 휴일처리
		if (isDayOff == false) {
			String strPreviousLunarDate = DateTimeUtil.convertSolarToLunar(DateTimeUtil.diff(strDate, -1, strSeparator), strSeparator);
			arr  = (strSeparator.equals(".")) ? strPreviousLunarDate.replaceAll("[.]", "-").split("-") : strPreviousLunarDate.replaceAll(strSeparator, "-").split("-");
			if ((arr[1] + arr[2]).equals("0101")) isDayOff = true;
		}
		
		return isDayOff;
	}
	

	
	/**
	 * JSON형태의 달력
	 * 
	 * @param year         년
	 * @param month        월
	 * @param strSeparator 년월일구분자
	 * @return 달력
	 * @throws ParseException
	 */
	public static String getCalendar(int year, int month, String strSeparator, HashMap<String, String> holidays) throws ParseException {
		strSeparator = StrUtil.nvl(strSeparator, GlobalEnv.GLOBAL_DATE_SEPERATOR);
		if (year < 1881 || year > 2040 || month < 1 || month > 12) return null;
		if (strSeparator.length()!=1) return null;
		
		int intLastYear = year;
		int intLastMonth = month;

		if (month>11) {
			intLastYear++;
			intLastMonth = 0;
		} 
		
		String strLastDate = DateTimeUtil.diff(DateTimeUtil.getFormatDate(intLastYear, intLastMonth+1, 1, strSeparator), 1, strSeparator).substring(8,10);
		int    intLastDate = Integer.parseInt(strLastDate);
		StringBuffer sb    = new StringBuffer();
		
		/* Previous Month */
		for (int i=getWeekDay(DateTimeUtil.getFormatDate(year, month, 1, strSeparator), strSeparator); i>0; i--) {
			String strSolarDate = DateTimeUtil.diff(DateTimeUtil.getFormatDate(year, month, 1, strSeparator), i, strSeparator);
			String holiday = (holidays.get(strSolarDate.replaceAll(strSeparator, "")) == null) ? getDateName(strSolarDate, strSeparator) : holidays.get(strSolarDate.replaceAll(strSeparator, ""));
			boolean isDayOff = (holidays.get(strSolarDate.replaceAll(strSeparator, "")) == null) ? isDayOff(strSolarDate, strSeparator) : true;
			sb.append(getCalendarNode(
						strSolarDate.substring(5),                                                 // strSolarDate
						getWeekDay(strSolarDate, strSeparator),                                    // intWeek
						DateTimeUtil.convertSolarToLunar(strSolarDate, strSeparator).substring(5), // strLunarDate
						isDayOff,                                      // isHoliday
						holiday,                                   // strDateName
						strSolarDate
				   )); 			
		}
		
		/* Current Month */
		for (int i=1; i<intLastDate+1; i++) {
			String strSolarDate = DateTimeUtil.getFormatDate(year, month, i, "");
			String holiday = (holidays.get(strSolarDate) == null) ? getDateName(DateTimeUtil.getFormatDate(year, month, i, strSeparator), strSeparator) : holidays.get(strSolarDate);
			boolean isDayOff = (holidays.get(strSolarDate) == null) ? isDayOff(DateTimeUtil.getFormatDate(year, month, i, strSeparator), strSeparator) : true;
			sb.append(getCalendarNode(
						DateTimeUtil.getMonthDateString(month) + strSeparator + DateTimeUtil.getMonthDateString(i),                            // strSolarDate
						getWeekDay(DateTimeUtil.getFormatDate(year, month, i, strSeparator), strSeparator),                                    // intWeek
						DateTimeUtil.convertSolarToLunar(DateTimeUtil.getFormatDate(year, month, i, strSeparator), strSeparator).substring(5), // strLunarDate
						isDayOff,                                      // isHoliday
						holiday,                                   // strDateName
						Integer.toString(year) + strSeparator + DateTimeUtil.getMonthDateString(month) + strSeparator + DateTimeUtil.getMonthDateString(i)
					)); 
		}
		
		/* Next Month */
		for (int i=1; i<(7-getWeekDay(DateTimeUtil.getFormatDate(year, month, intLastDate, strSeparator), strSeparator)); i++) {
			String strSolarDate = DateTimeUtil.diff(DateTimeUtil.getFormatDate(year, month, intLastDate, strSeparator), -i, strSeparator);
			String holiday = (holidays.get(strSolarDate.replaceAll(strSeparator, "")) == null) ? getDateName(strSolarDate, strSeparator) : holidays.get(strSolarDate.replaceAll(strSeparator, ""));
			boolean isDayOff = (holidays.get(strSolarDate.replaceAll(strSeparator, "")) == null) ? isDayOff(strSolarDate, strSeparator) : true;
			sb.append(getCalendarNode(
					 strSolarDate.substring(5),                                                 // strSolarDate
					 getWeekDay(strSolarDate, strSeparator),                                    // intWeek
					 DateTimeUtil.convertSolarToLunar(strSolarDate, strSeparator).substring(5), // strLunarDate
					 isDayOff,                                      // isHoliday
					 holiday,                                   // strDateName
					 strSolarDate
				   )); 
		}
		return getCalendarBlock(Integer.toString(year) + strSeparator + DateTimeUtil.getMonthDateString(month), sb);
	}
	
	/**
	 * 캘린더의 JSON 블럭 탬플릿
	 * 
	 * @param strDataBlockName 블럭이름
	 * @param strDataBlock     블럭내용
	 * @return 블럭
	 */
	private static String getCalendarBlock(String strMonth, StringBuffer strDataBlock) {
		return "{\"title\":\"" + strMonth + "\", \"content\":[" + strDataBlock.substring(0, strDataBlock.length()-1) + "]}";
	}
	
	/**
	 * 캘린더의 JSON 블럭노드 탬플릿
	 * 
	 * @param strSolarDate  양력날짜
	 * @param strWeekName   요일명칭
	 * @param strLunarDate  음력날짜
	 * @param isHoliday     휴일여부
	 * @param strDateName   명칭
	 * @return 블럭노드
	 */
	private static String getCalendarNode(String strSolarDate, int intWeek, String strLunarDate, boolean isHoliday, String strDateName, String strDate) {
		return "{\"solar\":\"" + strSolarDate + "\",\"week\":" + Integer.toString(intWeek) + ",\"lunar\":\"" + strLunarDate + "\",\"holiday\":" + isHoliday + ",\"name\":\"" + strDateName + "\",\"ymd\":\"" + strDate + "\"},"; 		
	}
}
