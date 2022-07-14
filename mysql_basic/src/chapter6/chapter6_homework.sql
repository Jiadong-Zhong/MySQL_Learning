# part 1
# 1.显示所有员工的姓名，部门号和部门名称。 (所有要用外连接)
select e.last_name, e.department_id, d.department_name
from employees e
         left join departments d on d.department_id = e.department_id;

# 2.查询90号部门员工的job_id和90号部门的location_id
select job_id, location_id
from departments d
         join employees e on d.department_id = e.department_id
where d.department_id = 90;

# 3.选择所有有奖金的员工的 last_name , department_name , location_id , city
select e.last_name, d.department_name, l.location_id, l.city
from employees e
         left join departments d on e.department_id = d.department_id
         left join locations l on d.location_id = l.location_id
where commission_pct is not null;

# 4.选择city在Toronto工作的员工的 last_name , job_id , department_id , department_name
select e.last_name, e.job_id, d.department_id, d.department_name
from employees e
         join departments d on e.department_id = d.department_id
         join locations l on d.location_id = l.location_id
where l.city = 'Toronto';

# 5.查询员工所在的部门名称、部门地址、姓名、工作、工资，其中员工所在部门的部门名称为’Executive’
select d.department_name, l.city, e.last_name, j.job_title, e.salary
from employees e
         join departments d on e.department_id = d.department_id
         join locations l on d.location_id = l.location_id
         join jobs j on e.job_id = j.job_id
where d.department_name = 'Executive';

# 6.选择指定员工的姓名，员工号，以及他的管理者的姓名和员工号，结果类似于下面的格式
select emp.last_name, emp.employee_id, mgr.last_name, mgr.employee_id
from employees emp
         left join employees mgr on mgr.employee_id = emp.manager_id;

# 7.查询哪些部门没有员工
select department_name, d.department_id
from departments d
         left join employees e on d.department_id = e.department_id
where e.department_id is null;

# 8. 查询哪个城市没有部门
select l.location_id, l.city
from locations l
         left join departments d on l.location_id = d.location_id
where d.location_id is null;

# 9. 查询部门名为 Sales 或 IT 的员工信息
select e.last_name, e.employee_id, d.department_id, d.department_name
from employees e
         join departments d on d.department_id = e.department_id
where department_name in ('Sales', 'IT');

# part 2
# 1.所有 有门派的人员信息
select *
from t_emp
where deptId is not null;

# 2.列出所有用户，并显示其机构信息
select *
from t_emp e
         left join t_dept d on e.deptId = d.id;

# 3.列出所有门派
select *
from t_dept;

# 4.所有不入门派的人员
select *
from t_emp
where deptId is null;

# 5.所有没人入的门派
select deptName
from t_dept d
         left join t_emp e on e.deptId = d.id
where e.deptId is null;

# 6.列出所有人员和机构的对照关系
select *
from t_emp e
         left join t_dept d on e.deptId = d.id;

# 7.列出所有没入派的人员和没人入的门派
select *
from t_emp e
left join t_dept d on e.deptId = d.id
where d.id is null
union all
select *
from t_dept d
left join t_emp e on e.deptId = d.id
where e.deptId is null;

