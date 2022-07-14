package jdbc1.preparedstatement_crud;

import jdbc1.bean.Customer;
import jdbc1.bean.Order;
import jdbc1.util.JDBCUtils;
import org.junit.Test;

import java.lang.reflect.Field;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 使用PreparedStatement实现针对不同表的通用的查询操作
 */
public class PreparedStatementQueryTest {
    @Test
    public void testGetInstances() {
        String sql = "select id, name, email from customers where id < ?";
        List<Customer> instances = getInstances(Customer.class, sql, 12);
        instances.forEach(System.out::println);
    }

    public <T> List<T> getInstances(Class<T> clazz, String sql, Object... args) {
        Connection connection = null;
        PreparedStatement ps = null;
        ResultSet resultSet = null;
        try {
            connection = JDBCUtils.getConnection();
            ps = connection.prepareStatement(sql);
            for (int i = 0; i < args.length; i++) {
                ps.setObject(i + 1, args[i]);
            }

            // 执行并返回结果集
            resultSet = ps.executeQuery();
            // 获取结果集的元数据
            ResultSetMetaData rsmd = resultSet.getMetaData();
            // 获取结果集的列数
            int columnCount = rsmd.getColumnCount();

            List<T> instances = new ArrayList<>();
            // 处理结果集
            while (resultSet.next()) { // 判断结果集下一条是否有数据，有数据返回true，指针下移，返回false，指针不下移
                // 获取当前这条数据的各个字段值
                T t = clazz.getDeclaredConstructor().newInstance();

                for (int i = 0; i < columnCount; i++) {
                    Object columnVal = resultSet.getObject(i + 1);
                    String columnLabel = rsmd.getColumnLabel(i + 1);
                    Field declaredField = clazz.getDeclaredField(columnLabel);
                    declaredField.setAccessible(true);
                    declaredField.set(t, columnVal);
                }
                instances.add(t);
            }
            return instances;
        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            // 关闭资源
            JDBCUtils.closeResource(connection, ps, resultSet);
        }
    }

    @Test
    public void testGetInstance() {
        String sql = "select id, name, email from customers where id = ?";
        Customer customer = getInstance(Customer.class, sql, 12);
        System.out.println(customer);

        String sql1 = "select order_id orderId, order_name orderName from `order` where order_id = ?";
        Order order = getInstance(Order.class, sql1, 1);
        System.out.println(order);
    }

    /**
     * 针对不同表的通用的查询操作，返回表中一条记录
     *
     * @param clazz 需要创建的类别
     * @param sql   查询语句
     * @param args  语句中的字段
     * @param <T>   需要创建的对象的泛型
     * @return 查询到的记录创建的对象
     */
    public <T> T getInstance(Class<T> clazz, String sql, Object... args) {
        Connection connection = null;
        PreparedStatement ps = null;
        ResultSet resultSet = null;
        try {
            connection = JDBCUtils.getConnection();
            ps = connection.prepareStatement(sql);
            for (int i = 0; i < args.length; i++) {
                ps.setObject(i + 1, args[i]);
            }

            // 执行并返回结果集
            resultSet = ps.executeQuery();
            // 获取结果集的元数据
            ResultSetMetaData rsmd = resultSet.getMetaData();
            // 获取结果集的列数
            int columnCount = rsmd.getColumnCount();

            // 处理结果集
            if (resultSet.next()) { // 判断结果集下一条是否有数据，有数据返回true，指针下移，返回false，指针不下移
                // 获取当前这条数据的各个字段值
                T t = clazz.getDeclaredConstructor().newInstance();

                for (int i = 0; i < columnCount; i++) {
                    Object columnVal = resultSet.getObject(i + 1);
                    String columnLabel = rsmd.getColumnLabel(i + 1);
                    Field declaredField = clazz.getDeclaredField(columnLabel);
                    declaredField.setAccessible(true);
                    declaredField.set(t, columnVal);
                }
                return t;
            }

        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            // 关闭资源
            JDBCUtils.closeResource(connection, ps, resultSet);
        }
        return null;
    }
}
