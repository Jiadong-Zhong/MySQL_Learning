package jdbc1.util;

import java.io.InputStream;
import java.sql.*;
import java.util.Properties;

/**
 * @Description 操作数据库的工具类
 */
public class JDBCUtils {
    /**
     * 获取数据库的连接
     * @return 数据库的连接
     * @throws Exception 读取配置文件的IOException 反射时的ClassNotFoundException 连接时的SQLException
     */
    public static Connection getConnection() throws Exception {
        InputStream is = ClassLoader.getSystemClassLoader().getResourceAsStream("jdbc1/jdbc.properties");
        Properties pros = new Properties();
        pros.load(is);

        String user = pros.getProperty("user");
        String password = pros.getProperty("password");
        String url = pros.getProperty("url");
        String driverClass = pros.getProperty("driverClass");

        // 加载驱动
        Class.forName(driverClass);

        // 获取连接
        return DriverManager.getConnection(url, user, password);
    }

    /**
     * 关闭资源
     * @param connection 数据库连接
     * @param ps Statement
     */
    public static void closeResource(Connection connection, Statement ps) {
        try {
            if (ps != null)
                ps.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }

        try {
            if (connection != null)
                connection.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static void closeResource(Connection connection, Statement ps, ResultSet rs) {
        try {
            if (ps != null)
                ps.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }

        try {
            if (connection != null)
                connection.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }

        try {
            if (rs != null)
                rs.close();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }
}
