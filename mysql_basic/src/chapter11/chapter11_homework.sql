# 1、创建数据库
create database if not exists dbtest11 character set 'utf8';

# 2、运行一下脚本创建表my_employees
use dbtest11;
create table if not exists my_employees
(
    id         int(10),
    first_name varchar(10),
    last_name  varchar(10),
    userid     varchar(10),
    salary     double(10, 2)
);

create table users
(
    id            int,
    userid        varchar(10),
    department_id int
);

# 3、显示表my_employees的结构
desc my_employees;

# 4、向my_employees表中插入下列数据
insert into my_employees(id, first_name, last_name, userid, salary)
values (1, 'patel', 'Ralph', 'Rpatel', 895),
       (2, 'Dancs', 'Betty', 'Bdancs', 860),
       (3, 'Biri', 'Ben', 'Bbiri', 1100),
       (4, 'Newman', 'Chad', 'Cnewman', 750),
       (5, 'Ropeburn', 'Audrey', 'Aropebur', 1550);

# 5、向表users中插入数据
insert into users (id, userid, department_id)
values (1, 'Rpatel', 10),
       (2, 'Bdancs', 10),
       (3, 'Bbiri', 20),
       (4, 'Cnewman', 30),
       (5, 'Aropebur', 40);

# 6、将3号员工的last_name修改为"drelxer"
update my_employees
set last_name = 'drelxer'
where id = 3;

# 7、将所有工资少于900的员工的工资修改为1000
update my_employees
set salary = 1000
where salary < 900;

# 8、将userid为Bbiri的user表和my_employees表中的记录全部删除
# 方式一
delete
from users
where userid = 'Bbiri';

delete
from my_employees
where userid = 'Bbiri';

# 方式二
delete m, u
from my_employees m
         join users u
              on m.userid = u.userid
where m.userid = 'Bbiri';

# 9、删除my_employees、users表所有数据
delete
from my_employees;
delete
from users;

# 10、检查所作的修正
select *
from my_employees;
select *
from users;

# 11、清空表 my_employees
truncate my_employees;


# 1、使用现有的数据库dbtest11
use dbtest11;

# 2、创建表格pet
create table if not exists pet
(
    name    varchar(20),
    owner   varchar(20),
    species varchar(20),
    sex     char(1),
    birth   year,
    death   year
);

# 3、添加记录
insert into pet
values ('Fluffy', 'harold', 'Cat', 'f', '2003', '2010'),
       ('Claws', 'gwen', 'Cat', 'm', '2004', null),
       ('Buffy', null, 'Dog', 'f', '2009', null),
       ('Fang', 'benny', 'Dog', 'm', '2000', null),
       ('bowser', 'diane', 'Dog', 'm', '2003', '2009'),
       ('Chirpy', null, 'Bird', 'f', '2008', null);

# 4、添加字段，主人的生日owner_birth DATE类型
alter table pet
    add column owner_birth DATE;

# 5、将名称为Claws的猫的主人改为kevin
update pet
set owner = 'kevin'
where name = 'Claws'
  and species = 'Cat';

# 6、将没有死的狗的主任改为duck
update pet
set owner = 'duck'
where death is null
  and species = 'Dog';

# 7、查询没有主人的宠物的名字
select name
from pet
where owner is null;

# 8、查询已经死了的cat的姓名，主人，以及去世时间
select name, owner, death
from pet
where death is not null;

# 9、删除已经死亡的狗
delete
from pet
where death is not null
  and species = 'Dog';

# 10、查询所有宠物信息
select *
from pet;


# 1、使用数据库dbtest11
use dbtest11;

# 2、创建表employee，并添加记录
create table if not exists employee
(
    id     int,
    name   varchar(15),
    sex    char(1),
    tel    varchar(25),
    addr   varchar(35),
    salary double(10, 2)
);

insert into employee(id, name, sex, tel, addr, salary)
values (10001, '张一一', '男', '13456789000', '山东青岛', 1001.58),
       (10002, '刘小红', '女', '13454319000', '河北保定', 1201.21),
       (10003, '李四', '男', '0751-1234567', '广东佛山', 1004.11),
       (10004, '刘小强', '男', '0755-5555555', '广东深圳', 1501.23),
       (10005, '王艳', '女', '020-1232133', '广东广州', 1405.16);

# 3、查询出薪资在1200~1300之间的员工信息
select *
from employee
where salary between 1200 and 1300;

# 4、查询出姓"刘"的员工的员工号，姓名，家庭住址
select id, name, addr
from employee
where name like '刘%';

# 5、将"李四"的家庭住址改为"广东韶关"
update employee
set addr = '广东韶关'
where name = '李四';

# 6、查询出名字中带"小"的员工
select *
from employee
where name like '%小%';
