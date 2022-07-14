# 0.准备工作
create database test15_pro_func;
use test15_pro_func;

# 1. 创建存储过程insert_user(), 实现传入用户名和密码，插入到admin表中
create table admin
(
    id        int primary key auto_increment,
    user_name varchar(15) not null,
    pwd       varchar(25) not null
);

delimiter $
create procedure insert_user(in user_name varchar(15), in pwd varchar(25))
begin
    insert into admin(user_name, pwd)
    values (user_name, pwd);
end $
delimiter ;

# 调用
call insert_user('Tom', 'abc123');
select *
from admin;

# 2.创建存储过程get_phone(), 实现传入女神编号，返回女神姓名和女神电话
create table beauty
(
    id    int primary key auto_increment,
    name  varchar(15) not null,
    phone varchar(15) unique,
    birth date
);

insert into beauty(name, phone, birth)
values ('朱茵', '13201233453', '1982-02-12'),
       ('孙燕姿', '13501233653', '1980-12-09'),
       ('田馥甄', '13651230755', '1983-08-21'),
       ('邓紫棋', '17843283452', '1991-11-12'),
       ('刘若英', '18635575464', '1989-05-18'),
       ('杨超越', '13761238755', '1994-05-11');

delimiter $
create procedure get_phone(in id int, out name varchar(15), out phone varchar(15))
begin
    select b.name, b.phone
    into name, phone
    from beauty b
    where b.id = id;
end $
delimiter ;

# 调用
call get_phone(1, @name, @phone);
select @name, @phone;

# 3.创建存储过程date_diff(), 实现传入两个女神生日，返回日期间隔大小
delimiter $
create procedure date_diff(in birth1 date, in birth2 date, out date_gap int)
begin
    select datediff(birth1, birth2) into date_gap;
end $
delimiter ;

set @birth1 = '1992-09-08';
set @birth2 = '1992-10-30';
call date_diff(@birth1, @birth2, @date_gap);
select @date_gap;

# 4.创建存储过程format_date(),实现传入一个日期，格式化成XX年XX月XX日返回
delimiter $
create procedure format_date(in my_date date, out str_date varchar(25))
begin
    select date_format(my_date, '%y年%m月%d日') into str_date;
end $
delimiter ;

call format_date(curdate(), @str_date);
select @str_date;

# 5.创建存储过程beauty_limit(), 根据传入的起始索引和条目数，查询女神表的记录
delimiter $
create procedure beauty_limit(in start_index int, in num int)
begin
    select *
    from beauty
    limit start_index, num;
end $
delimiter ;

call beauty_limit(1, 3);

# 创建带inout模式参数的存储过程
# 6.传入a和b两个值，最终a和b都翻倍并返回
delimiter $
create procedure double_ab(inout a int, inout b int)
begin
    select a * 2, b * 2
    into a, b;
    #     set a = a * 2;
#     set b = b * 2;
end $
delimiter ;

set @a = 2;
set @b = 4;
call double_ab(@a, @b);
select @a, @b;

# 7.删除题目5的存储过程
drop procedure if exists beauty_limit;

# 8.查看题目6中存储过程的信息
show create procedure double_ab;

show procedure status like 'double_ab';

select *
from information_schema.ROUTINES
where ROUTINE_NAME = 'double_ab';


# 0.准备工作
create table employees
as
select *
from atguigudb.employees;

create table departments
as
select *
from atguigudb.departments;

# 无参有返回
# 1.创建函数get_count()，返回公司的员工个数
delimiter $
create function get_count()
    returns int
begin
    return (select count(*)
            from employees);
end $
delimiter ;

select get_count();

# 有参有返回
# 2.创建函数ename_salary(),根据员工姓名，返回他的工资
desc employees;
delimiter $
create function ename_salary(emp_name varchar(25))
    returns double(8, 2)
begin
    return (select salary
            from employees
            where last_name = emp_name);
end $
delimiter ;

select ename_salary('Abel');

# 3.创建函数dept_sal()，根据部门名，返回该部门的平均工资
desc departments;
delimiter $
create function dept_sal(dept_name varchar(30))
    returns double(8, 2)
begin
    return (select avg(salary)
            from employees e
                     join departments d on e.department_id = d.department_id
            where d.department_name = dept_name);
end $
delimiter ;

select dept_sal('Marketing');

# 4.创建函数add_float()，实现传入两个float，返回二者之和
delimiter $
create function add_float(num1 float, num2 float)
    returns float
begin
    return num1 + num2;
end $
delimiter ;

set @v1 = 12.2;
set @v2 = 2.3;
select add_float(@v1, @v2);