package jdbc2.connection;

import com.mchange.v2.c3p0.ComboPooledDataSource;
import com.mchange.v2.c3p0.DataSources;
import org.junit.Test;

import java.sql.Connection;

public class C3P0Test {
    // 方式一：
    @Test
    public void testGetConnection() throws Exception{
        // 获取c3p0数据库连接池
        ComboPooledDataSource cpds = new ComboPooledDataSource();
        cpds.setDriverClass("com.mysql.jdbc.Driver");
        cpds.setJdbcUrl("jdbc:mysql://localhost:3306/test");
        cpds.setUser("root");
        cpds.setPassword("abc123");

        // 通过设置相关参数对数据库连接池进行管理
        // 初始时数据库连接池的连接数
        cpds.setInitialPoolSize(10);

        Connection connection = cpds.getConnection();
        System.out.println(connection);

        // 销毁连接池
        DataSources.destroy(cpds);
    }

    // 方式二：使用配置文件
    @Test
    public void testGetConnection1() throws Exception {
        ComboPooledDataSource cpds = new ComboPooledDataSource("hello c3p0");
        Connection connection = cpds.getConnection();
        System.out.println(connection);
    }
}
