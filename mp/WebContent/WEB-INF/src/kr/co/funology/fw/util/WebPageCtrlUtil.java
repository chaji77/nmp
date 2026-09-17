package kr.co.funology.fw.util;

import java.util.Enumeration;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

public class WebPageCtrlUtil {
	public static void setHistoryBack(HttpServletRequest request, HttpSession session) {
		String strPage = request.getRequestURI();
		String str = "<form name='frmPageControl' method='post' action='"+strPage+"' target='_self'>";
		Enumeration<String> enumeration = request.getParameterNames();
		while (enumeration.hasMoreElements()) {
		  String strParameter = (String) enumeration.nextElement();
		  str += "<input type='hidden' name='" + strParameter + "' value='" + request.getParameter(strParameter).replaceAll("'", "").replaceAll("\"", "") + "'>";
		}
		str += "</form>";
		str += "<script>";
		str += "function goHistoryBack() {document.frmPageControl.submit();}";
		str += "</script>";
		session.setAttribute("tmp_params", str);
	}
	public static String getHistoryBack(HttpSession session) {
		String str = StrUtil.nvl((String)session.getAttribute("tmp_params"));
		return str;
	}
}
