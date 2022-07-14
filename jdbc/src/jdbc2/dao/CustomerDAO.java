package jdbc2.dao;

import jdbc2.bean.Customer;

import java.sql.Connection;
import java.sql.Date;
import java.util.List;

/**
 * 此接口用于规范针对于customers表的常用操作
 */
public interface CustomerDAO {
    // 将customer对象添加到数据库中
    void insert(Connection connection, Customer customer);

    // 根据指定id删除表中的记录
    void deleteById(Connection connection, int id);

    // 根据customer对象修改表中的记录
    void updateById(Connection connection, Customer customer);

    // 根据指定id查询得到对应的customer
    Customer getById(Connection connection, int id);

    // 查询表中的所有记录
    List<Customer> getAll(Connection connection);

    // 返回数据表中的条目数
    Long getCount(Connection connection);

    // 返回数据表中最大的生日
    Date getMaxBirth(Connection connection);
}
