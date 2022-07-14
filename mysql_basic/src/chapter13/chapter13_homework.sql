create database test04_emp;

use test04_emp;

create table emp2
(
    id       int,
    emp_name varchar(15)
);

create table dept2
(
    id        int,
    dept_name varchar(15)
);

# 1、向表emp2的id列中添加主键约束
alter table emp2
    add constraint pk_emp2_id primary key (id);

# 2、向表dept2的id列中添加主键约束
alter table dept2
    add primary key (id);

# 3、向表emp2中添加列dept_id，并在其中定义外键约束，与之相关联的列是dept2表中的id列
alter table emp2
    add column dept_id int;

alter table emp2
    add constraint fk_emp2_dept_id foreign key (dept_id) references dept2 (id);

desc emp2;

# 承接homework11的增删改的综合案例
use test01_library;

desc books;

# 根据题目要求给books表中字段添加约束
# id
alter table books
    add primary key (id);

alter table books
    modify id int auto_increment;

alter table books
    modify id int primary key auto_increment;

# name
alter table books
    modify name varchar(50) not null;

# authors
alter table books
    modify authors varchar(100) not null;

# price
alter table books
    modify price float not null;

# pub_date
alter table books
    modify pub_date year not null;

# num
alter table books
    modify num int not null;


# 1.创建数据库test04_company
create database if not exists test04_company;

use test04_company;

# 2. 按照下表给出的结构在数据库中创建两个数据表 offices 和 employees
create table if not exists offices
(
    officeCode int primary key,
    city       varchar(50) not null,
    address    varchar(50),
    country    varchar(50) not null,
    postalCode varchar(15) unique
);

desc offices;

create table if not exists employees
(
    employeeNumber int primary key auto_increment,
    lastName       varchar(50) not null,
    firstName      varchar(50) not null,
    mobile         varchar(25) unique,
    officeCode     int         not null,
    jobTitle       varchar(50) not null,
    birth          datetime    not null,
    note           varchar(255),
    sex            varchar(5),
    # 表级约束
    constraint fk_emp_officeCode foreign key (officeCode) references offices (officeCode)
);

desc employees_info;

# 3.将表employees的mobile字段修改到officeCode字段后面
alter table employees
    modify mobile varchar(25) after officeCode;

# 4.将表employees的birth字段改名为employee_birth
alter table employees
    change birth employee_birth datetime;

# 5.修改sex字段，数据类型为char(1)，非空约束
alter table employees
    modify sex char(1) not null;

# 6.删除字段note
alter table employees
    drop column note;

# 7. 增加字段名favorite_activity 数据类型为varchar(100)
alter table employees
    add favorite_activity varchar(100);

# 8. 将表employees名称改为employees_info
rename table employees to employees_info;
