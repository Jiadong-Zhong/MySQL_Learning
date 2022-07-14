package jdbc1.preparedstatement_crud;

import jdbc1.bean.Order;
import jdbc1.util.JDBCUtils;
import org.junit.Test;

import java.lang.reflect.Field;
import java.sql.*;

/**
 * 针对Order表的通用查询操作
 */
public class OrderForQuery {

    /*
        针对于表的字段名和类的属性名不一样的情况
        1.在声明sql时，使用类的属性名来命名字段的别名
        2.在使用ResultSetMetaData时，使用getColumnLabel()替换getColumnName()来获取列的别名

        说明：说明sql中没有给字段起别名，getColumnLabel()获取的就是列名
     */
    @Test
    public void testOrderForQuery() {
        String sql = "select order_id orderId, order_name orderName, order_date orderDate from `order` where order_id = ?";
        Order order = queryOrder(sql, 1);
        System.out.println(order);
    }

    /**
     * 通用的针对order表的查询操作
     *
     * @return order对象
     */
    public Order queryOrder(String sql, Object... args) {
        Connection connection = null;
        PreparedStatement ps = null;
        ResultSet resultSet = null;
        try {
            connection = JDBCUtils.getConnection();
            ps = connection.prepareStatement(sql);

            for (int i = 0; i < args.length; i++) {
                ps.setObject(i + 1, args[i]);
            }

            resultSet = ps.executeQuery();
            ResultSetMetaData rsmd = ps.getMetaData();
            int columnCount = rsmd.getColumnCount();
            if (resultSet.next()) {
                Order order = new Order();
                for (int i = 0; i < columnCount; i++) {
                    Object columnVal = resultSet.getObject(i + 1);
                    // 获取列的别名 getColumnLabel
                    String columnLabel = rsmd.getColumnLabel(i + 1);
                    Field field = order.getClass().getDeclaredField(columnLabel);
                    field.setAccessible(true);
                    field.set(order, columnVal);
                }
                return order;
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
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
            String sql = "select order_id, order_name, order_date from test.`order` where order_id = ?";
            ps = connection.prepareStatement(sql);
            ps.setObject(1, 1);

            resultSet = ps.executeQuery();
            if (resultSet.next()) {
                int orderId = (int) resultSet.getObject(1);
                String orderName = (String) resultSet.getObject(2);
                Date orderDate = (Date) resultSet.getObject(3);
                Order order = new Order(orderId, orderName, orderDate);
                System.out.println(order);
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            JDBCUtils.closeResource(connection, ps, resultSet);
        }
    }
}
