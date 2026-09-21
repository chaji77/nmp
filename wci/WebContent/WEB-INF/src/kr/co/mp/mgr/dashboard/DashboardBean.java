package kr.co.mp.mgr.dashboard;

public class DashboardBean {
	private DashboardDAO dao;
	public DashboardBean() {
		this.dao = new DashboardDAO();
	}
	public DashboardVO DASHBOARD_EXIST_CHECK_PROC() {
		return this.dao.DASHBOARD_EXIST_CHECK_PROC();
	}
}
