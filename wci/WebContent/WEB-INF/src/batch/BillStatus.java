package batch;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Properties;

import com.baroservice.api.BarobillApiProfile;
import com.baroservice.api.BarobillApiService;
import com.baroservice.ws.ArrayOfString;
import com.baroservice.ws.ArrayOfTaxInvoiceStateEX;
import com.baroservice.ws.TaxInvoiceStateEX;

import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;
import kr.co.mp.mptax.InvoiceVO;

public class BillStatus {

    private Properties props   = null; // Properties
    private Connection connect = null;
    private String ck;
    private String cn;
    private String strSenderKey;
    private BarobillApiProfile mode;

    public BillStatus(String path) {
        try {
            File f = new File(path);
            if (f.canRead()) {
                props = new java.util.Properties();
                FileInputStream fs = new FileInputStream(f);
                props.load(new java.io.BufferedInputStream(fs));
                fs.close();
            }
        } catch (IOException e) {
            props = null;
        }
    }

    private String getString(String strKey) {
        return (props!=null) ? StrUtil.nvl(props.getProperty(strKey), "") : "";
    }

    private Connection getConnection() throws Exception {
        if (this.connect==null) {
          String url    = getString("ETAX_DB_URL");
          String user   = getString("ETAX_DB_USER");
          String passwd = getString("ETAX_DB_PASSWORD");
          Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
          this.connect = DriverManager.getConnection(url, user, passwd);
        }
        return this.connect;
    }

    private void closeConnection() {
        try {
            this.connect.close();
        } catch (Exception e) {

        }
    }

    void close(PreparedStatement ps, ResultSet rs) {
        try {
            if (rs!=null) rs.close();
            if (ps!=null) ps.close();
        } catch (SQLException e) {
            System.out.println(e.toString());
        }
    }
    void close(PreparedStatement ps) {
        try {
            if (ps!=null) ps.close();
        } catch (SQLException e) {
            System.out.println(e.toString());
        }
    }

    private ArrayList<String[]> getStatus(ArrayOfString mgtKeyList) {
        ArrayList<String[]> arr = new ArrayList<>();
        try {
            BarobillApiService barobillApiService = new BarobillApiService(this.mode);
            ArrayOfTaxInvoiceStateEX taxInvoiceStates = barobillApiService.taxInvoice.getTaxInvoiceStatesEX(this.ck, this.cn, mgtKeyList);
            if (taxInvoiceStates==null) return arr;
            for (TaxInvoiceStateEX r : taxInvoiceStates.getTaxInvoiceStateEX()) {
                String[] s = new String[3];
                int intStatus = r.getBarobillState();
                if (intStatus<0) {
                    s[0] = Integer.toString(intStatus); // fail
                    s[1] = "";
                    s[2] = "";
                }
                else {
                    int intResult = r.getNTSSendState();
                    s[0] = Integer.toString(intResult);
                    s[1] = r.getMgtKey();
                    s[2] = r.getInvoiceKey();
                }
                arr.add(s);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return arr;
    }

    private BasicVO SYS_BASIC_PROC() {
        BasicVO vo = new BasicVO();
        vo.COM_BIZ_NO     = getString("OWNER_BIZ_NO").replaceAll("-", "");
        vo.ETAX_ID        = getString("ETAX_ID");
        vo.ETAX_PASSWD    = getString("ETAX_PASSWD");
        vo.ETAX_KEY       = getString("ETAX_KEY");
        return vo;
    }

    private ArrayList<InvoiceVO> T_BILL_STATUS_PROC(String strSenderKey) {
        WrapPreparedStatementUtil ps = null;
        ArrayList<InvoiceVO> arr = new ArrayList<>();
        ResultSet rs = null;
        try {
            String query = "EXEC DBO.T_BILL_STATUS_PROC ? ";
            ps = new WrapPreparedStatementUtil(this.getConnection(), query);
            int i = 1;
            ps.setString(i++, strSenderKey);
            System.out.println(ps.getQueryString());
            rs = ps.executeQuery();
            while(rs.next()) {
                InvoiceVO vo = new InvoiceVO();
                vo.BILL_SEQ           = rs.getString("BILL_SEQ");
                vo.BILL_SENDER_KEY    = rs.getString("BILL_SENDER_KEY");
                arr.add(vo);
            }
            System.out.println("TARGET....." + arr.size());
        } catch (Exception e) {
          System.out.println(e.toString());
        } finally {
            close(ps, rs);
        }
        return arr;
    }

    private void T_BILL_UPDATE_STATUS_PROC(int seq, int status, String strInvoiceKey) {
        WrapPreparedStatementUtil ps = null;
        try {
          ps = new WrapPreparedStatementUtil(this.getConnection(), "EXECUTE DBO.T_BILL_UPDATE_STATUS_PROC ?, ?, ? ");
          int i = 1;
          ps.setInt(   i++, seq);
          ps.setInt(   i++, status);
          ps.setString(i++,  strInvoiceKey);
          System.out.println(ps.getQueryString());
          ps.executeUpdate();
        } catch (Exception e) {
          System.out.println(ps.getQueryString());
          System.out.println(e.toString());
        } finally {
            close(ps);
        }
    }

    public void exe(String key) {
        this.ck = "";
        this.cn = "";
        this.strSenderKey = key;
        System.out.println(this.strSenderKey);
        this.mode = (getString("ETAX_RELEASE_YN").equals("N")) ? BarobillApiProfile.TESTBED : BarobillApiProfile.RELEASE;
        try {
            BasicVO b = this.SYS_BASIC_PROC();
            this.ck = b.ETAX_KEY;
            this.cn = b.COM_BIZ_NO;
            ArrayList<InvoiceVO> arr = this.T_BILL_STATUS_PROC(this.strSenderKey);
            if (arr!=null && arr.size()>0) {
              ArrayOfString mgtKeyList = new ArrayOfString();
              for (InvoiceVO v : arr) {
                mgtKeyList.getString().add(v.BILL_SENDER_KEY + v.BILL_SEQ);
              }
              if (mgtKeyList.getString().size()>0) {
                ArrayList<String[]> status = this.getStatus(mgtKeyList);
                if (status!=null && status.size()>0) {
                  for (String[] s : status) {
                    System.out.println(s[0]);
                    System.out.println(s[1]);
                    System.out.println(s[2]);
                    this.T_BILL_UPDATE_STATUS_PROC(Integer.parseInt(s[1].substring(5)), Integer.parseInt(s[0]), s[2]);
                  }
                }
              } else {
                System.out.println("NO TAX......");
              }
            }
        } catch (Exception e) {
            System.out.println(e.toString());
            e.printStackTrace();
        } finally {
            this.closeConnection();
        }
    }


    public static void main(String[] args) {
        if (args==null || args.length!=2) {
            args = new String[2];
            args[0] = "MPONE";
            args[1] = "D:\\WorkSpace\\mp\\WebContent\\WEB-INF\\configuration.properties";
        }
        BillStatus bs = new BillStatus(args[1]);
        bs.exe(args[0]);
    }
}
