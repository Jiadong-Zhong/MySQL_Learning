# 第十二章
# 关于属性 character set name

# 创建数据库时知名字符集
create database if not exists dbtest12 character set 'utf8';

show create database dbtest12;

# 创建表的时候，指明表的字符集
create table temp
(
    id int
) character set 'utf8';

show create table temp;

# 创建表，指明表的字段时，可以指定字段的字符集
create table temp1
(
    id   int,
    name varchar(15) character set 'gbk'
);

show create table temp1;


# 2.整型数据类型
use dbtest12;
create table test_int1
(
    f1 tinyint,
    f2 smallint,
    f3 mediumint,
    f4 integer,
    f5 bigint
);

desc test_int1;

insert into test_int1(f1)
values (12), (-12), (-128), (127);

select * from test_int1;

insert into test_int1 (f1)
values (128);

create table test_int2
(
    f1 int,
    f2 int(5),
    f3 int(5) zerofill
);

insert into test_int2(f1, f2)
values (123, 123), (123456, 123456);

insert into test_int2(f3)
values (123), (123456);

show create table test_int2;

# 由于在mysql8.0内没有这些效果，后续不再写
