package jdbc2.dbutils;

import jdbc1.bean.Customer;
import jdbc2.util.JDBCUtils;
import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.ResultSetHandler;
import org.apache.commons.dbutils.handlers.*;
import org.junit.Test;

import java.sql.Connection;
import java.sql.Date;
import java.util.List;
import java.util.Map;

/**
 * 封装了针对于数据库的增删改查操作
 */
public class QueryRunnerTest {

    // 测试插入
    @Test
    public void testInsert() {
        Connection connection = null;
        try {
            QueryRunner runner = new QueryRunner();
            connection = JDBCUtils.getConnection3();
            String sql = "insert into customers(`name`,email,birth)values(?,?,?)";
            int insertCount = runner.update(connection, sql, "蔡徐坤", "caixukun@126.com", "1997-09-08");
            System.out.println(insertCount);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            JDBCUtils.closeResource(connection, null);
        }
    }

    // 测试查询
    /*
        BeanHandler是ResultSetHandler接口的实现类，用于封装表中的一条记录
     */
    @Test
    public void testQuery1() {
        Connection connection = null;
        try {
            QueryRunner runner = new QueryRunner();
            connection = JDBCUtils.getConnection3();
            String sql = "select id,`name`,email,birth from customers where id = ?";
            BeanHandler<Customer> handler = new BeanHandler<>(Customer.class);
            Customer customer = runner.query(connection, sql, handler, 23);
            System.out.println(customer);
        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            JDBCUtils.closeResource(connection, null);
        }
    }

    /*
        BeanListHandler是ResultSetHandler接口的实现类，用于封装表中的多条记录构成的集合
     */
    @Test
    public void testQuery2() {
        Connection connection = null;
        try {
            QueryRunner runner = new QueryRunner();
            connection = JDBCUtils.getConnection3();
            String sql = "select id,`name`,email,birth from customers where id < ?";
            BeanListHandler<Customer> handler = new BeanListHandler<>(Customer.class);
            List<Customer> customers = runner.query(connection, sql, handler, 23);
            customers.forEach(System.out::println);
        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            JDBCUtils.closeResource(connection, null);
        }
    }

    /*
        MapHandler是ResultSetHandler接口的实现类，对应表中的一条记录，将字段和值按照键值对存储。
     */
    @Test
    public void testQuery3() {
        Connection connection = null;
        try {
            QueryRunner runner = new QueryRunner();
            connection = JDBCUtils.getConnection3();
            String sql = "select id,`name`,email,birth from customers where id = ?";
            MapHandler handler = new MapHandler();
            Map<String, Object> customer = runner.query(connection, sql, handler, 23);
            System.out.println(customer);
        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            JDBCUtils.closeResource(connection, null);
        }
    }

    /*
        MapListHandler是ResultSetHandler接口的实现类，对应表中的多条记录，将字段和值按照键值对存储。
     */
    @Test
    public void testQuery4() {
        Connection connection = null;
        try {
            QueryRunner runner = new QueryRunner();
            connection = JDBCUtils.getConnection3();
            String sql = "select id,`name`,email,birth from customers where id < ?";
            MapListHandler handler = new MapListHandler();
            List<Map<String, Object>> customers = runner.query(connection, sql, handler, 23);
            customers.forEach(System.out::println);
        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            JDBCUtils.closeResource(connection, null);
        }
    }

    /*
        ScalarHandler用于查询表中的特殊值
     */
    @Test
    public void testQuery5() {
        Connection connection = null;
        try {
            QueryRunner runner = new QueryRunner();
            connection = JDBCUtils.getConnection3();
            String sql = "select count(*) from customers";
            ScalarHandler handler = new ScalarHandler();
            long count = (Long) runner.query(connection, sql, handler);
            System.out.println(count);
        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            JDBCUtils.closeResource(connection, null);
        }
    }

    @Test
    public void testQuery6() {
        Connection connection = null;
        try {
            QueryRunner runner = new QueryRunner();
            connection = JDBCUtils.getConnection3();
            String sql = "select max(birth) from customers";
            ScalarHandler handler = new ScalarHandler();
            Date maxBirth = (Date) runner.query(connection, sql, handler);
            System.out.println(maxBirth);
        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            JDBCUtils.closeResource(connection, null);
        }
    }

    /*
        自定义ResultSetHandler的实现类
     */
    @Test
    public void testQuery7() {
        Connection connection = null;
        try {
            QueryRunner runner = new QueryRunner();
            connection = JDBCUtils.getConnection3();
            String sql = "select id, `name`, email, birth from customers where id = ?";

            ResultSetHandler<Customer> handler = resultSet -> {
                System.out.println("handle");
                if (resultSet.next()) {
                    int id = resultSet.getInt("id");
                    String name = resultSet.getString("name");
                    String email = resultSet.getString("email");
                    Date birth = resultSet.getDate("birth");
                    return new Customer(id, name, email, birth);
                }
                return null;
            };

            Customer customer = runner.query(connection, sql, handler, 23);
            System.out.println(customer);
        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            JDBCUtils.closeResource(connection, null);
        }
    }
}
