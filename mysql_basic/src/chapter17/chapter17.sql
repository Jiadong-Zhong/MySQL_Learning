# chapter17 触发器

create database dbtest17;
use dbtest17;

create table test_trigger
(
    id     int primary key auto_increment,
    t_note varchar(30)
);

create table test_trigger_log
(
    id    int primary key auto_increment,
    t_log varchar(30)
);

select *
from test_trigger;

select *
from test_trigger_log;

# 1.创建触发器
# 创建名为before_insert_test_tri的触发器，向test_trigger数据表插入数据之前
# 向test_trigger_log数据表中插入before_insert的日志信息
delimiter $
create trigger before_insert_test_tri
    before insert
    on test_trigger
    for each row
begin
    insert into test_trigger_log(t_log)
    values ('before insert...');
end $
delimiter ;

# 测试
insert into test_trigger(t_note)
values ('Tom...');

# 创建名称为after_insert的触发器，向test_trigger数据表插入数据后，
# 向test_trigger_log数据表中插入after_insert的日志信息
delimiter $
create trigger after_insert
    after insert
    on test_trigger
    for each row
begin
    insert into test_trigger_log(t_log)
    values ('after insert...');
end $
delimiter ;

# 测试
insert into test_trigger (t_note)
values ('Jerry...');

# 定义触发器salary_check_trigger，基于员工表employees的insert事件
# 在insert之前检查要添加的新员工薪资是否大于他领导的薪资，如果大于领导薪资，则报sqlstate_value为HY000的错误，使得添加失败
create table employees
as
select *
from atguigudb.employees;

create table departments
as
select *
from atguigudb.departments;

desc employees;

delimiter $
create trigger salary_check_trigger
    before insert
    on employees
    for each row
begin
    declare mgr_salary double;

    select salary into mgr_salary from employees where employee_id = new.manager_id;

    if new.salary > mgr_salary then
        signal sqlstate 'HY000' set message_text = '薪资高于其领导薪资的错误';
    end if;
end $
delimiter ;

# 添加成功
insert into employees(employee_id, last_name, email, hire_date, job_id, salary, manager_id)
values (300, 'Tom', 'tom@126.com', curdate(), 'AD_VP', 8000, 103);

# 添加失败：[HY000][1644] 薪资高于其领导薪资的错误
insert into employees(employee_id, last_name, email, hire_date, job_id, salary, manager_id)
values (301, 'Tom1', 'tom1@126.com', curdate(), 'AD_VP', 10000, 103);

select *
from employees;

# 2.查看触发器
show triggers;

show create trigger salary_check_trigger;

select * from information_schema.TRIGGERS;

# 3.删除触发器
drop trigger if exists after_insert;
