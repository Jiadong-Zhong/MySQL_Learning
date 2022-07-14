# 第十五章，存储过程与存储函数

create database dbtest15;
use dbtest15;

create table if not exists employees
as
select *
from atguigudb.employees;

create table if not exists departments
as
select *
from atguigudb.departments;

# 1.创建存储过程
# 类型一：无参无返回
# 创建存储过程select_all_data(), 查看employees表的所有数据
delimiter $
create procedure select_all_data()
begin
    select *
    from employees;
end $
delimiter ;

# 2.存储过程调用
call select_all_data();

# 创建存储过程avg_employee_salary(), 返回所有员工的平均工资
delimiter $
create procedure avg_employee_salary()
begin
    select avg(salary)
    from employees;
end $
delimiter ;

call avg_employee_salary();

# 创建存储过程show_max_salary(), 用来查看employees表的最高薪资
delimiter $
create procedure show_max_salary()
begin
    select max(salary)
    from employees;
end $
delimiter ;

call show_max_salary();

# 类型二：带 out
# 创建存储过程show_min_salary(), 查看employees表中的最低薪资，并将最低薪资通过out参数ms输出
desc employees;
delimiter $
create procedure show_min_salary(out ms double(8, 2))
begin
    select min(salary)
    into ms
    from employees;
end $
delimiter ;

# 调用
call show_min_salary(@ms);

# 查看变量值
select @ms;

# 类型三：带 in
# 创建存储过程show_someone_salary(), 查看employees表中某个员工的薪资，并用in参数empname输入员工名
delimiter $
create procedure show_someone_salary(in empname varbinary(20))
begin
    select salary
    from employees
    where last_name = empname;
end $
delimiter ;

# 调用方式一
call show_someone_salary('Abel');
# 调用方式二
set @empname = 'Abel';
call show_someone_salary(@empname);

# 类型四：带 in 和 out
# 创建存储过程show_someone_salary2(), 查看employees表的某个员工的薪资，并用in参数empname输入姓名，用out参数empsalary输出薪资
delimiter $
create procedure show_someone_salary2(in empname varchar(20), out empsalary double(8, 2))
begin
    select salary
    into empsalary
    from employees
    where last_name = empname;
end $
delimiter ;

# 调用
set @empname = 'Abel';
call show_someone_salary2(@empname, @empsalary);
select @empsalary;

# 类型五：带inout
# 创建存储过程show_mgr_name(), 查询某个员工领导的姓名，并用inout参数empname输入员工姓名，输出领导姓名
delimiter $
create procedure show_mgr_name(inout empname varchar(20))
begin
    select e2.last_name
    into empname
    from employees e1
             join employees e2
                  on e1.manager_id = e2.employee_id
    where e1.last_name = empname;
end $
delimiter ;

# 调用
set @empname = 'Abel';
call show_mgr_name(@empname);
select @empname;

# 2.存储函数
# 创建存储函数，名称为email_by_name(), 参数定义为空，该函数查询Abel的email，并返回，数据类型为字符串类型
delimiter $
create function email_by_name()
    returns varchar(25)
    deterministic
    contains sql
    reads sql data
begin
    return (select email
            from employees
            where last_name = 'Abel');
end $
delimiter ;

# 调用
select email_by_name();

# 创建存储函数，名称为email_by_id(), 参数传入emp_id, 该函数查询emp_id的email并返回，数据类型为字符串类型
# 创建函数前执行此语句，保证函数的创建会成功
set global log_bin_trust_function_creators = 1;

delimiter $
create function email_by_id(emp_id int)
    returns varchar(25)
begin
    return (select email
            from employees
            where employee_id = emp_id);
end $
delimiter ;

# 调用
select email_by_id(101);

# 创建存储函数count_by_id(), 参数传入dept_id，该函数查询dept_id部门的员工人数，并返回，数据类型为整型
delimiter $
create function count_by_id(dept_id int)
returns int
begin
    return (select count(employee_id)
            from employees
            where department_id = dept_id);
end $
delimiter ;

# 调用
set @dept_id = 30;
select count_by_id(@dept_id);

# 3.存储过程、存储函数的查看
# 方式1.使用show create语句查看
show create procedure show_mgr_name;
show create function count_by_id;

# 方式2.show status语句查看存储过程和函数的状态信息
show procedure status;
show procedure status like 'show_max_salary';

show function status like 'email_by_id';

# 方式3.从information_schema.Routines表中查看信息
select * from information_schema.ROUTINES
where ROUTINE_NAME = 'email_by_id' and ROUTINE_TYPE = 'FUNCTION';

# 4.存储过程和存储函数的修改
alter procedure show_max_salary
sql security invoker
comment '查询最高工资';

# 5.删除
drop function if exists count_by_id;
drop procedure if exists show_min_salary;



