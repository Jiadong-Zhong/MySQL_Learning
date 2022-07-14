package jdbc2.dao2;

import jdbc1.util.JDBCUtils;
import jdbc2.bean.Customer;
import org.junit.Test;

import java.sql.Connection;
import java.sql.Date;
import java.util.List;

public class CustomerDAOImplTest {
    private CustomerDAOImpl dao = new CustomerDAOImpl();

    @Test
    public void insert() {
        Connection connection = null;
        try {
            connection = JDBCUtils.getConnection();
            Customer customer = new Customer(1, "于小飞", "xiaofei@126.com", new Date(43534646435L));
            dao.insert(connection, customer);
            System.out.println("添加成功");
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            JDBCUtils.closeResource(connection, null);
        }
    }

    @Test
    public void deleteById() {
        Connection connection = null;
        try {
            connection = JDBCUtils.getConnection();
            dao.deleteById(connection, 24);
            System.out.println("删除成功");
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            JDBCUtils.closeResource(connection, null);
        }
    }

    @Test
    public void updateById() {
        Connection connection = null;
        try {
            connection = JDBCUtils.getConnection();
            Customer customer = new Customer(25, "贝多芬", "beiduofen@126.com", new Date(453465656L));
            dao.updateById(connection, customer);
            System.out.println("修改成功");
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            JDBCUtils.closeResource(connection, null);
        }
    }

    @Test
    public void getById() {
        Connection connection = null;
        try {
            connection = JDBCUtils.getConnection();
            Customer customer = dao.getById(connection, 19);
            System.out.println(customer);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            JDBCUtils.closeResource(connection, null);
        }
    }

    @Test
    public void getAll() {
        Connection connection = null;
        try {
            connection = JDBCUtils.getConnection();
            List<Customer> customers = dao.getAll(connection);
            customers.forEach(System.out::println);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            JDBCUtils.closeResource(connection, null);
        }
    }

    @Test
    public void getCount() {
        Connection connection = null;
        try {
            connection = JDBCUtils.getConnection();
            Long count = dao.getCount(connection);
            System.out.println(count);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            JDBCUtils.closeResource(connection, null);
        }
    }

    @Test
    public void getMaxBirth() {
        Connection connection = null;
        try {
            connection = JDBCUtils.getConnection();
            Date maxBirth = dao.getMaxBirth(connection);
            System.out.println(maxBirth);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            JDBCUtils.closeResource(connection, null);
        }
    }
}