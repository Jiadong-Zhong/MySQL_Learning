create table emps
as
select employee_id, last_name, salary
from atguigudb.employees;

# 1.复制一张emps表的空表emps_back，只有表结构，不包含任何数据
create table emps_back
as
select *
from emps
where 1 = 2;

# 2.查询emps_back表中的数据
select *
from emps_back;

# 3.创建触发器emps_insert_trigger，每当向表中添加一条记录时，同步将这条记录添加到emps_back表中
delimiter $
create trigger emps_insert_trigger
    after insert
    on emps
    for each row
begin
    insert into emps_back(employee_id, last_name, salary)
    values (new.employee_id, new.last_name, new.salary);
end $
delimiter ;

# 4.验证触发器是否起作用
insert into emps (employee_id, last_name, salary)
values (300, 'Tom', 3400);

select *
from emps;

select *
from emps_back;


# 1.复制一张emps表的空表emps_back1，只有表结构，不包含任何数据
create table emps_back1
as
select *
from emps
where 1 = 2;

# 2.查询emps_back1中的数据
select *
from emps_back1;

# 3.创建触发器emps_del_trigger，每当向emps表中删除一条记录时，同步将删除的这条记录添加到emps_back1中
delimiter $
create trigger emps_del_trigger
    before delete
    on emps
    for each row
begin
    insert into emps_back1(employee_id, last_name, salary)
    values (old.employee_id, old.last_name, old.salary);
end $
delimiter ;

# 4.验证触发器是否起作用
delete from emps
where employee_id = 300;

select *
from emps;

select *
from emps_back1;
