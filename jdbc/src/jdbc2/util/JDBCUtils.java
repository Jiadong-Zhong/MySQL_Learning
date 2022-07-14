package jdbc2.util;

import com.alibaba.druid.pool.DruidDataSourceFactory;
import com.mchange.v2.c3p0.ComboPooledDataSource;
import org.apache.commons.dbcp.BasicDataSourceFactory;
import org.apache.commons.dbutils.DbUtils;

import javax.sql.DataSource;
import java.io.FileInputStream;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;

public class JDBCUtils {

    // 连接池只需要一个就可以了
    private static ComboPooledDataSource cpds = new ComboPooledDataSource("hello c3p0");

    /**
     * 使用C3P0数据库连接池获取连接
     *
     * @return 数据库连接
     * @throws Exception 连接时的SQLException
     */
    public static Connection getConnection1() throws Exception {
        return cpds.getConnection();
    }



    private static DataSource dbcpSource;
    static {
        try {
            Properties properties = new Properties();
            FileInputStream is = new FileInputStream("src/dbcp.properties");
            properties.load(is);
            dbcpSource = BasicDataSourceFactory.createDataSource(properties);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * 使用DBCP数据库连接池获取连接
     * @return 数据库连接
     * @throws Exception 连接时的SQLException
     */
    public static Connection getConnection2() throws Exception {
        return dbcpSource.getConnection();
    }



    private static DataSource druidSource;
    static {
        try {
            Properties properties = new Properties();
            FileInputStream is = new FileInputStream("src/druid.properties");
            properties.load(is);
            druidSource = DruidDataSourceFactory.createDataSource(properties);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * 使用Druid数据库连接池获取连接
     * @return 数据库连接
     * @throws Exception 连接时的SQLException
     */
    public static Connection getConnection3() throws Exception {
        return druidSource.getConnection();
    }

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

    /*
        使用dbutils中的Dbutils的工具类，实现资源的关闭
     */
    public static void closeResource1(Connection connection, Statement ps, ResultSet rs) {
//        try {
//            DbUtils.close(connection);
//        } catch (SQLException e) {
//            throw new RuntimeException(e);
//        }
//        try {
//            DbUtils.close(ps);
//        } catch (SQLException e) {
//            throw new RuntimeException(e);
//        }
//        try {
//            DbUtils.close(rs);
//        } catch (SQLException e) {
//            throw new RuntimeException(e);
//        }
        DbUtils.closeQuietly(connection);
        DbUtils.closeQuietly(ps);
        DbUtils.closeQuietly(rs);
    }
}
