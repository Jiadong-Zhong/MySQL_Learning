# 1. 使用表employees创建视图employee_vu，其中包括姓名，员工号，部门
use atguigudb;

create or replace view employee_vu
as
select last_name, employee_id, department_id
from employees;

# 2. 显示视图的结构
desc employee_vu;

# 3. 查询视图中的全部内容
select * from employee_vu;

# 4. 将视图中的数据限定在部门号是80的范围内
create or replace view employee_vu
as
select last_name, employee_id, department_id
from employees
where department_id = 80;


create table emps
as
select *
from atguigudb.employees;
# 1.创建视图emp_v1，要求电话号码以 011 开头的员工姓名和工资、邮箱
create or replace view emp_v1
as
select last_name, salary, email
from emps
where phone_number like '011%';

# 2.向视图emp_v1修改为查询号码以'011'开头的并且邮箱中包含e字符的员工姓名和邮箱、电话号码
create or replace view emp_v1
as
select last_name, salary, email, phone_number
from emps
where phone_number like '011%'
and email like '%e%';

select * from emp_v1;

# 3.向emp_v1插入一条记录，是否可以？
# 不可以，因为emps中有非空字段

# 4.修改emp_v1员工的工资，每人涨薪1000
update emp_v1
set salary = salary + 1000;

# 5. 删除emp_v1中姓名为Olsen的员工
delete from emp_v1
where last_name = 'Olsen';

# 6.创建视图emp_v2，要求查询部门的最高工资高于12000的部门id和其最高工资
create or replace view emp_v2
as
select department_id, max(salary) max_salary
from emps
group by department_id
having max_salary > 12000;

select * from emp_v2;

# 7. 向emp_v2中插入一条记录，是否可以
desc emps;
# 不可以

# 8.删除刚才的 emp_v2 和 emp_v1
drop view if exists emp_v1, emp_v2;

