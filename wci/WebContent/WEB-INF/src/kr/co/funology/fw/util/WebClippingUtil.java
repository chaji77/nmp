package kr.co.funology.fw.util;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLConnection;

public class WebClippingUtil {

	/**
	 * @param args
	 */
	public static void main(String[] args) {

		URL url                   = null;
		String strContentType     = null;
		String strContentEncoding = null;
		long lngReadTime          = 0;
		StringBuffer sb           = new StringBuffer();
		
		try {
			url = new URL("http://www.mp1.co.kr/default.asp");
		} catch(Exception e) {
			System.out.println(e.toString());
			System.exit(1);
		}
		
		try {
			URLConnection urlcon = url.openConnection();
			strContentType     = urlcon.getContentType();
			strContentEncoding = urlcon.getContentEncoding();
			lngReadTime        = urlcon.getDate();
			
			System.out.println(strContentType);
			System.out.println(strContentEncoding);
			System.out.println(lngReadTime);
			
			BufferedReader br = new BufferedReader(new InputStreamReader(urlcon.getInputStream()));
			String strGotStream = null;
			while ((strGotStream=br.readLine())!=null) {
				sb.append(strGotStream + "\r\n");
			}
			System.out.println(sb.toString());
			br.close();
		} catch (Exception e) {
			System.out.println(e.toString());
		}
		

	}

}
