package kr.co.mp.mgr.holiday;

import java.util.ArrayList;

import kr.co.funology.fw.util.StrUtil;

public class HolidayBean {
	private HolidayDAO dao;
	public HolidayBean() {
		this.dao = new HolidayDAO();
	}
	
	public int M_HOLIDAY_ADD_PROC(HolidayVO vo) {
		return dao.M_HOLIDAY_ADD_PROC(vo);
	}
	public int M_HOLIDAY_MOD_PROC(HolidayVO vo) {
		return dao.M_HOLIDAY_MOD_PROC(vo);
	}
	public int M_HOLIDAY_DROP_PROC(String date) {
		return dao.M_HOLIDAY_DROP_PROC(date);
	}
	public HolidayVO M_HOLIDAY_DETAIL_PROC(String date) {
		return dao.M_HOLIDAY_DETAIL_PROC(date);
	}
	public int M_HOLIDAY_DATES_EXIST_CHECK_PROC(String year) {
		return dao.M_HOLIDAY_DATES_EXIST_CHECK_PROC(year);
	}
	public ArrayList<HolidayVO> M_HOLIDAY_LIST_PROC(HolidayVO vo, String year) {
		return dao.M_HOLIDAY_LIST_PROC(vo, year);
	}
	
	public int M_HOLIDAY_TB_YEARLY_ADD_PROC(String xml) {
		return dao.M_HOLIDAY_TB_YEARLY_ADD_PROC(xml);
	}
	public static String[] M_HOLIDAY_MATURITY_DATE_RETURN_PROC(String date) {
		return HolidayDAO.M_HOLIDAY_MATURITY_DATE_RETURN_PROC(date);
	}
	
	public static HolidayVO M_HOLIDAY_MATURITY_PROC(String date) {
		date = StrUtil.extractDigits(date, 8);
		return HolidayDAO.M_HOLIDAY_MATURITY_PROC(date);
	}
}
