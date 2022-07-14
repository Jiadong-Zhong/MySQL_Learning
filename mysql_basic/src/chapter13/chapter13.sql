# chapter13 约束

/*
 1.基础知识
 1.1 为什么需要约束？为了保证数据的完整性

 1.2 什么叫约束？对表中字段的限制。

 1.3 约束的分类：
 角度1：约束的字段的个数
 单列约束  vs  多列约束

 角度2：约束的作用范围
 列级约束：声明此约束时指定在字段后面
 表级约束：在表中所有字段声明之后声明的约束

 角度3：约束的功能
 (1) not null 非空约束
 (2) unique  唯一约束
 (3) primary key 主键约束
 (4) foreign key 外键约束
 (5) check 检查约束
 (6) default 默认值约束

 1.4 如何添加/删除约束
 create table 时添加约束
 alter table 时增加约束、删除约束
 */

# 2.如何查看表中的约束
use atguigudb;
select *
from information_schema.TABLE_CONSTRAINTS
where TABLE_NAME = 'employees';

create database if not exists dbtest13;
use dbtest13;

# 3. not null (非空约束)
# 3.1 在create table时添加约束

create table if not exists test1
(
    id        int         not null,
    last_name varchar(15) not null,
    email     varchar(25),
    salary    decimal(10, 2)
);

desc test1;

insert into test1(id, last_name, email, salary)
values (1, 'Tom', 'tom@126.com', 3400);

# 错误：Column 'last_name' cannot be null
insert into test1(id, last_name, email, salary)
values (2, null, 'tom@126.com', 3400);

# 错误：Column 'id' cannot be null
insert into test1(id, last_name, email, salary)
values (null, 'Jerry', 'jerry@126.com', 3400);

# 错误：Field 'last_name' doesn't have a default value
insert into test1(id, email)
values (2, 'abc@126.com');

# 3.2 在alter table时添加约束
desc test1;

alter table test1
    modify email varchar(25) not null;

# 3.3 在alter table时删除约束
alter table test1
    modify email varchar(25) null;

# 4. 唯一性约束 unique
# 4.1 创建表时添加约束
create table if not exists test2
(
    id        int unique, # 列级约束
    last_name varchar(15),
    email     varchar(25),
    salary    decimal(10, 2),

# 表级约束
    constraint uk_test2_email unique (email)
);

desc test2;

select *
from information_schema.TABLE_CONSTRAINTS
where TABLE_NAME = 'test2';

# 在创建唯一约束的时候，如果不给唯一约束命名，就默认和列名相同

insert into test2(id, last_name, email, salary)
values (1, 'Tom', 'tom@126.com', 4500);

# 错误：Duplicate entry '1' for key 'test2.id'
insert into test2(id, last_name, email, salary)
values (1, 'Tom1', 'tom1@126.com', 4600);

# 错误：Duplicate entry 'tom@126.com' for key 'test2.uk_test2_email'
insert into test2(id, last_name, email, salary)
values (2, 'Tom1', 'tom@126.com', 4600);

# 可以向声明为unique的字段上添加null值，而且可以多次添加null值
insert into test2(id, last_name, email, salary)
values (2, 'Tom1', null, 4600);

insert into test2(id, last_name, email, salary)
values (3, 'Tom2', null, 4600);

select *
from test2;

# 4.2 在alter table时添加约束
desc test2;

update test2
set salary = 5000
where id = 3;

# 方式一
alter table test2
    add constraint uk_test2_salary unique (salary);

# 方式二
alter table test2
    modify last_name varchar(15) unique;

# 4.3 复合的唯一性约束
create table user
(
    id       int,
    name     varchar(15),
    password varchar(25),

# 表级约束
    constraint uk_user_name_pwd unique (name, password)
);

insert into user
values (1, 'Tom', 'abc');
# 也可以成功
insert into user
values (1, 'Tom1', 'abc');

select *
from user;

# 案例：复合的唯一性约束
# 学生表
create table student
(
    sid    int,                 # 学号
    sname  varchar(20),         # 姓名
    tel    char(11) unique key, # 电话
    cardid char(18) unique key  # 身份证号
);

# 课程表
create table course
(
    cid   int,        # 课程编号
    cname varchar(20) # 课程名称
);

# 选课表
create table student_course
(
    id    int,
    sid   int,            # 学号
    cid   int,            # 课程编号
    score int,
    unique key (sid, cid) # 复合唯一
);

insert into student (sid, sname, tel, cardid)
values (1, '张三', '13710011002', '101223199012015623'); # 成功

insert into student (sid, sname, tel, cardid)
values (2, '李四', '13710011003', '101223199012015624'); # 成功

insert into course (cid, cname)
values (1001, 'Java'),
       (1002, 'MySQL'); # 成功

select *
from student;

select *
from course;

insert into student_course (id, sid, cid, score)
values (1, 1, 1001, 89),
       (2, 1, 1002, 90),
       (3, 2, 1001, 88),
       (4, 2, 1002, 56); # 成功

select *
from student_course;

# 错误：Duplicate entry '2-1002' for key 'student_course.sid'
insert into student_course (id, sid, cid, score)
values (5, 2, 1002, 67);

# 4.4 删除唯一性约束
# 添加唯一性约束的列上也会创建唯一索引
# 删除唯一约束只能通过删除唯一索引的方式删除
# 删除时需要制定唯一索引名，唯一索引名就和唯一约束名一样
# 如果创建唯一约束时未指定名称，如果是单列，就默认和列名相同：如果是组合列，那么默认和()中排第一个的列名相同，也可以自定义约束名

select *
from information_schema.TABLE_CONSTRAINTS
where TABLE_NAME = 'test2';

desc test2;

alter table test2
    drop index last_name;

alter table test2
    drop index uk_test2_salary;

# 5. primary key (主键约束)
# 5.1 在创建表时添加约束

# 一个表中最多只能有一个主键约束
# 错误：Multiple primary key defined
create table test3
(
    id        int primary key, # 列级约束
    last_name varchar(15) primary key,
    salary    decimal(10, 2),
    email     varchar(25)
);

# 主键元素特征：非空且唯一，用于唯一的标识表中的一条记录
create table test3
(
    id        int primary key, # 列级约束
    last_name varchar(15),
    salary    decimal(10, 2),
    email     varchar(25)
);

# MySQL的主键名总是PRIMARY，用于唯一标识表中的一条记录
create table test4
(
    id        int,
    last_name varchar(15),
    salary    decimal(10, 2),
    email     varchar(25),
    # 表级约束
    constraint pk_test5_id primary key (id)
);


select *
from information_schema.TABLE_CONSTRAINTS
where TABLE_NAME = 'test4';

insert into test4(id, last_name, salary, email)
values (1, 'Tom', 4500, 'tom@126.com');

# 错误：Duplicate entry '1' for key 'test4.PRIMARY'
insert into test4(id, last_name, salary, email)
values (1, 'Tom', 4500, 'tom@126.com');

# 错误：Column 'id' cannot be null
insert into test4(id, last_name, salary, email)
values (null, 'Tom', 4500, 'tom@126.com');

select *
from test4;

create table user1
(
    id       int,
    name     varchar(15),
    password varchar(25),
    primary key (name, password)
);

# 如果是多列组合的符合主键约束，那么这些列都不允许为空，并且组合的值不允许重复
insert into user1 (id, name, password)
values (1, 'Tom', 'abc');

insert into user1 (id, name, password)
values (1, 'Tom1', 'abc');

# 错误：Column 'name' cannot be null
insert into user1 (id, name, password)
values (1, null, 'abc');

select *
from user1;

# 5.2 在alter table时添加约束
create table test6
(
    id        int,
    last_name varchar(15),
    salary    decimal(10, 2),
    email     varchar(25)
);

desc test6;

alter table test6
    add primary key (id);

# 5.3 如何删除主键约束 (在实际开发中，不会去删除表中的主键约束)
alter table test6
    drop primary key;

# 6. 自增长列：auto_increment
# 6.1 在create table上添加
create table test7
(
    id        int primary key auto_increment,
    last_name varchar(15)
);
# 开发中，一旦主键作用字段加上auto_increment，则我们添加数据时，就不要给主键对应字段赋值了
insert into test7 (last_name)
values ('Tom');

select *
from test7;

# 向包含auto_increment的主键字段上添加0或者null时，实际上会自动添加指定的字段
insert into test7 (id, last_name)
values (0, 'Tom');

insert into test7 (id, last_name)
values (null, 'Tom');

insert into test7 (id, last_name)
values (10, 'Tom');

insert into test7 (id, last_name)
values (-10, 'Tom');

# 6.2 在alter table时添加
create table test8
(
    id        int primary key,
    last_name varchar(15)
);

alter table test8
    modify id int auto_increment;

desc test8;

# 6.3 删除
alter table test8
    modify id int;

# 6.4 8.0新增变量的持久化
create table test9
(
    id int primary key auto_increment
);

insert into test9 (id)
values (0),
       (0),
       (0),
       (0);

select *
from test9;

delete
from test9
where id = 4;

insert into test9
values (0);

delete
from test9
where id = 5;

# 7.foreign key 外键约束
# 7.1 在create table时添加

# 主表和从表，父表和子表

# 先创建主表
create table dept1
(
    dept_id   int,
    dept_name varchar(15)
);

# 再创建从表
create table emp1
(
    emp_id        int primary key auto_increment,
    emp_name      varchar(15),
    department_id int,
    # 表级约束
    constraint fk_emp1_dept_id foreign key (department_id) references dept1 (dept_id)
);

# 操作报错：Failed to add the foreign key constraint. Missing index for constraint 'fk_emp1_dept_id' in the referenced table 'dept1'
# 主表没有主键约束或唯一性约束
alter table dept1
    add primary key (dept_id);

desc dept1;

create table emp1
(
    emp_id        int primary key auto_increment,
    emp_name      varchar(15),
    department_id int,
    # 表级约束
    constraint fk_emp1_dept_id foreign key (department_id) references dept1 (dept_id)
);

desc emp1;

select *
from information_schema.TABLE_CONSTRAINTS
where TABLE_NAME = 'emp1';

# 7.2 演示外键的效果
# 添加失败
insert into emp1
values (1001, 'Tom', 10);

insert into dept1 (dept_id, dept_name)
values (10, 'IT');

# 在主表中添加了10号部门后，就可以在从表中添加10号部门员工
insert into emp1
values (1001, 'Tom', 10);

# 删除失败
delete
from dept1
where dept_id = 10;

# 更新失败
update dept1
set dept_id = 20
where dept_id = 10;

# 7.3 在alter table时添加外键约束
create table dept2
(
    dept_id   int primary key,
    dept_name varchar(15)
);

create table emp2
(
    emp_id        int primary key auto_increment,
    emp_name      varchar(15),
    department_id int
);

select *
from information_schema.TABLE_CONSTRAINTS
where TABLE_NAME = 'emp2';

alter table emp2
    add constraint fk_emp2_dept_id foreign key (department_id) references dept2 (dept_id);

# 7.4 约束等级
# Cascade  Set null  No action  Restrict  Set default
# 结论：对于外键约束，最好采用 ON UPDATE CASCADE ON DELETE RESTRICT 方式

# 7.5 删除外键约束
# 一个表中可以声明多个外键约束
select *
from information_schema.TABLE_CONSTRAINTS
where TABLE_NAME = 'emp1';

alter table emp1
    drop foreign key fk_emp1_dept_id;

# 再删除外键约束对应的索引
show index from emp1;

alter table emp1
    drop index fk_emp1_dept_id;

# 8. check 约束
create table test10
(
    id        int,
    last_name varchar(15),
    salary    decimal(10, 2) check (salary > 2000)
);

insert into test10
values (1, 'Tom', 2500);

# 添加失败
insert into test10 (id, last_name, salary)
values (2, 'Tom1', 1500);

# 9。 default 约束
# 9.1 在create table时添加
create table test11
(
    id        int,
    last_name varchar(15),
    salary    decimal(10, 2) default 2000
);

desc test11;

insert into test11 (id, last_name, salary)
values (1, 'Tom', 3000);

select *
from test11;

insert into test11(id, last_name)
values (2, 'Tom1');

# 9.2 在alter table时添加
create table test12
(
    id        int,
    last_name varchar(15),
    salary    decimal(10, 2)
);

alter table test12
    modify salary decimal(8, 2) default 2500;

desc test12;

# 9.3 删除约束
alter table test12
    modify salary decimal(8, 2);
desc test12;