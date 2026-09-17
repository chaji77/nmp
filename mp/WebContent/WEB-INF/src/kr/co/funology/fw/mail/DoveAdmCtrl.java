package kr.co.funology.fw.mail;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;

public class DoveAdmCtrl {

    public static int[] search(String email, String box, String position, String val) {
    	Logger logger = Logger.getLogger("DoveAdmCtrl.search");
        String query = "doveadm search -u "+ email +" mailbox "+ box +"\\* "+ position +" " + val;
        List<String> arrCommand = new ArrayList<String>();
        arrCommand.add("/bin/sh");
        arrCommand.add("-c");
        arrCommand.add(query);

        logger.debug(query);

        Process process = null;
        Runtime runtime = Runtime.getRuntime();
        ArrayList<DoveAdmVO> arr = new ArrayList<>();
        List<Integer> output = new ArrayList<>();
        BufferedReader br = null;
        String msg;
        String searched = "";
        try {
            String[] cmd = arrCommand.toArray(new String[arrCommand.size()]);
            process = runtime.exec(cmd);
            br = new BufferedReader(new InputStreamReader(process.getInputStream(), "utf-8"));
            while ((msg=br.readLine())!=null) {
            	String[] r = msg.split(" ");
            	DoveAdmVO vo = new DoveAdmVO();
            	vo.mailboxuid = r[0];
            	vo.uid        = r[1];
            	arr.add(vo);

            	searched = msg.split(" ")[1].toString();
            	// System.out.println(searched);
            	try {
            		output.add(Integer.parseInt(searched));
            	} catch (Exception e) {
            		logger.error(e.toString());
            	}
            }
            process.waitFor();
        } catch (Exception e) {
            logger.error(e.toString());
        } finally {
            try {
                process.destroy();
                if (br!=null) br.close();
            } catch (Exception e) {
                logger.error(e.toString());
            }
        }

        if (output !=null && output.size()>0) {
        	// Arrays.sor.sort(output, Collections.reverseOrder());
        	logger.debug("output ----------- ");
        	logger.debug(output.size());
        	int[] r = output.stream().mapToInt(Integer::intValue).toArray();
        	logger.debug("r ----------- ");
        	logger.debug(r.length);
        	logger.debug(r[0]);
        	return r;
        }
        return null;
    }

}

//doveadm search mailbox-guid f889a50f3837d9603d0701006fbab03b uid 2488,2493
//f889a50f3837d9603d0701006fbab03b 2493
