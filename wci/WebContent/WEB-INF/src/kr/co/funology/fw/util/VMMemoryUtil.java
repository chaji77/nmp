package kr.co.funology.fw.util;

import java.util.HashMap;

/**
 * VM's Memory Check Utility
 * 
 * 
 * @author DOLGAMZA
 * @version 1.0
 * @since 2012.08
 *
 */
public class VMMemoryUtil {
	
	/**
	 * Get VM Memory Status
	 * 
	 * @return VM Memory Status
	 */
	public HashMap<String, Double> getVMMemory() {
		HashMap<String, Double> h = new HashMap<String, Double>();
		Runtime rt = Runtime.getRuntime();
		h.put("TotalMemory",  (double)rt.totalMemory()/(1024*1024));
		h.put("FreeMemory",   (double)rt.freeMemory()/(1024*1024));
		h.put("AvailProcess", (double)rt.availableProcessors());
		return h;
	}

	/**
	 * Run Garbage Collection
	 * 
	 * 
	 */
	public void execGarbageCollection() {
		Runtime.getRuntime().gc();
		System.out.println("Garbage Collection is run.");
	}
	
}
