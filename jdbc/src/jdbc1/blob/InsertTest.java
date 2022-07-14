package jdbc1.blob;

import jdbc1.util.JDBCUtils;
import org.junit.Test;

import java.sql.Connection;
import java.sql.PreparedStatement;

/**
 * 使用PreparedStatement实现批量数据的操作
 *
 * update delete本身就具有批量操作的效果
 * 批量操作主要针对批量插入，使用PreparedStatement实现更高效的批量插入
 *
 * 题目：向goods表中插入20000条数据
 * 方式一：使用Statement
 * 获取连接 -> 创建Statement -> 循环加入
 *
 * 方式二：使用PreparedStatement
 * 20000数据用时：500403
 */
public class InsertTest {
    @Test
    public void testBatchInsert1() {
        Connection connection = null;
        PreparedStatement ps = null;
        try {
            long start = System.currentTimeMillis();
            connection = JDBCUtils.getConnection();
            String sql = "insert into goods (name) values (?)";
            ps = connection.prepareStatement(sql);

            for (int i = 1; i <= 20000; i++) {
                ps.setObject(1, "name_" + i);
                ps.execute();
            }
            long end = System.currentTimeMillis();
            System.out.println(end - start);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            JDBCUtils.closeResource(connection, ps);
        }
    }

    /*
        方式三：
        1.addBatch()  executeBatch()  clearBatch()
        2.mysql服务器是默认关闭批处理的，需要通过一个参数开启批处理支持
            ?rewriteBatchedStatements=true 放在配置文件的url后面
        20000用时：1642
        1e6用时：75627
     */
    @Test
    public void testBatchInsert2() {
        Connection connection = null;
        PreparedStatement ps = null;
        try {
            long start = System.currentTimeMillis();
            connection = JDBCUtils.getConnection();
            String sql = "insert into goods (name) values (?)";
            ps = connection.prepareStatement(sql);

            for (int i = 1; i <= 1e6; i++) {
                ps.setObject(1, "name_" + i);
                // “攒”
                ps.addBatch();

                if (i % 500 == 0) {
                    // 执行
                    ps.executeBatch();
                    // 清空
                    ps.clearBatch();
                }
            }
            long end = System.currentTimeMillis();
            System.out.println(end - start);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            JDBCUtils.closeResource(connection, ps);
        }
    }

    /*
        方式四：设置连接不允许自动提交数据
        1e6用时：22485
     */
    @Test
    public void testBatchInsert3() {
        Connection connection = null;
        PreparedStatement ps = null;
        try {
            long start = System.currentTimeMillis();
            connection = JDBCUtils.getConnection();

            // 设置不允许自动提交数据
            connection.setAutoCommit(false);

            String sql = "insert into goods (name) values (?)";
            ps = connection.prepareStatement(sql);

            for (int i = 1; i <= 1e6; i++) {
                ps.setObject(1, "name_" + i);
                // “攒”
                ps.addBatch();

                if (i % 500 == 0) {
                    // 执行
                    ps.executeBatch();
                    // 清空
                    ps.clearBatch();
                }
            }
            // 提交数据
            connection.commit();

            long end = System.currentTimeMillis();
            System.out.println(end - start);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            JDBCUtils.closeResource(connection, ps);
        }
    }
}
