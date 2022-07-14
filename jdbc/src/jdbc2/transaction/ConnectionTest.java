package jdbc2.transaction;

import jdbc1.util.JDBCUtils;
import org.junit.Test;

import java.sql.Connection;

public class ConnectionTest {
    @Test
    public void testGetConnection() throws Exception{
        Connection connection = JDBCUtils.getConnection();
        System.out.println(connection);
    }


}
