package jdbc1.preparedstatement_crud;

import jdbc1.bean.Customer;
import jdbc1.util.JDBCUtils;
import org.junit.Test;

import java.lang.reflect.Field;
import java.sql.*;

/**
 * @Description 针对于Customers表的查询操作
 */
public class CustomerForQuery {

    @Test
    public void testQueryForCustomer() {
        String sql = "select id, name, birth, email from customers where id = ?";
        String sql1 = "select name, email from customers where id = ?";
        Customer customer = queryForCustomer(sql1, 13);
        System.out.println(customer);
    }

    // 针对customer表的通用操作
    public Customer queryForCustomer(String sql, Object... args) {
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
                Customer customer = new Customer();
                for (int i = 0; i < columnCount; i++) {
                    Object columnVal = resultSet.getObject(i + 1);
                    // 获取类名
                    String columnName = rsmd.getColumnName(i + 1);

                    // 给customer对象指定的columnName属性赋值为columnVal：通过反射
                    // Field declaredField = Class.forName("jdbc.bean.Customer").getDeclaredField(columnName);
                    Field declaredField = Customer.class.getDeclaredField(columnName);
                    declaredField.setAccessible(true);
                    declaredField.set(customer, columnVal);
                }
                return customer;
            }

        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            // 关闭资源
            JDBCUtils.closeResource(connection, ps, resultSet);
        }
        return null;
    }

    @Test
    public void testQuery1() {
        Connection connection = null;
        PreparedStatement ps = null;
        ResultSet resultSet = null;
        try {
            connection = JDBCUtils.getConnection();
            String sql = "select id, name, email, birth from customers where id = ?";
            ps = connection.prepareStatement(sql);

            ps.setObject(1, 1);

            // 执行并返回结果集
            resultSet = ps.executeQuery();

            // 处理结果集
            if (resultSet.next()) { // 判断结果集下一条是否有数据，有数据返回true，指针下移，返回false，指针不下移
                // 获取当前这条数据的各个字段值
                int id = resultSet.getInt(1);
                String name = resultSet.getString(2);
                String email = resultSet.getString(3);
                Date birth = resultSet.getDate(4);

                // Object[] data = new Object[] {id, name, email, birth};
                // 将数据封装成一个对象
                Customer customer = new Customer(id, name, email, birth);
                System.out.println(customer);
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            // 关闭资源
            JDBCUtils.closeResource(connection, ps, resultSet);
        }
    }
}
