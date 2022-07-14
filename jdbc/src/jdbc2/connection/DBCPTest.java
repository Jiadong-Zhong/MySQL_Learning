package jdbc2.connection;

import org.apache.commons.dbcp.BasicDataSource;
import org.apache.commons.dbcp.BasicDataSourceFactory;
import org.junit.Test;

import javax.sql.DataSource;
import java.io.FileInputStream;
import java.io.InputStream;
import java.sql.Connection;
import java.util.Properties;

public class DBCPTest {

    // 方式一：
    @Test
    public void testGetConnection() throws Exception {
        // 创建了DBCP的数据库连接池
        BasicDataSource source = new BasicDataSource();

        // 设置基本信息
        source.setDriverClassName("com.mysql.jdbc.Driver");
        source.setUrl("jdbc:mysql://localhost:3306/test");
        source.setUsername("root");
        source.setPassword("abc123");

        // 还可以设置其他涉及数据库连接池的相关属性
        source.setInitialSize(10);
        source.setMaxActive(10);

        Connection connection = source.getConnection();
        System.out.println(connection);
    }

    // 方式二：使用配置文件
    @Test
    public void testGetConnection1() throws Exception {
        Properties properties = new Properties();
        // 方式1：
        // InputStream is = ClassLoader.getSystemClassLoader().getResourceAsStream("dbcp.properties");
        // 方式2：
        FileInputStream is = new FileInputStream("src/dbcp.properties");
        properties.load(is);
        DataSource source = BasicDataSourceFactory.createDataSource(properties);

        Connection connection = source.getConnection();
        System.out.println(connection);
    }
}
