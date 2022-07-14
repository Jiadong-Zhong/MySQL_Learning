package jdbc2.connection;

import com.alibaba.druid.pool.DruidDataSource;
import com.alibaba.druid.pool.DruidDataSourceFactory;
import org.apache.commons.dbcp.BasicDataSourceFactory;
import org.junit.Test;

import javax.sql.DataSource;
import java.io.FileInputStream;
import java.sql.Connection;
import java.util.Properties;

public class DruidTest {

    @Test
    public void testGetConnection() throws Exception{
        Properties properties = new Properties();
        // 方式1：
        // InputStream is = ClassLoader.getSystemClassLoader().getResourceAsStream("druid.properties");
        // 方式2：
        FileInputStream is = new FileInputStream("src/druid.properties");
        properties.load(is);
        DataSource source = DruidDataSourceFactory.createDataSource(properties);

        Connection connection = source.getConnection();
        System.out.println(connection);
    }
}
