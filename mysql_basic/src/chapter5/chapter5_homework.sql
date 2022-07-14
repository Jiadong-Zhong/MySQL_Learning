# 1、查询员工的姓名、部门号和年薪，按照年薪降序，姓名升序显示
SELECT last_name, department_id, salary * 12 annual_salary
FROM employees
ORDER BY annual_salary DESC, last_name;

# 2、选择工资不在8000到17000的员工姓名和工资，按照工资降序，显示21到40位置的数据
SELECT last_name, salary
FROM employees
WHERE salary NOT BETWEEN 8000 AND 17000
ORDER BY salary DESC
LIMIT 20, 20;

# 3、查询邮箱中包含 e 的员工信息，并先按照邮箱的字节数降序，再按部门号升序
SELECT *
FROM employees
WHERE email LIKE '%e%'
ORDER BY LENGTH(email) DESC, department_id;