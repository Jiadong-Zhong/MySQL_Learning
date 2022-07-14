package jdbc2.transaction;

import jdbc1.util.JDBCUtils;
import org.junit.Test;

import java.lang.reflect.Field;
import java.sql.*;

/*
    1.什么叫数据库事务
    事务：一组逻辑操作单元，使数据从一种状态变换到另一种状态。
        一组逻辑操作单元：一个或多个DML操作。

    2.事务处理的原则
    保证所有事务都作为一个工作单元来执行，即使出了故障，都不能改变这种执行方式。
    当在一个事务中执行多个操作时，要么所有事务都被提交，那么这些修改就永久保存
    要么数据库管理系统将放弃所有修改，整个事务回滚到最初状态

    3.数据一旦提交就不可回滚

    4.哪些操作会导致数据库的自动提交
        DDL操作一旦执行，都会自动提交
        DML操作默认情况下，一旦执行就会提交
            可以通过设置参数取消DML的自动提交
        默认在关闭连接时，会自动提交数据
 */
public class TransactionTest {

    // *************************未考虑事物情况下***************************//
    /*
        针对数据表user_table来说
        AA用户给BB用户转账100

        update user_table set balance = balance - 100 where user = AA;
        update user_table set balance = balance + 100 where user = BB;
     */
    @Test
    public void testUpdate() {
        String sql1 = "update user_table set balance = balance - 100 where user = ?";
        update(sql1, "AA");

        // 模拟网络异常
        System.out.println(10 / 0);

        String sql2 = "update user_table set balance = balance + 100 where user = ?";
        update(sql2, "BB");

        System.out.println("转账成功");
    }

    public int update(String sql, Object... args) {
        Connection connection = null;
        PreparedStatement ps = null;
        try {
            connection = JDBCUtils.getConnection();
            ps = connection.prepareStatement(sql);
            for (int i = 0; i < args.length; i++) {
                ps.setObject(i + 1, args[i]);
            }
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            JDBCUtils.closeResource(connection, ps);
        }
        return 0;
    }

    // *************************考虑事物情况下***************************//
    // 考虑事物后
    @Test
    public void testUpdateWithTransaction(){
        Connection connection = null;
        try {
            connection = JDBCUtils.getConnection();
            // 取消自动提交
            connection.setAutoCommit(false);

            String sql1 = "update user_table set balance = balance - 100 where user = ?";
            update(connection, sql1, "AA");

            // 模拟网络异常
            System.out.println(10 / 0);

            String sql2 = "update user_table set balance = balance + 100 where user = ?";
            update(connection, sql2, "BB");

            System.out.println("转账成功");

            // 提交数据
            connection.commit();
        } catch (Exception e) {
            e.printStackTrace();
            // 回滚数据
            try {
                connection.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        } finally {
            // 修改为自动提交数据
            // 主要针对于使用数据库连接池的使用
            try {
                connection.setAutoCommit(true);
            } catch (SQLException e) {
                e.printStackTrace();
            }
            JDBCUtils.closeResource(connection, null);
        }
    }

    public int update(Connection connection, String sql, Object... args) {
        PreparedStatement ps = null;
        try {
            ps = connection.prepareStatement(sql);
            for (int i = 0; i < args.length; i++) {
                ps.setObject(i + 1, args[i]);
            }
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            JDBCUtils.closeResource(null, ps);
        }
        return 0;
    }


    @Test
    public void testTransactionSelect() throws Exception{
        Connection connection = JDBCUtils.getConnection();
        connection.setAutoCommit(false);
        // 设置当前的隔离级别
        connection.setTransactionIsolation(Connection.TRANSACTION_READ_COMMITTED);
        String sql = "select user, password, balance from user_table where user = ?";
        User cc = getInstance(connection, User.class, sql, "cc");
        System.out.println(cc);
    }

    @Test
    public void testTransactionUpdate() throws Exception{
        Connection connection = JDBCUtils.getConnection();

        // 获取当前连接的隔离级别
        System.out.println(connection.getTransactionIsolation());

        connection.setAutoCommit(false);

        String sql = "update user_table set balance = ? where user = ?";
        update(connection, sql, 5000, "cc");
        Thread.sleep(15000);
        System.out.println("修改结束");
    }

    // 考虑了事务后的查询操作
    public <T> T getInstance(Connection connection, Class<T> clazz, String sql, Object... args) {
        PreparedStatement ps = null;
        ResultSet resultSet = null;
        try {
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
            JDBCUtils.closeResource(null, ps, resultSet);
        }
        return null;
    }

}
