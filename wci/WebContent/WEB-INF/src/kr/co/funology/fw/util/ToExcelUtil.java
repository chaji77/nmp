package kr.co.funology.fw.util;

import java.util.List;
import java.util.Map;

import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;

/**
 * Make Excel Utility
 * 
 * @author PRO
 *
 */
public class ToExcelUtil {

	private int rn = 0;
	
	/**
	 * Make WorkSheet.
	 * <pre>
	 * // jsp example
	 * String fn = "file_" + DateTimeUtil.getCurrentDate("");
     * fn = new String(fn.getBytes("utf-8"), "8859_1");
     * List&lt;Map&lt;String, Object&gt;&gt; data = new ArrayList&lt;&gt;();
	 * Map&lt;String, Object&gt; datum = new HashMap&lt;&gt;();
	 * datum.put("1", "사번");
	 * datum.put("2", "성명");
	 * data.add(datum);
     * try {
	 *   out.clear();
	 *   out = pageContext.pushBody();
	 *   ToExcelUtil eu = new ToExcelUtil();
	 *   Workbook wb = eu.getWorkBook(data);
	 *   if (wb!=null) wb.write(response.getOutputStream());
	 * } catch (Exception e) {
	 *   System.out.println(e.toString());
	 * }
	 * </pre>
	 * 
	 * @param data        내용
	 */
	public Workbook getWorkBook(List<Map<String, Object>> data) {
		Workbook wb = new HSSFWorkbook();
		try {
			Sheet sheet = wb.createSheet("Sheet1");
			this.rn = 0;
			this.createWorkSheet(sheet, data);
		} catch (Exception e) {
			System.out.println(e.toString());
		}
		return wb;
	}
	
	private void createWorkSheet(Sheet sheet, List<Map<String, Object>> data) {
		for (Map<String, Object> datum : data) {
			Row row = sheet.createRow(rn++);
			int cn = 0;
			for (String key : datum.keySet()) {
				Cell cell = row.createCell(cn++);
				cell.setCellValue(datum.get(key).toString());
				// System.out.println(datum.get(key).toString());
			}
		}
	}

}
