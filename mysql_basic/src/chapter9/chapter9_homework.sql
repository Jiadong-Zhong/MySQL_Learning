# 1、查询和Zlotkey相同的部门的员工姓名和工资
select last_name, salary
from employees
where department_id in (
    select department_id
    from employees
    where last_name = 'Zlotkey'
);

# 2、查询工资比公司平均工资高的员工的员工号，姓名和工资
select employee_id, last_name, salary
from employees
where salary > (
    select avg(salary)
    from employees
);

# 3、选择工资大于所有JOB_ID = 'SA_MAN'的员工工资的员工的last_name, job_id, salary
select last_name, job_id, salary
from employees
where salary > all (
    select salary
    from employees
    where job_id = 'SA_MAN'
);

# 4、查询和姓名中包含字母u的员工在相同部门的员工的员工号和姓名
select employee_id, last_name
from employees
where department_id in (
    select distinct department_id
    from employees
    where last_name like '%u%'
);

# 5、查询在部门的location_id为1700的部门工作的员工的员工号
select employee_id
from employees e
where department_id in (
    select department_id
    from departments
    where location_id = 1700
);

# 6、查询管理者是King的员工姓名和工资
select last_name, salary
from employees
where manager_id in (
    select employee_id
    from employees
    where last_name = 'King'
);

# 7、查询工资最低的员工信息：last_name, salary
select last_name, salary
from employees
where salary = (
    select min(salary)
    from employees
);

# 8、查询平均工资最低的部门信息
select *
from departments
where department_id = (
    select department_id
    from employees
    group by department_id
    having avg(salary) = (
        select min(avg_salary)
        from (
                 select avg(salary) "avg_salary"
                 from employees
                 group by department_id
             ) dept_avg_salary
    )
);

select *
from departments
where department_id = (
    select department_id
    from employees
    group by department_id
    having avg(salary) <= all (
        select avg(salary) "avg_salary"
        from employees
        group by department_id
    )
);

# 方式3：limit
select *
from departments
where department_id = (
    select department_id
    from employees
    group by department_id
    having avg(salary) = (
        select avg(salary) "avg_salary"
        from employees
        group by department_id
        order by avg_salary
        limit 1
    )
);

# 方式4：
select d.*
from departments d,
     (
         select department_id, avg(salary) "avg_salary"
         from employees
         group by department_id
         order by avg_salary
         limit 0, 1) dept_avg_salary
where d.department_id = dept_avg_salary.department_id;

# 9、查询平均工资最低的部门信息和该部门的平均工资(相关子查询)
select d.*, (select avg(salary) from employees where d.department_id = department_id) "avg_salary"
from departments d
where department_id = (
    select department_id
    from employees
    group by department_id
    having avg(salary) = (
        select min(avg_salary)
        from (
                 select avg(salary) "avg_salary"
                 from employees
                 group by department_id
             ) dept_avg_salary
    )
);

select d.*, dept_avg_salary.avg_salary
from departments d,
     (
         select department_id, avg(salary) "avg_salary"
         from employees
         group by department_id
         order by avg_salary
         limit 0, 1) dept_avg_salary
where d.department_id = dept_avg_salary.department_id;

# 10、查询平均工资最高的job信息
select *
from jobs
where job_id = (
    select job_id
    from employees
    group by job_id
    having avg(salary) = (
        select max(avg_salary)
        from (
                 select avg(salary) "avg_salary"
                 from employees
                 group by job_id
             ) job_avg_salary
    )
);

select j.*
from jobs j,
     (
         select job_id, avg(salary) "avg_salary"
         from employees
         group by job_id
         order by avg_salary desc
         limit 0, 1
     ) job_avg_salary
where j.job_id = job_avg_salary.job_id;

# 11、查询平均工资高于公司平均工资的部门
select *
from departments
where department_id in (
    select department_id
    from employees
    where employees.department_id is not null
    group by department_id
    having avg(salary) > (
        select avg(salary)
        from employees
    )
);

# 12、查询出公司中所有manager的信息
select *
from employees mgr
where exists(
              select *
              from employees emp
              where emp.manager_id = mgr.employee_id
          );

# 13、各个部门中，最高工资中最低的那个部门的最低工资是多少
# 方式一
select min(salary)
from employees
where department_id = (select department_id
                       from employees
                       where department_id is not null
                       group by department_id
                       having max(salary) = (
                           select min(max_salary)
                           from (
                                    select max(salary) "max_salary"
                                    from employees
                                    group by department_id
                                ) dept_max_salary
                       )
);

# 方式二
select min(salary)
from employees
where department_id = (select department_id
                       from employees
                       where department_id is not null
                       group by department_id
                       having max(salary) <= all (
                           select max(salary) "max_salary"
                           from employees
                           group by department_id
                       )
);

# 方式三
select min(salary)
from employees
where department_id = (select department_id
                       from employees
                       where department_id is not null
                       group by department_id
                       having max(salary) = (
                           select max(salary) "max_salary"
                           from employees
                           group by department_id
                           order by max_salary
                           limit 0, 1
                       )
);

# 方式四
select min(salary)
from employees e,
     (
         select department_id, max(salary) "max_salary"
         from employees
         group by department_id
         order by max_salary
         limit 0, 1
     ) dept_max_salary
where e.department_id = dept_max_salary.department_id;

# 14. 查询平均工资最高的部门的manager的详细信息: last_name, department_id, email, salary
# 方式一
select last_name, department_id, email, salary
from employees
where employee_id = any (
    select distinct manager_id
    from employees
    where department_id = (
        select department_id
        from employees
        group by department_id
        having avg(salary) = (
            select max(avg_salary)
            from (
                     select avg(salary) "avg_salary"
                     from employees
                     group by department_id
                 ) dept_avg_salary
        )
    )
);

# 方式二
select last_name, department_id, email, salary
from employees
where employee_id = any (
    select distinct manager_id
    from employees
    where department_id = (
        select department_id
        from employees
        group by department_id
        having avg(salary) >= all (
            select avg(salary) "avg_salary"
            from employees
            group by department_id
        )
    )
);

# 方式3
select last_name, department_id, email, salary
from employees
where employee_id = any (
    select distinct manager_id
    from employees e,
         (
             select department_id, avg(salary) "avg_salry"
             from employees
             group by department_id
             order by avg_salry desc
             limit 0, 1
         ) dept_avg_salary
    where e.department_id = dept_avg_salary.department_id
);

# 15. 查询部门的部门号，其中不包括job_id是"ST_CLERK"的部门号
# 方式一
select department_id
from departments
where department_id not in (
    select distinct department_id
    from employees
    where job_id = 'ST_CLERK'
);

# 方式二
select department_id
from departments d
where not exists(
        select *
        from employees e
        where d.department_id = e.department_id
          and e.job_id = 'ST_CLERK'
    );

# 16.选择没有管理者的员工的last_name
select last_name
from employees emp
where not exists(
        select *
        from employees mgr
        where emp.manager_id = mgr.employee_id
    );

# 17.查询员工号，姓名，雇用时间，工资，其中员工的管理者为'De Haan'
# 方式一
select employee_id, last_name, hire_date, salary
from employees
where manager_id in (
    select employee_id
    from employees
    where last_name = 'De Haan'
);

# 方式二
select employee_id, last_name, hire_date, salary
from employees emp
where exists(
              select *
              from employees mgr
              where emp.manager_id = mgr.employee_id
                and mgr.last_name = 'De Haan'
          );

# 18.查询各部门中比本部门平均工资高的员工的员工号，姓名和工资
# 方式一
select employee_id, last_name, salary
from employees e1
where salary > (
    select avg(salary)
    from employees e2
    where e1.department_id = e2.department_id
);

# 方式二
select employee_id, last_name, salary
from employees e,
     (
         select department_id, avg(salary) "avg_salary"
         from employees
         group by department_id
     ) dept_avg_salary
where e.salary > dept_avg_salary.avg_salary
  and e.department_id = dept_avg_salary.department_id;

# 19.查询每个部门下的部门人数大于5的部门名称
select department_name
from departments d
where 5 < (
    select count(employee_id)
    from employees e
    where d.department_id = e.department_id
);

# 20.查询每个国家下的部门个数大于2的国家编号
select country_id
from locations l
where 2 < (
    select count(department_id)
    from departments d
    where l.location_id = d.location_id
);
