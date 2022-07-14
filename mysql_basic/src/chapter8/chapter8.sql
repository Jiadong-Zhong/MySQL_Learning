# 聚合函数

# 1、常见的聚合函数
# 1.1、AVG / SUM : 适用于数值类型的
select avg(salary), sum(salary)
from employees;

# 下面操作没有意义
select sum(last_name), avg(last_name), sum(hire_date)
from employees;

# 1.2 MAX / MIN
select max(salary), min(salary)
from employees;

select max(last_name), min(last_name)
from employees;

# 1.3 COUNT
# 作用：计算指定字段在查询结构中出现的个数
select count(employee_id), count(salary), count(1)
from employees;

select *
from employees;

# 计算表中有多少条记录
# 1: count(*)
# 2: count(1)
# 3: count(具体字段) 不一定对

# count不计算null值
select count(commission_pct)
from employees;

# AVG = SUM / COUNT

# 查询公司中的平均奖金率
# 错误
select avg(commission_pct)
from employees;

# 正确
select sum(commission_pct) / count(*), avg(ifnull(commission_pct, 0))
from employees;

# 如果使用MyISAM引擎，count(*),count(1),count(具体字段)效率相同
# 如果是InnoDB引擎，count(*) = count(1) > count(字段)

# 2、GROUP BY 的使用
# 查询各个部门的平均工资，最高工资
select department_id, avg(salary), max(salary)
from employees
group by department_id;

# 查询各个工作的平均工资
select job_id, avg(salary)
from employees
group by job_id;

# 查询各个部门内各个工作的平均工资
select department_id, job_id, avg(salary)
from employees
group by department_id, job_id;

# 错误的，但是不报错
select department_id, job_id, avg(salary)
from employees
group by department_id;
# 结论：select中非组函数的字段一定要在group by中

# with rollup再计算一次整体，不能和order by一起使用
select department_id, avg(salary)
from employees
group by department_id with rollup;

# 3、HAVING的使用  作用：过滤数据
# 查询各个部门最高工资比10000高的部门
# 如果过滤条件中使用了聚合函数，则必须用having替换where，否则报错，且having必须在group by之后
select department_id, max(salary) "maxSalary"
from employees
group by department_id
having maxSalary > 10000;

# 查询部门id为10,20,30,40中最高工资比10000高的部门
select department_id, max(salary) "maxSalary"
from employees


group by department_id
having department_id in (10, 20, 30, 40) and maxSalary > 10000;

# 下方效率比上方更高
select department_id, max(salary) "maxSalary"
from employees
where department_id in (10, 20, 30, 40)
group by department_id
having maxSalary > 10000;

# 当过滤条件中有聚合函数时，过滤条件必须声明再having中
# 当过滤条件中没有聚合函数时，建议声明在where中

/*
    where 与 having 对比
    having适用范围更广
    如果过滤条件中没有聚合函数，where效率高于having
 */

# 4、SQL底层执行原理
# 4.1 select语句的完整结构
/*
    select ..., ..., ....
    from ... join ... on 多表的连接条件
    join ... on ....
    where 不包含聚合函数的过滤条件
    group by ..., ....
    having 包含聚合函数的过滤条件
    limit ..., ....
 */

# 4.2 执行过程
/*
    from ..., ... -> on -> (left / right join) -> where -> group by -> having -> select -> distinct ->
    order by -> limit
 */