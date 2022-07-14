# 第10章，创建和管理表

# 1.创建和管理数据库
# 1.1 如何创建数据库
# 方式一：
create database mytest1; # 使用默认字符集

show create database mytest1;

# 方式二：
create database mytest2 character set 'gbk';

show create database mytest2;

# 方式三（推荐）：如果要创建的数据库已经存在，则创建不成功，但不会报错
create database if not exists mytest2 character set 'utf8';

show create database mytest2;

# 1.2 管理数据库
# 查看当前连接中的数据库都有哪些
show databases;

# 切换数据库
use mytest2;

# 查看当前数据库中有哪些表
show tables;

# 查看当前使用的数据库
select database()
from dual;

# 查看指定数据库下有哪些表
show tables from mysql;

# 1.3 修改数据库
# 更改字符集
alter database mytest2 character set 'utf8';

show create database mytest2;

# 1.4 删除数据库
# 方式一：
drop database mytest1;

# 方式二：（推荐）
drop database if exists mytest1;
drop database if exists mytest2;
show databases;

# 2.如何创建数据表
use atguigudb;
show create database atguigudb;
show tables;

# 方式一：
create table if not exists myempl
(
    id        int,
    emp_name  varchar(15), # 使用varchar必须指明长度
    hire_date date
);

# 查看表结构
DESC myempl;
show create table myempl; # 如果创建表时没有指明使用的字符集，则默认使用表所在的数据库的字符集
select *
from myempl;

# 方式二：基于现有的表
create table myemp2
as
select employee_id, last_name, salary
from employees;

desc myemp2;
desc employees;

select *
from myemp2;

# 查询语句中字段的别名，可以作为新创建表的字段名
# 此时的查询语句可以结构比较丰富，使用前面章节讲过的各种select
create table myemp3
as
select e.employee_id emp_id, e.last_name lname, d.department_name
from employees e
         join departments d on d.department_id = e.department_id;

select *
from myemp3;

desc myemp3;

# 练习一：创建一个表employees_copy，实现对employees表的复制，包括表数据
create table if not exists employees_copy
as
select *
from employees;

# 练习二：创建一个表employees_blank，实现对employees表的复制，不包括表数据
create table if not exists employees_blank
as
select *
from employees
# where department_id > 10000;
where 1 = 2;

select *
from employees_blank;

# 3.修改表  --> alter
# 3.1 添加一个字段
alter table myempl
    add salary double(10, 2); # 默认添加到表中的最后一个字段位置

alter table myempl
    add phone_number varchar(20) first;

alter table myempl
    add email varchar(45) after emp_name;

# 3.2 修改一个字段：数据类型、长度、默认值
alter table myempl
    modify emp_name varchar(25);

alter table myempl
    modify emp_name varchar(35) default 'aaa';

# 3.3 重命名一个字段
alter table myempl
change salary monthly_salary double(10, 2);

alter table myempl
change email my_email varchar(50);

# 3.4 删除一个字段
alter table myempl
drop column my_email;

# 4.重命名表
# 方式一：
rename table myempl
to myemp1;

# 方式二：
alter table myemp2
rename to myemp12;

# 5.删除表
drop table if exists myemp2;
drop table if exists myemp12;

# 6.清空表
# 清空数据，表结构保留
truncate table employees_copy;
select * from employees_copy;

# 7、DCL中 COMMIT 和 ROLLBACK
# COMMIT 提交数据，一旦执行得数据永久保存在了数据中，意味着数据不可以回滚
# ROLLBACK 回滚数据，一旦执行ROLLBACK，则可以实现数据的回滚。回滚到最近的一次COMMIT之后

# 8. 对比 truncate table 和 delete from
# 相同点：都可实现对表中所有数据的删除，同时保留表的结构
# 不同点：
# TRUNCATE TABLE 一旦执行，表数据全部清除，同时，数据不可以回滚
# DELETE FROM 一旦执行，表数据可以全部清除，也可以部分删除，同时，数据可以回滚

/*
    9. DDL 和 DML 的说明
    DDL的操作一旦执行就不可回滚，SET autocommit = FALSE 对DDL无效，因为执行完DDL之后，一定会执行COMMIT，且不受SET影响
    DML的操作默认情况下一旦执行也不可回滚，但是，如果在执行DML之前，执行了SET autocommit = FALSE，则可以回滚
 */

# 演示：
# DELETE FROM
commit;

select *
from myemp3;

set autocommit = false;
delete from myemp3;

select *
from myemp3;

rollback;

# TRUNCATE TABLE
select *
from myemp3;

commit;

select *
from myemp3;

set autocommit = false;
truncate table myemp3;

select *
from myemp3;

rollback;

select *
from myemp3;

# 9.DDL的原子化
create database mytest;

use mytest;

create table book1(
    book_id int,
    book_name varchar(255)
);

show tables;

# 应该是回滚的，不会删除book1，但是在idea中编译时错误
# drop table book1, book2;
