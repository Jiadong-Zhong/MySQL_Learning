# 多表查询

# 1、熟悉常见的几个表
DESC employees;
DESC departments;
DESC locations;

# 查询 Abel 在哪个城市工作
SELECT *
FROM employees
WHERE last_name = 'Abel';

SELECT *
FROM departments
WHERE department_id = 80;

SELECT *
FROM locations
WHERE location_id = 2500;

# 多表查询
# 出现笛卡尔积错误，缺少多表的连接条件
# 错误的实现方式，每个员工与每个部门都匹配了一次
SELECT employee_id, department_name
FROM employees,
     departments;
# 2889条记录

# 正确方式：需要有连接条件
SELECT employee_id, department_name
FROM employees,
     departments
WHERE employees.`department_id` = departments.`department_id`;

# 如果查询语句中出现了多个表中都存在的字段，必须指明此字段存在的表
SELECT employees.employee_id, departments.department_name, employees.department_id
FROM employees,
     departments
WHERE employees.`department_id` = departments.`department_id`;

# 从优化角度，建议多表查询时，每个字段前都指明其所在的表

# 可以给表起别名，在SELECT和WHERE中使用表的别名，如果起了别名之后使用需要别名
SELECT emp.employee_id, dept.department_name, emp.department_id
FROM employees emp,
     departments dept
WHERE emp.`department_id` = dept.`department_id`;

# 如果有n个表实现多表查询，则需要至少n-1个连接条件
# 查询员工的employee_id, last_name, department_name, city
SELECT e.employee_id, e.last_name, d.department_name, l.city, e.department_id, l.location_id
FROM employees e,
     departments d,
     locations l
WHERE e.`department_id` = d.`department_id`
  AND d.`location_id` = l.`location_id`;

/*
    多表查询的分类

    等值连接  vs  非等值连接
    自连接  vs  非自连接
    内连接  vs  外连接
 */

# 等值连接  vs  非等值连接
# 非等值连接
SELECT *
FROM job_grades;

SELECT e.last_name, e.salary, j.grade_level
FROM employees e,
     job_grades j
WHERE e.`salary` BETWEEN j.`lowest_sal` AND j.`highest_sal`
ORDER BY j.grade_level;

# 自连接 vs 非自连接
SELECT *
FROM employees;

# 查询员工id，员工姓名及其管理者的id和姓名
SELECT e.employee_id, e.last_name, m.employee_id, m.last_name
FROM employees e,
     employees m
WHERE e.`manager_id` = m.`employee_id`;

# 内连接  vs  外连接
# 内连接：合并具有同一列的表的行，结果集中不包含 一个表与另一个表不匹配的行
SELECT e.employee_id, d.department_name
FROM employees e,
     departments d
WHERE e.`department_id` = d.`department_id`;
# 只有106条记录

# 外连接：合并具有同一列的表的行，结果集中除了包含包含 一个表与另一个表匹配的行之外，还查询到了不匹配的行
# 外连接的分类：左外连接，右外连接，满外连接
# 左外连接：外连接中不匹配的行只有左表中的行
# 右外连接：外连接中不匹配的行只有右表中的行

# 查询所有员工的 last_name, department_name

# SQL92语法实现外连接，使用 + ，MySQL不支持92语法的外连接
# WHERE e.`department_id` = d.`department_id`(+);

# SQL99使用JOIN ON的方式实现多表查询

# SQL99实现内连接
SELECT last_name, department_name
FROM employees e
         JOIN departments d ON e.department_id = d.department_id;

select last_name, department_name, city
from employees e
         join departments d on e.department_id = d.department_id
         join locations l on d.location_id = l.location_id;

# SQL99实现外连接
select last_name, department_name
from employees e
         left join departments d on d.department_id = e.department_id;

select last_name, department_name
from employees e
         right join departments d on d.department_id = e.department_id;

# 满外连接 MySQL不支持FULL OUTER JOIN
# UNION 和 UNION ALL
# UNION 会执行去重操作
# UNION ALL 不会执行去重操作

# 7种JOIN实现
# 中图，内连接
select employee_id, department_name
from employees
         join departments d on d.department_id = employees.department_id;

# 左上图：左外连接
select employee_id, department_name
from employees
         left join departments d on d.department_id = employees.department_id;

# 右上图：右外连接
select employee_id, department_name
from employees
         right join departments d on d.department_id = employees.department_id;


# 左中图：在左上图去除中间部分
select employee_id, department_name
from employees e
         left join departments d on d.department_id = e.department_id
where d.department_id is null;

# 右中图：右上图去除中间部分
select employee_id, department_name
from employees e
         right join departments d on d.department_id = e.department_id
where e.department_id is null;

# 左下图：满外连接，左上图 UNION ALL 右中图  或者 左中图 UNION ALL 右上图
select employee_id, department_name
from employees
         left join departments d on d.department_id = employees.department_id
union all
select employee_id, department_name
from employees e
         right join departments d on d.department_id = e.department_id
where e.department_id is null;

# 右下图：左中图 UNION ALL 右中图
select employee_id, department_name
from employees e
         left join departments d on d.department_id = e.department_id
where d.department_id is null
union all
select employee_id, department_name
from employees e
         right join departments d on d.department_id = e.department_id
where e.department_id is null;

# SQL99 : NATUAL JOIN 自动查询两个表中相同字段，进行等值连接
select employee_id, last_name, department_name
from employees e
         natural join departments d;

# USING 指定表中的"同名字段"进行等值连接
select employee_id, last_name, department_name
from employees e
         join departments d
              using (department_id);

