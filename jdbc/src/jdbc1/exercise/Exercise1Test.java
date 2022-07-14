package jdbc1.exercise;

import jdbc1.util.JDBCUtils;
import org.junit.Test;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Scanner;

public class Exercise1Test {

    @Test
    public void testInsert() {
        Scanner sc = new Scanner(System.in);
        System.out.println("请输入用户名：");
        String name = sc.next();
        System.out.println("请输入邮箱：");
        String email = sc.next();
        System.out.println("请输入生日：");
        String birth = sc.next();


        String sql = "insert into customers(name, email, birth) values(?,?,?)";
        int insertCount = update(sql, name, email, birth);
        if (insertCount > 0) {
            System.out.println("添加成功");
        } else {
            System.out.println("添加失败");
        }
    }

    public int update(String sql, Object... args){
        Connection connection = null;
        PreparedStatement ps = null;
        try {
            connection = JDBCUtils.getConnection();
            ps = connection.prepareStatement(sql);

            for (int i = 0; i < args.length; i++) {
                ps.setObject(i + 1, args[i]);
            }
            /*
                ps.execute()
                如果执行的是查询操作，返回结果集，返回true
                如果执行的是增删改查，无返回值，返回false
             */
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            JDBCUtils.closeResource(connection, ps);
        }
        return 0;
    }
}
