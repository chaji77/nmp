package kr.co.funology.fw.pims;

import java.text.ParseException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;

import kr.co.funology.fw.util.FormatUtil;
import kr.co.funology.fw.util.CalendarUtil;
import kr.co.funology.fw.util.DateTimeUtil;

public class ScheduleCtrl {

    protected String        strSeparator;
    ArrayList<ScheduleVO> al;
    protected String[][][]  matrix;
    protected StringBuffer  sbr;
    private int           intStartYmd;
    private int           intEndYmd;

    public ScheduleCtrl() {

    }

    /**
     * Get Schedule
     * 
     * @param intYear    Year
     * @param intMonth   Month
     * @param separator  Separator
     * @param strSessid  SessionId
     * @param strMyYn    Only My Schedule?
     * @return Schedule Data
     * @throws ParseException parse exception
     */
    public String getSchedule(int intYear, int intMonth, String separator) throws ParseException {		//, String strSessid
        matrix = new String[6][7][30];
        sbr    = new StringBuffer();
        strSeparator = separator;

        String strYm = Integer.toString(intYear) + strSeparator + ((intMonth<10)?"0"+Integer.toString(intMonth):Integer.toString(intMonth));
        setMatrix(strYm);
        al = new ScheduleDAO().getSchedule(intYear, intMonth, separator);
        Collections.sort(al, new sort());

        sbr.append("[");
        for (int i=0; i<al.size();) {
            String r = getScheduleNode(i);
            sbr.append((al.size()==0)?r.substring(0, r.length()-1):r);
        }
        sbr.append("]");
        return sbr.toString();
    }

    public HashMap<String, String> getAdditionalHolidy(String strTargetDate) {
        return new ScheduleDAO().getAdditionalHoliday(strTargetDate);
    }

    /**
     * set calendar matrix
     *
     * @param strYm
     * @throws ParseException
     */
    protected void setMatrix(String strYm) throws ParseException {
        String[] arr = (strSeparator.equals(".")) ? strYm.replaceAll("[.]", "-").split("-") : strYm.replaceAll(strSeparator, "-").split("-");
        int year     = Integer.parseInt(arr[0]);
        int month    = Integer.parseInt("1"+arr[1])-100;
        int j        = 0;
        int k        = 0;
        intStartYmd  = Integer.parseInt(((strSeparator.equals(".")) ? strYm.replaceAll("[.]", "") : strYm.replaceAll(strSeparator, "")) + "01");
        intEndYmd    = Integer.parseInt(((strSeparator.equals(".")) ? strYm.replaceAll("[.]", "") : strYm.replaceAll(strSeparator, "")) + "28");

        for (int i=CalendarUtil.getWeekDay(DateTimeUtil.getFormatDate(year, month, 1, strSeparator), strSeparator); i>0; i--) {
            String strSolarDate = DateTimeUtil.diff(DateTimeUtil.getFormatDate(year, month, 1, strSeparator), i, strSeparator);
            matrix[k][j][0] = strSolarDate.substring(5);
            int intSolarDate = Integer.parseInt((strSeparator.equals(".")) ? strSolarDate.replaceAll("[.]", "") : strSolarDate.replaceAll(strSeparator, ""));
            intStartYmd  = (intStartYmd > intSolarDate) ? intSolarDate : intStartYmd;
            j++;
        }

        int intLastYear  = year;
        int intLastMonth = month;

        if (month>11) {
            intLastYear++;
            intLastMonth = 0;
        }
        String strLastDate = DateTimeUtil.diff(DateTimeUtil.getFormatDate(intLastYear, intLastMonth+1, 1, strSeparator), 1, strSeparator).substring(8,10);
        int    intLastDate = Integer.parseInt("1"+strLastDate)-100;
        for (int i=1; i<intLastDate+1; i++) {
            if (j%7==0 && i>1) {
                j=0;
                k++;
            }
            matrix[k][j][0] = DateTimeUtil.getMonthDateString(month) + strSeparator + DateTimeUtil.getMonthDateString(i);
            int intSolarDate = Integer.parseInt(Integer.toString(year) + DateTimeUtil.getMonthDateString(month) + DateTimeUtil.getMonthDateString(i));
            intStartYmd = (intStartYmd > intSolarDate) ? intSolarDate : intStartYmd;
            intEndYmd   = (intEndYmd < intSolarDate)   ? intSolarDate : intEndYmd;
            j++;
        }

        for (int i=1; i<(7-CalendarUtil.getWeekDay(DateTimeUtil.getFormatDate(year, month, intLastDate, strSeparator), strSeparator)); i++) {
            if (j%7==0) {
                j=0;
                k++;
            }
            String strSolarDate = DateTimeUtil.diff(DateTimeUtil.getFormatDate(year, month, intLastDate, strSeparator), -i, strSeparator);
            matrix[k][j][0] = strSolarDate.substring(5);
            int intSolarDate = Integer.parseInt((strSeparator.equals(".")) ? strSolarDate.replaceAll("[.]", "") : strSolarDate.replaceAll(strSeparator, ""));
            intStartYmd  = (intStartYmd > intSolarDate) ? intSolarDate : intStartYmd;
            intEndYmd   = (intEndYmd < intSolarDate)   ? intSolarDate : intEndYmd;
            j++;
        }
    }

    /**
     * save cell to metrix
     *
     * @param jo
     * @param xo
     * @param depth
     * @param strEndDate
     * @param vo
     */
    private void fill(int jo, int xo, int depth, String strEndDate, ScheduleVO vo) {
        boolean isStop = false;
        for (int x=xo; x<matrix[jo].length; x++) {
            matrix[jo][x][depth] = vo.SCH_LIST_SEQ;
            if (matrix[jo][x][0]!=null && matrix[jo][x][0].equals(strEndDate)) {
                isStop = true;
                break;
            }
        }

        if (isStop==false) {
            int j = jo+1;
            if (j<matrix.length && matrix[j][0][0]!=null) {
                ScheduleVO voadd = new ScheduleVO();
                voadd.START_YMD= vo.START_YMD;
                voadd.END_YMD  = vo.END_YMD;
                voadd.START_MM = matrix[j][0][0].substring(0, 2);
                voadd.START_DD = matrix[j][0][0].substring(3);
                voadd.START_HM = vo.START_HM;
                voadd.END_MM   = vo.END_MM;
                voadd.END_DD   = vo.END_DD;
                voadd.END_HM   = vo.END_HM;
                voadd.SCH_NM   = vo.SCH_NM;
                voadd.SCH_LIST_SEQ = vo.SCH_LIST_SEQ;
                voadd.GRP      = vo.GRP;
                voadd.EMP_NM  = vo.EMP_NM;
                al.add(0, voadd);
            }
            vo.END_MM = matrix[jo][matrix[jo].length-1][0].substring(0, 2);
            vo.END_DD = matrix[jo][matrix[jo].length-1][0].substring(3);
        }
    }


    /**
     * Get Schedule Node
     *
     * @param seq
     * @return
     */
    protected String getScheduleNode(int seq) {
        int depth = 0;
        int floor = 0;
        ScheduleVO vo = al.remove(seq);
        String strStartDate = vo.START_MM + strSeparator + vo.START_DD;
        String strEndDate   = vo.END_MM   + strSeparator + vo.END_DD;

        for (int i=0; i<matrix.length; i++) {
            for (int x=0; x<matrix[i].length; x++) {
                if (matrix[i][x][0]!=null && matrix[i][x][0].equals(strStartDate)) {
                    for (int y=1; y<30; y++) {
                        if (matrix[i][x][y] == null) {
                            floor = i;
                            depth = y;
                            fill(i, x, y, strEndDate, vo);
                            break;
                        }
                    }
                }
            }
        }
        return getScheduleNode(vo, floor, depth);
    }

    /**
     * Save Schedule Node To JSON
     *
     * @param vo
     * @param floor
     * @param depth
     * @return
     */
    private String getScheduleNode(ScheduleVO vo, int floor, int depth) {
        StringBuffer sb = new StringBuffer();
        sb.append("{");
        sb.append("'symd':'");
        sb.append(FormatUtil.addSeparatorDate(vo.START_YMD,"/"));
        sb.append("','eymd':'");
        sb.append(FormatUtil.addSeparatorDate(vo.END_YMD,"/"));
        sb.append("','sdt':'");
        sb.append(vo.START_MM);
        sb.append(strSeparator);
        sb.append(vo.START_DD);
        sb.append("','shm':'");
        sb.append(vo.START_HM);
        sb.append("','edt':'");
        sb.append(vo.END_MM);
        sb.append(strSeparator);
        sb.append(vo.END_DD);
        sb.append("','ehm':'");
        sb.append(vo.END_HM);
        sb.append("','nm':'");
        sb.append(vo.SCH_NM);
        sb.append("','idx':");
        sb.append(vo.SCH_LIST_SEQ);
        sb.append(",'depth':");
        sb.append(depth);
        sb.append(",'floor':");
        sb.append(floor);
        sb.append(",'grp':'");
        sb.append(vo.GRP);
        sb.append("','who':'");
        sb.append(vo.EMP_NM);
        sb.append("'},");
        return sb.toString();
    }

  /**
   * sort
   *
   * @author DOLGAMZA
   *
   */
  static class sort implements Comparator<ScheduleVO> {
    @Override
    public int compare(ScheduleVO arg0, ScheduleVO arg1) {
      return (arg0.START_MM + arg0.START_DD + arg0.START_HM).compareTo((arg1.START_MM + arg1.START_DD + arg1.START_HM));
    }
  }
  
  public void P_PLAN_ADD_PROC(String strGrp, String strTitle, String strStartYmd, String strEndYmd, String strStartHM, String strEndYM, String strRegid, String strContents) {
    new ScheduleDAO().P_PLAN_ADD_PROC(strGrp, strTitle, strStartYmd, strEndYmd, strStartHM, strEndYM, strRegid, strContents);
  }
  public void P_PLAN_MOD_PROC(int intPlanId, String strGrp, String strTitle, String strStartYmd, String strEndYmd, String strStartHM, String strEndYM, String strRegid, String strContents) {
    new ScheduleDAO().P_PLAN_MOD_PROC(intPlanId, strGrp, strTitle, strStartYmd, strEndYmd, strStartHM, strEndYM, strRegid, strContents);
  }
  public void P_PLAN_DROP_PROC(String strPlanId) {
    new ScheduleDAO().P_PLAN_DROP_PROC(strPlanId);
  }
  public ScheduleVO P_PLAN_DETAIL_PROC(int intPlanId) {
    try {
      return new ScheduleDAO().P_PLAN_DETAIL_PROC(intPlanId);
    } catch (ParseException e) {
      e.printStackTrace();
    }
    return null;
  }
  public static String getGrpNm(String grp) {
    if (grp.equals("1")) return "업무";
    if (grp.equals("2")) return "회의";
    if (grp.equals("3")) return "외근|출장";
    if (grp.equals("4")) return "휴가";
    return "";
  }
}
