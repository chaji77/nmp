package kr.co.soap.controll;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;

import kr.co.funology.fw.util.WrapPreparedStatementUtil;

public class ConnectionManager {
	
	private static String url 			= "jdbc:sqlserver://210.112.124.63:1433;databaseName=MP";
	private static String driverName 	= "com.microsoft.sqlserver.jdbc.SQLServerDriver";
	private static String username 		= "cheoum01";
	private static String password		= "cjdmados1@djemals!@#$";
	private static Connection conn;
	
	public static Connection getConnection() {
		try {
			Class.forName(driverName);
			try {
				conn = DriverManager.getConnection(url, username, password);
			} catch(SQLException e) {
				System.out.println("Conn Error");
			}
		} catch(ClassNotFoundException e) {
			System.out.println("Driver not found");
		}
		return conn;
	}
	
	public static void closeConnection(Connection conn, WrapPreparedStatementUtil ps, ResultSet rs) {
		try {
			if (rs!=null) rs.close();
			if (ps!=null) ps.close();
			closeConnection(conn);
		} catch (SQLException e) {
			System.out.println("closeConnection : " + e.toString());
		}
	}
	
	private static void closeConnection(Connection conn) {
		try {
			if (conn!=null) conn.close();
		} catch (SQLException e) {
			System.out.println("closeConnection : " + e.toString());
		}
	}
}
