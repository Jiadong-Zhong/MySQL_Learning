# 第9章  子查询

# 需求：谁的工资比Abel高

select last_name, salary
from employees
where last_name = 'Abel';

select last_name, salary
from employees
where salary > 11000;

# 方式2 自连接
select e2.last_name, e2.salary
from employees e1,
     employees e2
where e2.salary > e1.salary
  and e1.last_name = 'Abel';

# 方式3：子查询
select last_name, salary
from employees
where salary > (
    select salary
    from employees
    where last_name = 'Abel'
);

# 2、称谓的规范：外查询(主查询) 内查询(内查询)

/*
    子查询在主查询之前一次执行完成
    子查询的结果被主查询使用
    注意事项：
    子查询要包括在括号内
    将子查询放在比较条件的右侧
    单行操作符对应单行子查询，多行操作符对应多行子查询
 */

# 3、子查询的分类

/*
    角度1：单行子查询 vs 多行子查询
    角度2：相关子查询 vs 不相关子查询

    举例：相关子查询：查询工资大于本部门平均工资的员工信息
        不相关子查询：查询工资大于本公司平均工资的员工信息
 */

# 4、单行子查询
# 4.1 单行操作符  = != > >= < <=
# 查询工资大于149号员工工资的员工信息
select employee_id, last_name, salary
from employees
where salary > (
    select salary
    from employees
    where employee_id = 149
);

# 返回job_id与141号员工相同，salary比143号员工多的员工姓名，job_id和工资
select last_name, job_id, salary
from employees
where job_id = (
    select job_id
    from employees
    where employee_id = 141
)
  and salary > (
    select salary
    from employees
    where employee_id = 143
);

# 返回公司工资最少的员工的last_name, job_id, salary
select last_name, job_id, salary
from employees
where salary = (
    select min(salary)
    from employees
);

# 查询与141号员工的manager_id和department_id相同的其他员工的employee_id, manager_id, department_id
select employee_id, manager_id, department_id
from employees
where manager_id = (
    select manager_id
    from employees
    where employee_id = 141
)
  and department_id = (
    select department_id
    from employees
    where employee_id = 141
)
  and employee_id != 141;

select employee_id, manager_id, department_id
from employees
where (manager_id, department_id) = (
    select manager_id, department_id
    from employees
    where employee_id = 141
)
  and employee_id != 141;

# 查询最低工资大于50号部门最低工资的部门id和其最低工资
select department_id, min(salary) "min_salary"
from employees
where department_id is not null
group by department_id
having min_salary > (
    select min(salary)
    from employees
    where department_id = 50
);

# 显示员工的employee_id, last_name和location，
# 其中若department_id与location_id为1800的department_id相同，则location为‘Canada’，其余为‘USA’
select employee_id,
       last_name,
       case department_id
           when (
               select department_id
               from departments
               where location_id = 1800
           ) then 'Canada'
           else 'USA' end "location"
from employees;

# 子查询中的空值问题，查出来结果可能是空

# 非法使用子查询，使用单行操作符操作多行数据

# 多行子查询
# 5.1 多行操作符  IN ANY ALL SOME

# 返回其他job_id中比job_id为'IT_PROG'部门任一工资低的员工的员工号、姓名、job_id以及salary
select employee_id, last_name, job_id, salary
from employees
where salary < any (
    select salary
    from employees
    where job_id = 'IT_PROG'
)
  and job_id != 'IT_PROG';

# 返回其他job_id中比job_id为'IT_PROG'部门所有工资低的员工的员工号、姓名、job_id以及salary
select employee_id, last_name, job_id, salary
from employees
where salary < all (
    select salary
    from employees
    where job_id = 'IT_PROG'
)
  and job_id != 'IT_PROG';

# 查询平均工资最低的部门id
# MySQL聚合函数不能嵌套
select department_id
from employees
group by department_id
having avg(salary) = (
    select min(avg_salary)
    from (
             select avg(salary) "avg_salary"
             from employees
             group by department_id
         ) t_dept_avg_sal
);
select department_id
from employees
group by department_id
having avg(salary) <= all (select min(avg_salary)
                           from (
                                    select avg(salary) "avg_salary"
                                    from employees
                                    group by department_id
                                ) t_dept_avg_sal
);

# 5.3 空值问题


# 6 相关子查询
# 查询员工中工资大于本部门平均工资的员工的last_name, salary和department_id
select last_name, salary, department_id
from employees e1
where salary > (
    select avg(salary)
    from employees e2
    where e1.department_id = e2.department_id
);

# 在from中声明子查询
select e.last_name, e.salary, e.department_id
from employees e,
     (select department_id, avg(salary) "avg_salary"
      from employees
      group by department_id) dept_avg_salary
where e.department_id = dept_avg_salary.department_id
  and e.salary > dept_avg_salary.avg_salary;

# 查询员工的id, salary, 按照department_name排序
select employee_id, salary
from employees e
order by (
             select department_name
             from departments d
             where e.department_id = d.department_id
         );

# 结论：在select中，除了group by和limit之外，其他地方都可以声明子查询

# 若employees表中employee_id与job_history表中employee_id相同的数目不小于2
# 输出这些相同id的员工的employee_id, last_name和其job_id
select employee_id, last_name, job_id
from employees e
where 2 <= (
    select count(*)
    from job_history j
    where e.employee_id = j.employee_id
);

# exists 与 not exists 关键字
# 查询公司管理者的employee_id, last_name, job_id, department_id信息
select distinct mgr.employee_id, mgr.last_name, mgr.job_id, mgr.department_id
from employees emp
         join employees mgr
where emp.manager_id = mgr.employee_id;

select employee_id, last_name, job_id, department_id
from employees
where employee_id in (
    select distinct manager_id
    from employees
);

# 方式3：使用exists
select employee_id, last_name, job_id, department_id
from employees e1
where exists(
              select *
              from employees e2
              where e1.employee_id = e2.manager_id
          );

# 查询departments表中，不存在与employees表中的部门和department_id和department_name
# 方式一
select d.department_id, d.department_name
from employees e
         right join departments d on d.department_id = e.department_id
where e.department_id is null;

# 方式二
select department_id, department_name
from departments d
where not exists(
        select *
        from employees e
        where e.department_id = d.department_id
    );



