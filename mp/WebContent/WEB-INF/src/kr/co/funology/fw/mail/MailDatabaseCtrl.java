package kr.co.funology.fw.mail;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.ArrayList;

import org.apache.log4j.Logger;

import kr.co.funology.fw.mgr.ConfigurationMgr;
import kr.co.funology.fw.util.CryptoDESUtil;
import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class MailDatabaseCtrl {

    private static Connection getConnection() throws Exception {
        String url    = ConfigurationMgr.getInstance().getString("MAIL_DB_URL"); // "jdbc:mysql://211.50.114.142:3306/mailbox";
        String user   = CryptoDESUtil.decrypt(ConfigurationMgr.getInstance().getString("MAIL_DB_USER")); // "dolgamza";
        String passwd = CryptoDESUtil.decrypt(ConfigurationMgr.getInstance().getString("MAIL_DB_PASSWORD")); // "@alsehf80";
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection(url, user, passwd);
    }

    public static synchronized ArrayList<String> getMailAccount() {
        Connection conn = null;
        WrapPreparedStatementUtil ps = null;
        ResultSet rs = null;
        ArrayList<String> arr = new ArrayList<>();
        Logger logger = Logger.getLogger("MailDatabaseCtrl.getMailAccount");
        try {
          conn = MailDatabaseCtrl.getConnection();
          if (conn!=null) {
              String query = "SELECT email, password FROM virtual_users;";
              ps = new WrapPreparedStatementUtil(conn, query);
              // ps.setString(1, strEmpId);
              rs = ps.executeQuery();
              while (rs.next()) {
                arr.add(rs.getString("email"));
              }
          }
        } catch (Exception e) {
            logger.error(ps.getQueryString());
            logger.error(e.toString());
        } finally {
            try {
                if (rs!=null) rs.close();
                if (ps!=null) ps.close();
                if (conn!=null) conn.close();
            } catch (Exception e) {
                logger.error(e.toString());
            }
        }
        return arr;
    }

    public static synchronized int addMailAccount(String strEmailAddress, String passwd, String nm) {
        Connection conn = null;
        WrapPreparedStatementUtil ps = null;
        int intResult = 0;
        Logger logger = Logger.getLogger("MailDatabaseCtrl.addMailAccount");
        try {
            conn = MailDatabaseCtrl.getConnection();
            if (conn!=null) {
                String query = "INSERT INTO virtual_users (domain_id, password, email, hexpass, user_nm) ";
                if (ConfigurationMgr.getInstance().getString("MAIL_DB_VER").contentEquals("MARIA")) {
                  query += " VALUES ('"+ConfigurationMgr.getInstance().getString("MAIL_DOMAIN_ID")+"', ENCRYPT(?, CONCAT('$6$', SUBSTRING(SHA(RAND()), -16))), ?, HEX(AES_ENCRYPT(?, 'SOLOGY')), ?);"; // for local
                } else {
                  query += " VALUES ('"+ConfigurationMgr.getInstance().getString("MAIL_DOMAIN_ID")+"', REPLACE(TO_BASE64(UNHEX(SHA2(?, 512))), '\n', ''), ?, HEX(AES_ENCRYPT(?, 'SOLOGY')), ?);"; // for real
                }
                ps = new WrapPreparedStatementUtil(conn, query);
                ps.setString(1, passwd);
                ps.setString(2,  strEmailAddress);
                ps.setString(3,  passwd);
                ps.setString(4,  nm);
                intResult = ps.executeUpdate();
            }
        } catch (Exception e) {
            logger.error(ps.getQueryString());
            logger.error(e.toString());
        } finally {
            try {
                if (ps!=null) ps.close();
                if (conn!=null) conn.close();
            } catch (Exception e) {
                logger.error(e.toString());
            }
        }

        // create default folders.
        try {
            MailFolder mf = new MailFolder(strEmailAddress, passwd, false, "kr");
            mf.initialize();
            mf.close();
        } catch (Exception e) {
            logger.error(e.toString());
        }
        return intResult;
    }

    public static synchronized void changeMailAccountPassword(String strEmailAddress, String passwd, String nm) {
        Connection conn = null;
        WrapPreparedStatementUtil ps = null;
        Logger logger = Logger.getLogger("MailDatabaseCtrl.changeMailAccountPassword");
        try {
            conn = MailDatabaseCtrl.getConnection();
            if (conn!=null) {
                String query = "";
                if (ConfigurationMgr.getInstance().getString("MAIL_DB_VER").contentEquals("MARIA")) {
                  query = "UPDATE virtual_users SET password = ENCRYPT(?, CONCAT('$6$', SUBSTRING(SHA(RAND()), -16))), hexpass = HEX(AES_ENCRYPT(?, 'SOLOGY')), user_nm = ? WHERE email=?;";
                } else {
                  query = "UPDATE virtual_users SET password = REPLACE(TO_BASE64(UNHEX(SHA2(?, 512))), '\n', ''), hexpass = HEX(AES_ENCRYPT(?, 'SOLOGY')), user_nm = ? WHERE email=?;";
                }
                System.out.println(query);
                ps = new WrapPreparedStatementUtil(conn, query);
                ps.setString(1, passwd);
                ps.setString(2, passwd);
                ps.setString(3, nm);
                ps.setString(4, strEmailAddress);
                logger.debug(ps.getQueryString());
                ps.executeUpdate();
            }
        } catch (Exception e) {
            // logger.error(ps.getQueryString());
            logger.error(e.toString());
        } finally {
            try {
                if (ps!=null) ps.close();
                if (conn!=null) conn.close();
            } catch (Exception e) {
                logger.error(e.toString());
            }
        }
    }

    public static synchronized int dropMailAccount(String strLoginId) {
        Connection conn = null;
        WrapPreparedStatementUtil ps = null;
        int intResult = 0;
        Logger logger = Logger.getLogger("MailDatabaseCtrl.dropMailAccount");
        try {
            conn = MailDatabaseCtrl.getConnection();
            if (conn!=null) {
                String query = "DELETE FROM virtual_users WHERE email = ?;";
                ps = new WrapPreparedStatementUtil(conn, query);
                ps.setString(1,  strLoginId);
                intResult = ps.executeUpdate();
            }
        } catch (Exception e) {
            logger.error(ps.getQueryString());
            logger.error(e.toString());
        } finally {
            try {
                if (ps!=null) ps.close();
                if (conn!=null) conn.close();
            } catch (Exception e) {
                logger.error(e.toString());
            }
        }
        return intResult;
    }

    public static synchronized int addMailLog(String strMessageUid, String strReceiver) {
        Connection conn = null;
        WrapPreparedStatementUtil ps = null;
        int intResult = 0;
        Logger logger = Logger.getLogger("MailDatabaseCtrl.addMailLog");
        try {
            conn = MailDatabaseCtrl.getConnection();
            if (conn!=null) {
                String query = "INSERT INTO message_read_log (sender, messageuid, receiver) ";
                query += " SELECT ?, ?, ? FROM dual WHERE NOT EXISTS (SELECT * FROM message_read_log WHERE sender=? and messageuid=? and receiver=?);";
                ps = new WrapPreparedStatementUtil(conn, query);
                ps.setString(1, strMessageUid.split("----")[0]);
                ps.setString(2, strMessageUid.split("----")[1]);
                ps.setString(3, strReceiver);
                ps.setString(4, strMessageUid.split("----")[0]);
                ps.setString(5, strMessageUid.split("----")[1]);
                ps.setString(6, strReceiver);
                logger.debug(ps.getQueryString());
                intResult = ps.executeUpdate();
            }
        } catch (Exception e) {
            logger.error(ps.getQueryString());
            logger.error(e.toString());
        } finally {
            try {
                if (ps!=null) ps.close();
                if (conn!=null) conn.close();
            } catch (Exception e) {
                logger.error(e.toString());
            }
        }
        return intResult;
    }

    public static synchronized ArrayList<String[]> getMailReader(String strMessageUid) {
        Connection conn = null;
        WrapPreparedStatementUtil ps = null;
        ResultSet rs = null;
        ArrayList<String[]> arr = new ArrayList<>();
        Logger logger = Logger.getLogger("MailDatabaseCtrl.getMailReader");
        try {
          conn = MailDatabaseCtrl.getConnection();
          if (conn!=null) {
              String query = "SELECT sender, messageuid, receiver, regdt FROM message_read_log where messageuid=?;";
              ps = new WrapPreparedStatementUtil(conn, query);
              ps.setString(1, strMessageUid);
              rs = ps.executeQuery();
              logger.debug(ps.getQueryString());
              String[] str = new String[4];
              while (rs.next()) {
                str[0] = rs.getString("sender");
                str[1] = rs.getString("messageuid");
                str[2] = rs.getString("receiver");
                str[3] = rs.getString("regdt");
                arr.add(str);
              }
          }
        } catch (Exception e) {
            logger.error(ps.getQueryString());
            logger.error(e.toString());
        } finally {
            try {
                if (rs!=null) rs.close();
                if (ps!=null) ps.close();
                if (conn!=null) conn.close();
            } catch (Exception e) {
                logger.error(e.toString());
            }
        }
        return arr;
    }
    
    public static synchronized int addUserFolder(String strEmail, ArrayList<MailFolderVO> arrFolders) {
        Connection conn = null;
        WrapPreparedStatementUtil ps = null;
        int intResult = 0;
        if (arrFolders==null || arrFolders.size()<1) return 0;
        Logger logger = Logger.getLogger("MailDatabaseCtrl.addUserFolder");
        try {
            conn = MailDatabaseCtrl.getConnection();
            if (conn!=null) {
                for (int i=0; i<arrFolders.size();i++) {
                    MailFolderVO vo = arrFolders.get(i);
                    String query = "INSERT INTO user_folders (email, folder) SELECT ?, ? FROM dual WHERE NOT EXISTS (SELECT * FROM user_folders WHERE email=? and folder=?);";
                    ps = new WrapPreparedStatementUtil(conn, query);
                    ps.setString(1, strEmail);
                    ps.setString(2, vo.fullname);
                    ps.setString(3, strEmail);
                    ps.setString(4, vo.fullname);
                    logger.debug(ps.getQueryString());
                    intResult += ps.executeUpdate();
                }
            }
        } catch (Exception e) {
            logger.error(e.toString());
        } finally {
            try {
                if (ps!=null) ps.close();
                if (conn!=null) conn.close();
            } catch (Exception e) {
                logger.error(e.toString());
            }
        }
        return intResult;
    }

    public static synchronized ArrayList<MailClassifyVO> getUserRule(String strEmail) {
        Connection conn = null;
        WrapPreparedStatementUtil ps = null;
        ResultSet rs = null;
        ArrayList<MailClassifyVO> arr = new ArrayList<>();
        Logger logger = Logger.getLogger("MailDatabaseCtrl.getUserRule");
        try {
            conn = MailDatabaseCtrl.getConnection();
            if (conn!=null) {
                String query = "select seq, email, folder, position, rule from user_folders_class_rule where email = ?;";
                ps = new WrapPreparedStatementUtil(conn, query);
                ps.setString(1, strEmail);
                rs = ps.executeQuery();
                while (rs.next()) {
                    MailClassifyVO vo = new MailClassifyVO();
                    vo.seq      = rs.getString("seq");
                    vo.email    = rs.getString("email");
                    vo.folder   = rs.getString("folder");
                    vo.position = rs.getString("position");
                    vo.rule     = rs.getString("rule");
                    arr.add(vo);
                }
            }
        } catch (Exception e) {
            logger.error(ps.getQueryString());
            logger.error(e.toString());
        } finally {
            try {
                if (rs!=null) rs.close();
                if (ps!=null) ps.close();
                if (conn!=null) conn.close();
            } catch (Exception e) {
                logger.error(e.toString());
            }
        }
        return arr;
    }

    public static synchronized boolean setUserRule(String strEmail, String folder, String position, String rule) {
        Connection conn = null;
        WrapPreparedStatementUtil ps = null;
        boolean isSet = false;
        Logger logger = Logger.getLogger("MailDatabaseCtrl.getUserRule");
        try {
            conn = MailDatabaseCtrl.getConnection();
            if (conn!=null) {
                String query = "INSERT INTO user_folders_class_rule (email, folder, position, rule) ";
                query += "SELECT ?, ?, ?, ? FROM dual ";
                query += " WHERE NOT EXISTS (SELECT * FROM user_folders_class_rule WHERE email=? and folder=? and position=? and rule=?);";
                ps = new WrapPreparedStatementUtil(conn, query);
                int i = 0;
                ps.setString(++i, strEmail);
                ps.setString(++i, folder);
                ps.setString(++i, position);
                ps.setString(++i, rule);
                ps.setString(++i, strEmail);
                ps.setString(++i, folder);
                ps.setString(++i, position);
                ps.setString(++i, rule);
                logger.debug(ps.getQueryString());
                isSet = ps.execute();
            }
        } catch (Exception e) {
            logger.error(e.toString());
        } finally {
            try {
                if (ps!=null) ps.close();
                if (conn!=null) conn.close();
            } catch (Exception e) {
                logger.error(e.toString());
            }
        }
        return isSet;
    }

    public static synchronized boolean dropUserRule(String seq) {
        Connection conn = null;
        WrapPreparedStatementUtil ps = null;
        boolean isSet = false;
        Logger logger = Logger.getLogger("MailDatabaseCtrl.getUserRule");
        try {
            conn = MailDatabaseCtrl.getConnection();
            if (conn!=null) {
                String query = "DELETE FROM user_folders_class_rule WHERE seq=?;";
                ps = new WrapPreparedStatementUtil(conn, query);
                int i = 0;
                ps.setString(++i, seq);
                logger.debug(ps.getQueryString());
                isSet = ps.execute();
            }
        } catch (Exception e) {
            logger.error(e.toString());
        } finally {
            try {
                if (ps!=null) ps.close();
                if (conn!=null) conn.close();
            } catch (Exception e) {
                logger.error(e.toString());
            }
        }
        return isSet;
    }


    public static synchronized boolean reservate(String email, String messageuid, String tosend) {
        Connection conn = null;
        WrapPreparedStatementUtil ps = null;
        boolean isSet = false;
        Logger logger = Logger.getLogger("MailDatabaseCtrl.reservate");
        try {
            conn = MailDatabaseCtrl.getConnection();
            if (conn!=null) {
                String query = "INSERT INTO message_reserved (email, messageuid, tosend) VALUES (?, ?, ?);";
                ps = new WrapPreparedStatementUtil(conn, query);
                int i = 0;
                ps.setString(++i, email);
                ps.setString(++i, messageuid);
                ps.setString(++i, tosend);
                logger.debug(ps.getQueryString());
                isSet = ps.execute();
            }
        } catch (Exception e) {
            logger.error(e.toString());
        } finally {
            try {
                if (ps!=null) ps.close();
                if (conn!=null) conn.close();
            } catch (Exception e) {
                logger.error(e.toString());
            }
        }
        return isSet;
    }

    public static synchronized boolean controlAlias(ArrayList<String[]> destinations) {
        Connection conn = null;
        WrapPreparedStatementUtil ps = null;
        boolean isSet = false;
        Logger logger = Logger.getLogger("MailDatabaseCtrl.addVirtuals");
        try {
            conn = MailDatabaseCtrl.getConnection();
            if (conn!=null) {
                String strVirtualToAdd = "";
                if (destinations!=null && destinations.size()>0) {
                    for (int a=0; a<destinations.size(); a++) {
                        strVirtualToAdd += ",("+ConfigurationMgr.getInstance().getString("MAIL_DOMAIN_ID")+", '" + destinations.get(a)[0] + "', '" + destinations.get(a)[1] + "')";
                    }
                    strVirtualToAdd = strVirtualToAdd.substring(1);
                }

                String query = "delete from virtual_aliases where domain_id = "+ConfigurationMgr.getInstance().getString("MAIL_DOMAIN_ID")+" and source like 'dep%'; ";
                ps = new WrapPreparedStatementUtil(conn, query);
                isSet = ps.execute();
                ps.close();

                if (!strVirtualToAdd.isEmpty()) {
                    query = "INSERT INTO virtual_aliases (domain_id, source, destination) VALUES " + strVirtualToAdd;
                    ps = new WrapPreparedStatementUtil(conn, query);
                    logger.debug(ps.getQueryString());
                    isSet = ps.execute();
                }
            }
        } catch (Exception e) {
            logger.error(e.toString());
        } finally {
            try {
                if (ps!=null) ps.close();
                if (conn!=null) conn.close();
            } catch (Exception e) {
                logger.error(e.toString());
            }
        }
        return isSet;
    }

    public static synchronized ArrayList<String[]> getAliasList() {
        Connection conn = null;
        WrapPreparedStatementUtil ps = null;
        ResultSet rs = null;
        ArrayList<String[]> arr = new ArrayList<>();
        Logger logger = Logger.getLogger("MailDatabaseCtrl.getUserRule");
        try {
            conn = MailDatabaseCtrl.getConnection();
            if (conn!=null) {
                String query = "select a.source, a.destination, b.user_nm \n";
                query       += "  from virtual_aliases a \n";
                query       += " inner join virtual_users b \n";
                query       += "    on b.email = a.destination \n";
                query       += " order by a.source asc, a.destination asc;";
                ps = new WrapPreparedStatementUtil(conn, query);
                rs = ps.executeQuery();
                while (rs.next()) {
                    String[] str = {rs.getString("source"), rs.getString("destination"), rs.getString("user_nm")};
                    arr.add(str);
                }
            }
        } catch (Exception e) {
            logger.error(e.toString());
        } finally {
            try {
                if (rs!=null) rs.close();
                if (ps!=null) ps.close();
                if (conn!=null) conn.close();
            } catch (Exception e) {
                logger.error(e.toString());
            }
        }
        return arr;
    }

}
