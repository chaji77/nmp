package batch;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Properties;

import kr.co.funology.fw.util.StrUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class dbbackup {
    private Properties props   = null; // Properties
    private Connection connect = null;

    public dbbackup(String path) {
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

    public void exe() {
        WrapPreparedStatementUtil ps = null;
        try {
          ps = new WrapPreparedStatementUtil(this.getConnection(), "EXECUTE DBO.BACKUP_PROC;");
          System.out.println(ps.getQueryString());
          ps.execute();
        } catch (Exception e) {
          System.out.println(ps.getQueryString());
          System.out.println(e.toString());
        } finally {
            close(ps);
            closeConnection();
        }
    }

    public static void main(String[] args) {
        if (args==null || args.length!=1) {
            args = new String[1];
            args[0] = "D:\\WorkSpace\\mp\\WebContent\\WEB-INF\\configuration.properties";
        }
        dbbackup bs = new dbbackup(args[0]);
        bs.exe();
    }
}
