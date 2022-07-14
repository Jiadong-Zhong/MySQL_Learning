package jdbc1.blob;

import jdbc1.bean.Customer;
import jdbc1.util.JDBCUtils;
import org.junit.Test;

import java.io.*;
import java.sql.*;

/**
 * 使用PreparedStatement操作Blob数据
 */
public class BlobTest {
    // 向数据表中插入Blob类型的字段
    @Test
    public void testInsert() throws Exception {
        Connection connection = JDBCUtils.getConnection();
        String sql = "insert into customers (name, email, birth, photo) values (?,?,?,?)";
        PreparedStatement ps = connection.prepareStatement(sql);

        ps.setObject(1, "张宇豪");
        ps.setObject(2, "zhang@qq.com");
        ps.setObject(3, "1992-09-08");
        FileInputStream is = new FileInputStream("src/jdbc/Merlin.jpeg");
        ps.setBlob(4, is);

        ps.execute();

        JDBCUtils.closeResource(connection, ps);
    }

    // 查询表中的Blob类型字段
    @Test
    public void testQuery() {
        Connection connection = null;
        PreparedStatement ps = null;
        ResultSet resultSet = null;
        InputStream is = null;
        FileOutputStream os = null;
        try {
            connection = JDBCUtils.getConnection();
            String sql = "select id, name, email, birth, photo from customers where id = ?";
            ps = connection.prepareStatement(sql);

            ps.setInt(1, 24);

            resultSet = ps.executeQuery();
            if (resultSet.next()) {
                // int id = resultSet.getInt(1);
                // String name = resultSet.getString(2);
                // String email = resultSet.getString(3);
                // Date birth = resultSet.getDate(4);

                int id = resultSet.getInt("id");
                String name = resultSet.getString("name");
                String email = resultSet.getString("email");
                Date birth = resultSet.getDate("birth");

                Customer customer = new Customer(id, name, email, birth);
                System.out.println(customer);

                // 将Blob类型字段下载下来，以文件类型保存到本地
                Blob photo = resultSet.getBlob("photo");
                is = photo.getBinaryStream();
                os = new FileOutputStream("src/jdbc/" + name + ".jpg");
                byte[] buffer = new byte[1024];
                int len;
                while ((len = is.read(buffer)) != -1) {
                    os.write(buffer, 0, len);
                }

            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            JDBCUtils.closeResource(connection, ps, resultSet);
            try {
                if (is != null)
                    is.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
            try {
                if (os != null)
                    os.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

    }
}
