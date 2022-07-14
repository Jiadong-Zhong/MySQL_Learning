# 第三章_基本的SELECT语句

# 1、SQL分类
/*
    DDL: Data Definition Language 数据定义语言
    CREATE \ ALTER \ DROP \ RENAME \ TRUNCATE

    DML: Data Manipulation Language 数据操作语言
    INSERT \ DELETE \ UPDATE \ SELECT(重中之重)

    DCL: Data Control Language 数据控制语言
    COMMIT \ ROLLBACK \ SAVEPOINT \ GRANT \ REVOKE

 */

USE dbtest1;

SELECT *
FROM employees;

INSERT INTO employees
VALUES (1002, 'Tom');

SHOW CREATE TABLE employees;

/*
    导入现有的数据表、表的数据
    方式1：source 文件的全路径名
    方法2：基于具体的图形化界面的工具可以导入数据
 */

USE atguigudb;
# 最基本的SELECT语句  SELECT 字段1, 字段2, ... from 表名
SELECT 1 + 1, 3 * 2
FROM DUAL;
# dual: 伪表

# * : 表中的所有字段（或列）
SELECT *
FROM employees;

SELECT employee_id, last_name, salary
FROM atguigudb.employees;


# 列的别名
# as: alias(别名，可以省略)
# 列的别名可以使用""引起来，不要使用''
SELECT employee_id emp_id, last_name AS lname, department_id "部门id", salary * 12 "annual sal"
FROM employees;

# 去除重复行
# 查询员工表中一共有哪些部门id呢
SELECT department_id
FROM employees;

# 去重
SELECT DISTINCT department_id
FROM employees;

# 无报错，但是没有实际意义
SELECT DISTINCT department_id, salary
FROM employees;

# 空值参与运算
# 空值：null
# null不等同于0, ''
# 空值参与运算结果一定也为空
SELECT employee_id, salary "月工资", salary * (1 + commission_pct) * 12 "年工资", commission_pct
FROM employees;

# 解决方案，引入IFNULL
SELECT employee_id, salary "月工资", salary * (1 + IFNULL(commission_pct, 0)) * 12 "年工资", commission_pct
FROM employees;

# 着重号 ``
# 字段和表名与关键字重合
SELECT * FROM `order`;

# 查询常数，给每一行都加一个常量
SELECT '尚硅谷', 123, employee_id, last_name
FROM employees;

# 显示表结构
DESCRIBE employees; # 显示表中字段的详细信息

DESC employees;

# 过滤数据
# 查询90号员工的信息
SELECT *
FROM employees
# 过滤条件 在FROM结构后面
WHERE department_id = 90;

# 练习：查询last_name为'King'的信息
SELECT *
FROM employees
WHERE last_name = 'King';