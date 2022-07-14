# 第11章，数据处理之增删改

# 0. 储备工作
use atguigudb;

create table if not exists emp1
(
    id        int,
    'name'    varchar(15),
    hire_date date,
    salary    double(10, 2)
);

desc emp1;

select *
from emp1;

# 1. 添加数据
# 方式一：一条一条的添加数据
insert into emp1
values (1, 'Tom', '2000-12-21', 3400); # 一定要按照声明的字段的先后顺序添加

insert into emp1(id, hire_date, salary, name)
values (2, '1999-09-09', 4000, 'Jerry');

insert into emp1(id, salary, name)
values (3, 4000, 'shk');

insert into emp1 (id, name, salary)
values (4, 'Jim', 5000),
       (5, '张俊杰', 5500);

# 方式二：将查询结果插入到表中
select *
from emp1;

insert into emp1(id, name, salary, hire_date)
# 查询语句
select employee_id, last_name, salary, hire_date # 查询的字段一定要与添加到表的字段一一对应
from employees
where department_id in (60, 70);

desc emp1;
desc employees;

# 说明：emp1表中要添加数据的字段的长度不能低于employees表中查询的字段的长度
# 如果低于，则有添加不成功的风险

# 2.更新数据（或修改数据）
# update ... set ... where ...
# 可以实现批量修改
update emp1
set hire_date = curdate()
where id = 5;

select *
from emp1;

# 同时修改一条数据的多个字段
update emp1
set hire_date = curdate(),
    salary    = 6000
where id = 4;

# 题目：将表中姓名中包含字符a的提薪20%
update emp1
set salary = salary * 1.2
where name like '%a%';

# 修改数据可能不成功，可能是由于约束的影响造成的
update employees
set department_id = 10000
where employee_id = 102;

# 3.删除数据 delete from ... where ...
delete
from emp1
where id = 1;

# 删除数据也可能因为约束导致删除失败
delete
from departments
where department_id = 50;

# 小结：DML操作默认情况下，执行完都会自动提交数据
# 如果希望执行完不提交数据，则需要使用  set autocommit = false

# 4. 计算列
use atguigudb;

create table if not exists test01
(
    a int,
    b int,
    c int generated always as (a + b) virtual # c字段即计算列
);

insert into test01 (a, b)
values (10, 20);

select *
from test01;

update test01
set a = 100;

# 5.综合案例

# 1、创建数据库 test01_library
create database if not exists test01_library;

use test01_library;

# 2、创建表 books
create table if not exists books
(
    id       int,
    name     varchar(50),
    authors  varchar(100),
    price    float,
    pub_date year,
    note     varchar(100),
    num      int
);

select *
from books;

# 3、向 books 表中插入记录
# (1).不指定字段名称，插入第一条记录
insert into books
values (1, 'Tal of AAA', 'Dickes', 23, '1995', 'novel', 11);

# (2).指定所有字段名称，插入第二条记录
insert into books (id, name, authors, price, pub_date, note, num)
values (2, 'EmmaT', 'Jane lura', 35, '1993', 'joke', 22);

# (3).同时插入多条记录（剩下的所有记录）
insert into books (id, name, authors, price, pub_date, note, num)
values (3, 'Story of Jane', 'Jane Tim', 40, '2001', 'novel', 0),
       (4, 'Lovey Day', 'George Byron', 20, '2005', 'novel', 30),
       (5, 'Old land', 'Honore Blade', 30, '2010', 'law', 0),
       (6, 'The Battle', 'Upton Sara', 30, '1999', 'medicine', 40),
       (7, 'Rose Hood', 'Richard haggard', 28, '2008', 'cartoon', 28);

# 4、将小说类型(novel)的书的价格都增加5
update books
set price = price + 5
where note = 'novel';

# 5、将名称为EmmaT的书的价格改为40， 并将说明改为drama
update books
set price = 40,
    note  = 'drama'
where name = 'EmmaT';

# 6、删除库存为0的记录
delete
from books
where num = 0;

# 7、统计书名中包含字母a字母的书
select *
from books
where name like '%a%';

# 8、统计书名中包含a字母的书的数量和库存总量
select count(*), sum(num)
from books
where name like '%a%';

# 9、找出 novel 类型的书，按照价格降序排列
select *
from books
where note = 'novel'
order by price desc;

# 10、查询图书信息，按照库存量降序排列，如果库存量相同的按照note升序排列
select *
from books
order by num desc, note;

# 11、按照note分类统计书的数量
select count(*), note
from books
group by note;

# 12、按照note分类统计数的库存量，显示库存量超过30本的
select sum(num) "total_num", note
from books
group by note
having total_num > 30;

# 13、查询所有图书，每页显示5本，显示第二页
select *
from books
limit 5, 5;

# 14、按照note分类统计书的库存量，显示库存量最多的
select max(total_num)
from (
         select sum(num) "total_num"
         from books
         group by note
     ) note_total_sum;

select note, sum(num) "total_num"
from books
group by note
order by total_num desc
limit 0, 1;

# 15、查询书名达到10个字符串的书，不包括里面的空格
select *
from books
where length(replace(name, ' ', '')) >= 10;

# 16、查询书名的类型，其中note值为novel显示小说，law显示法律，medicine显示医药，cartoon显示卡通，joke显示笑话
select name,
       case note
           when 'novel' then '小说'
           when 'law' then '法律'
           when 'medicine' then '医药'
           when 'cartoon' then '卡通'
           when 'joke' then '笑话'
           else '其他' end "类型"
from books;

# 17、查询书名、库存，其中num值超过30本的，显示滞销，大于0并低于10的，显示畅销， 为0显示无货
select name,
       case num
           when num > 30 then '滞销'
           when num > 0 and num < 10 then '畅销'
           when num = 0 then '无货'
           end "库存"
from books;

# 18、统计每一种note的库存量，并合计总量
select ifnull(note, '合计库存总量') as note, sum(num)
from books
group by note with rollup;

# 19、统计每一种note的数量，并合计总量
select ifnull(note, '合计总量') as note, count(*)
from books
group by note with rollup;

# 20、统计库存量前三名的书
select *
from books
order by num desc
limit 0, 3;

# 21、找出最早出版的一本书
select *
from books
order by pub_date
limit 0, 1;

# 22、找出novel中价格最高的一本书
select *
from books
where note = 'novel'
order by price desc
limit 0, 1;

# 23、找出书名中字数最多的一本书，不含空格
select *
from books
order by length(replace(name, ' ', '')) desc
limit 0, 1;



