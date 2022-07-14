# 显示系统时间
select sysdate()
from dual;

# 查询员工号，姓名，工资，以及工资提高百分之20%后的结果
select employee_id, last_name, salary, salary * 1.2 "new salary"
from employees;

# 将员工的姓名按首字母排序，并写出姓名的长度
select last_name, length(last_name)
from employees
order by last_name;

# 查询员工id, last_name, salary，并作为一个列输出，别名为out_put
select concat(employee_id, last_name, salary) "out_put"
from employees;

# 查询公司各员工工作的年数、工作的天数，并按照工作年数降序排序
select hire_date, datediff(curdate(), hire_date), year(curdate()) - year(hire_date) "years"
from employees
order by years desc;

# 查询员工姓名，雇佣时间，部门id，满足雇用时间在1997年之后，部门id为80、90或110，commission_pct不为空
select last_name, hire_date, department_id
from employees
where year(hire_date) >= '1997-01-01'
  and department_id in (80, 90, 110)
  and commission_pct is not null;

# 查询公司中入职超过10000天的员工姓名、入职时间
select last_name, hire_date
from employees
where datediff(now(), hire_date) > 10000;

# 做一个查询，产生下面效果
# <last_name> earns <salary> monthly but wants <salary * 3>
select concat(last_name, ' earns ', salary, ' monthly but wants ', salary * 3)
from employees;

# 使用case when 按照下面条件
select last_name,
       job_id,
       case job_id
           when 'AD_PRES' then 'A'
           when 'ST_MAN' then 'B'
           when 'IT_PROG' then 'C'
           when 'SA_REP' then 'D'
           when 'ST_CLERK' then 'E'
           end "Grade"
from employees;
