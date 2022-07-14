package jdbc1.preparedstatement_crud;

import jdbc1.statement_crud.User;
import jdbc1.util.JDBCUtils;
import org.junit.Test;

import java.lang.reflect.Field;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.util.Scanner;

/**
 * 演示PreparedStatement解决SQL注入问题
 * 除了解决Statement的拼串，sql问题之外，还有哪些好处？
 * 1.可以操作Blob类型的数据，而Statement做不到
 * 2.可以实现更高效的批量操作
 */
public class PreparedStatementTest {
    @Test
    public void testLogin() {
        Scanner sc = new Scanner(System.in);

        System.out.print("用户名：");
        String userName = sc.nextLine();
        System.out.print("密码：");
        String password = sc.nextLine();

        // SELECT user,password FROM user_table WHERE USER = '1' or ' AND PASSWORD = '
        // ='1' or '1' = '1';
        String sql = "SELECT user,password FROM user_table WHERE user = ? and password = ?";
        User user = getInstance(User.class, sql, userName, password);
        if (user != null) {
            System.out.println("登陆成功!");
        } else {
            System.out.println("用户名或密码错误！");
        }
    }

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
