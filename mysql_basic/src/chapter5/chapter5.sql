# 排序与分页

# 排序
# 如果没有使用排序操作，默认情况下查询返回的数据是按照添加数据的顺序显示的
SELECT *
FROM employees;

# 使用 ORDER BY 对查询的数据进行排序操作
# 升序：ASC
# 降序：DESC
# ORDER BY 后没有显式指明排序时，默认以升序排列

# 按照salary从高到低的顺序显示员工信息
SELECT employee_id, last_name, salary
FROM employees
ORDER BY salary DESC;

# 可以使用列的别名进行排序，列的别名只能在ORDER BY中使用，不能在WHERE中使用
SELECT employee_id, salary, salary * 12 annual_sal
FROM employees
ORDER BY annual_sal;

# WHERE 需要在 FROM 后，在 ORDER BY 之前
SELECT employee_id, salary
FROM employees
WHERE department_id IN (50, 60, 70)
ORDER BY department_id DESC;

# 二级排序
# 显示员工信息，按照 department_id 的降序排列， salary 的升序排列
SELECT employee_id, salary, department_id
FROM employees
ORDER BY department_id DESC, salary;


# 分页
# LIMIT 实现分页

# 每页显示20条记录，此时显示第1页
SELECT employee_id, last_name
FROM employees
LIMIT 0, 20;

# 每页显示20条记录，此时显示第2页
SELECT employee_id, last_name
FROM employees
LIMIT 20, 20;

# 每页显示 pageSize 条记录，此时显示第 pageNo 页
# LIMIT (pageNo - 1) * pageSize, pageSize

# WHERE ORDER BY LIMIT 声明顺序
SELECT employee_id, last_name, salary
FROM employees
WHERE salary > 6000
ORDER BY salary DESC
LIMIT 0, 10;


# 表里有107条数据，只想显示第32、33条数据
SELECT *
FROM employees
LIMIT 31, 2;

# 8.0 新特性 LIMIT ... OFFSET ...
SELECT employee_id, last_name
FROM employees
LIMIT 2 OFFSET 31;

# 查询员工表中工资最高的员工信息
SELECT employee_id, last_name, salary
FROM employees
ORDER BY salary DESC
LIMIT 0, 1;

