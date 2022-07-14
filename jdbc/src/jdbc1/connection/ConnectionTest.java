package jdbc1.connection;

import org.junit.Test;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.Driver;
import java.sql.DriverManager;
import java.util.Properties;

public class ConnectionTest {

    // 方式一
    @Test
    public void testConnection() throws Exception {
        // 获取Driver的实现类对象
        Driver driver = new com.mysql.jdbc.Driver();

        // jdbc:mysql: 协议
        // localhost: ip地址
        // 3306: 默认的mysql端口号
        // test: test数据库
        String url = "jdbc:mysql://localhost:3306/test";
        // 用户名和密码封装在Properties中
        Properties info = new Properties();
        info.setProperty("user", "root");
        info.setProperty("password", "abc123");

        Connection connect = driver.connect(url, info);
        System.out.println(connect);
    }

    // 方式二：对方式一的迭代：在程序中不出现第三方的api，使得程序具有更好的可移植性
    @Test
    public void testConnection2() throws Exception {
        // 使用反射实现Driver的实现类对象
        Class<?> clazz = Class.forName("com.mysql.jdbc.Driver");
        Driver driver = (Driver) clazz.getDeclaredConstructor().newInstance();

        // 提供要连接的数据库
        String url = "jdbc:mysql://localhost:3306/test";

        // 提供用户名和密码
        Properties info = new Properties();
        info.setProperty("user", "root");
        info.setProperty("password", "abc123");

        Connection connect = driver.connect(url, info);
        System.out.println(connect);
    }

    // 方式三：使用DriverManager替换Driver
    @Test
    public void testConnection3() throws Exception {
        // 使用反射实现Driver的实现类对象
        Class<?> clazz = Class.forName("com.mysql.jdbc.Driver");
        Driver driver = (Driver) clazz.getDeclaredConstructor().newInstance();

        // 提供另外三个连接的信息
        String url = "jdbc:mysql://localhost:3306/test";
        String user = "root";
        String password = "abc123";

        // 注册驱动
        DriverManager.registerDriver(driver);

        // 获取连接
        Connection connection = DriverManager.getConnection(url, user, password);
        System.out.println(connection);
    }

    // 方式四：省略注册驱动，只需要加载驱动
    @Test
    public void testConnection4() throws Exception {
        // 加载Driver  在MySQL的Driver实现类中静态代码块内已经加载
        Class.forName("com.mysql.jdbc.Driver");

        // 提供另外三个连接的信息
        String url = "jdbc:mysql://localhost:3306/test";
        String user = "root";
        String password = "abc123";

        // 获取连接
        Connection connection = DriverManager.getConnection(url, user, password);
        System.out.println(connection);
    }

    // 方式五(final)：将数据库连接的基本信息声明在配置信息中，通过读取配置文件，获取连接
    /*
        好处？
        实现数据与代码分离，解耦
        如果需要修改配置文件信息，可以避免程序重新打包
     */
    @Test
    public void testConnection5() throws Exception {
        // 读取配置文件中的基本信息
        InputStream is = ConnectionTest.class.getClassLoader().getResourceAsStream("jdbc1/jdbc.properties");
        Properties pros = new Properties();
        pros.load(is);

        String user = pros.getProperty("user");
        String password = pros.getProperty("password");
        String url = pros.getProperty("url");
        String driverClass = pros.getProperty("driverClass");

        // 加载驱动
        Class.forName(driverClass);

        // 获取连接
        Connection connection = DriverManager.getConnection(url, user, password);
        System.out.println(connection);
    }
}
