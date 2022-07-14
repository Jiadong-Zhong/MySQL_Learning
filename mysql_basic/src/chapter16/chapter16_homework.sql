/*
    变量：
        系统变量  全局系统变量、会话系统变量
        用户自定义变量  会话用户变量、局部变量
 */

create database if not exists test16_var_cursor;
use test16_var_cursor;

create table employees
as
select *
from atguigudb.employees;

create table departments
as
select *
from atguigudb.departments;

set global log_bin_trust_function_creators = 1;

# 无参有返回
# 1.创建函数get_count()，返回公司的员工个数
delimiter $
create function get_count()
    returns int
begin
    declare emp_count int;

    select count(*)
    into emp_count
    from employees;

    return emp_count;
end $
delimiter ;

select get_count();

# 有参有返回
# 2.创建函数ename_salary()，根据员工姓名，返回它的工资
delimiter $
create function ename_salary(emp_name varchar(15))
    returns double
begin
    set @sal = 0;

    select salary into @sal from employees where last_name = emp_name;

    return @sal;
end $
delimiter ;

select ename_salary('Abel');

select @sal;

# 创建函数dept_sal(), 根据部门名返回该部门的平均工资
delimiter $
create function dept_sal(dept_name varchar(25))
    returns double
begin
    declare avg_sal double;

    select avg(salary)
    into avg_sal
    from employees e
             join departments d on e.department_id = d.department_id
    where d.department_name = dept_name;

    return avg_sal;
end $
delimiter ;

select dept_sal('Marketing');

# 创建函数add_float()，实现传入两个float，返回二者之和
delimiter $
create function add_float(num1 float, num2 float)
    returns float
begin
    declare sum float;

    set sum = num1 + num2;

    return sum;
end $
delimiter ;

select add_float(12.2, 2.3);

# 2.流程控制

# 1).创建函数test_if_case，实现传入成绩，如果成绩>90，返回A，如果成绩>80，返回B，如果成绩>60，返回C，否则返回D
# 分别使用if和case结构实现
delimiter $
create function test_if_case1(score double)
    returns char
begin
    declare grade char;

    if score > 90 then
        set grade = 'A';
    elseif score > 80 then
        set grade = 'B';
    elseif score > 60 then
        set grade = 'C';
    else
        set grade = 'D';
    end if;

    return grade;
end $
delimiter ;

select test_if_case1(56);

delimiter $
create function test_if_case2(score double)
    returns char
begin
    declare grade char;

    case
        when score > 90 then set grade = 'A';
        when score > 80 then set grade = 'B';
        when score > 60 then set grade = 'C';
        else set grade = 'D';
        end case;

    return grade;
end $
delimiter ;

select test_if_case2(65.5);

# 2).创建存储过程test_if_pro()，传入工资，如果工资值<3000，要删除工资为此值的员工，如果3000<=工资<=5000，则涨薪1000，否则涨500
delimiter $
create procedure test_if_pro(in sal double)
begin
    if sal < 3000 then
        delete from employees where salary = sal;
    elseif sal <= 5000 then
        update employees set salary = salary + 1000 where salary = sal;
    else
        update employees set salary = salary + 500 where salary = sal;
    end if;
end $
delimiter ;

select *
from employees;

call test_if_pro(2900);

# 3).创建存储过程insert_data，传入参数为in的int类型变量insert_count，实现向admin表中批量插入insert_count条记录
create table admin
(
    id        int primary key auto_increment,
    user_name varchar(25) not null,
    user_pwd  varchar(35) not null
);

select *
from admin;

delimiter $
create procedure insert_data(in insert_count int)
begin
    declare count int default 1;

    while count <= insert_count
        do
            insert into admin(user_name, user_pwd)
            values (concat('uestc-', count), round(rand() * 100000));
            set count = count + 1;
        end while;
end $
delimiter ;

call insert_data(100);
select *
from admin;

# 3.游标的使用
# 创建存储过程update_salary，参数1为int型变量dept_id，表示部门id，参数2为int型change_sal_count，表示要调整薪资的员工个数
# 按照salary升序排列，根据hire_date情况，调整前change_sal_count个员工的薪资
delimiter $
create procedure update_salary(in dept_id int, in change_sal_count int)
begin
    declare count int default 1;
    declare cur_hire_date date;
    declare cur_emp_id int;
    declare add_sal_rate double;

    declare emp_cursor cursor for select employee_id, hire_date
                                  from employees
                                  where department_id = dept_id
                                  order by salary;

    open emp_cursor;

    while count <= change_sal_count
        do
            fetch emp_cursor into cur_emp_id, cur_hire_date;

            if year(cur_hire_date) < 1995 then
                set add_sal_rate = 1.2;
            elseif year(cur_hire_date) <= 1998 then
                set add_sal_rate = 1.15;
            elseif year(cur_hire_date) <= 2001 then
                set add_sal_rate = 1.1;
            else
                set add_sal_rate = 1.05;
            end if;

            update employees set salary = salary * add_sal_rate where employee_id = cur_emp_id;
            set count = count + 1;
        end while;

    close emp_cursor;
end $
delimiter ;

select * from employees where department_id = 50 order by salary;
call update_salary(50, 2);
