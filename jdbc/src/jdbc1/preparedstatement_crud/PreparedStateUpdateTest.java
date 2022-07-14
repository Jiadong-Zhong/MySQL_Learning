package jdbc1.preparedstatement_crud;

import jdbc1.util.JDBCUtils;
import org.junit.Test;

import java.io.InputStream;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.Properties;

/*
    使用PreparedStatement替换Statement，实现对数据表的增删改查操作

    增删改/查

 */
public class PreparedStateUpdateTest {

    @Test
    public void testCommonUpdate() {
//        String sql = "delete from customers where id = ?";
//        update(sql, 3);

        String sql = "update `order` set order_name = ? where order_id = ?";
        update(sql, "DD", "2");
    }

    // 通用的增删改查操作
    public void update(String sql, Object... args) {
        Connection connection = null;
        PreparedStatement ps = null;
        try {
            connection = JDBCUtils.getConnection();
            ps = connection.prepareStatement(sql);
            for (int i = 0; i < args.length; i++) {
                ps.setObject(i + 1, args[i]);
            }
            ps.execute();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            JDBCUtils.closeResource(connection, ps);
        }

    }

    // 修改customer表的一条记录
    @Test
    public void testUpdate() {
        Connection connection = null;
        PreparedStatement ps = null;
        try {
            // 获取连接
            connection = JDBCUtils.getConnection();

            // 预编译sql语句，返回PreparedStatement实例
            String sql = "update customers set name = ? where id = ?";
            ps = connection.prepareStatement(sql);

            // 填充占位符
            ps.setObject(1, "莫扎特");
            ps.setObject(2, 18);

            // 执行
            ps.execute();
        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            // 资源的关闭
            JDBCUtils.closeResource(connection, ps);
        }
    }


    // 向customers表中添加一条记录
    @Test
    public void testInsert() {
        Connection connection = null;
        PreparedStatement ps = null;
        try {
            // 读取配置文件中的基本信息
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
            connection = DriverManager.getConnection(url, user, password);
            // System.out.println(connection);

            // 预编译sql语句，返回PreparedStatement的实例
            String sql = "insert into customers(name, email, birth)values(?,?,?)"; // ?是占位符
            ps = connection.prepareStatement(sql);

            // 填充占位符
            ps.setString(1, "哪吒");
            ps.setString(2, "nezha@gmail.com");
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            java.util.Date date = sdf.parse("1000-01-01");
            ps.setDate(3, new Date(date.getTime()));

            // 执行操作
            ps.execute();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            // 资源的关闭
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
    }
}
