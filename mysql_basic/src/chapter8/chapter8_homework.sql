# 1、where字句是否可以使用组函数进行过滤
# 不可以

# 2、查询公司员工工资的最大值、最小值、平均值、总和
select max(salary), min(salary), avg(salary), sum(salary)
from employees;

# 3、查询各job_id的员工工资的最大值、最小值、平均值、总和
select job_id, max(salary), min(salary), avg(salary), sum(salary)
from employees
group by job_id;

# 4、选择具有各个job_id的员工人数
select job_id, count(*)
from employees
group by job_id;

# 5、查询员工最高工资和最低工资的差距
select max(salary) - min(salary) "DIFFERENCE"
from employees;

# 6、查询各个管理者手下员工的最低工资，其中最低工资不能低于6000，没有管理者的员工不计算在内
select manager_id, min(salary) "min_salary"
from employees
where manager_id is not null
group by manager_id
having min_salary >= 6000;

# 7、查询所有部门的名字，location_id，员工数量和平均工资，并按平均工资降序
select department_name, location_id, count(employee_id), avg(salary) "avg_salary"
from departments d
         left join employees e on d.department_id = e.department_id
group by department_name, location_id
order by avg_salary;

# 8、查询每个工种、每个部门的部门名、工种名和最低工资
select department_name, e.job_id, job_title, min(salary)
from departments d
         left join employees e on d.department_id = e.department_id
         left join jobs j on e.job_id = j.job_id
group by e.job_id, department_name, job_title
