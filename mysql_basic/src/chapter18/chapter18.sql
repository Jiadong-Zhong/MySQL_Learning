# 8.0新特性
create database if not exists dbtest18;

use dbtest18;

# 1.窗口函数
# 1.1 窗口函数的效果
create table sales
(
    id          int primary key auto_increment,
    city        varchar(15),
    country     varchar(15),
    sales_value decimal
);

insert into sales (city, country, sales_value)
values ('北京', '海淀', 10.00),
       ('北京', '朝阳', 20.00),
       ('上海', '黄埔', 30.00),
       ('上海', '长宁', 10.00);

select *
from sales;

# 现在计算网站在每个城市的销售总额，在全国的消瘦总额，每个区在城市销售的比率，以及占总销售额的比率
# 创建临时表
create temporary table a
select sum(sales_value) as sales_value
from sales;

select *
from a;

create temporary table b
select city, sum(sales_value) as sales_value
from sales
group by city;

select *
from b;

select s.city                        as '城市',
       s.country                     as '区',
       s.sales_value                 as '区销售额',
       b.sales_value                 as '市销售额',
       s.sales_value / b.sales_value as '市销售额比率',
       a.sales_value                 as '总销售额',
       s.sales_value / a.sales_value as '总比率'
from sales s
         join b on s.city = b.city
         join a
order by s.city, s.country;

select city                                                    as '城市',
       country                                                 as '区',
       sales_value                                             as '区销售额',
       sum(sales_value) over (partition by city)               as '市销售额',
       sales_value / sum(sales_value) over (partition by city) as '市比率',
       sum(sales_value) over ()                                as '总销售额',
       sales_value / sum(sales_value) over ()                  as '总比率'
from sales
order by city, country;

# 2. 介绍窗口函数
create table employees
as
select *
from atguigudb.employees;

select *
from employees;

# 准备工作
CREATE TABLE goods
(
    id          INT PRIMARY KEY AUTO_INCREMENT,
    category_id INT,
    category    VARCHAR(15),
    NAME        VARCHAR(30),
    price       DECIMAL(10, 2),
    stock       INT,
    upper_time  DATETIME
);

INSERT INTO goods(category_id, category, NAME, price, stock, upper_time)
VALUES (1, '女装/女士精品', 'T恤', 39.90, 1000, '2020-11-10 00:00:00'),
       (1, '女装/女士精品', '连衣裙', 79.90, 2500, '2020-11-10 00:00:00'),
       (1, '女装/女士精品', '卫衣', 89.90, 1500, '2020-11-10 00:00:00'),
       (1, '女装/女士精品', '牛仔裤', 89.90, 3500, '2020-11-10 00:00:00'),
       (1, '女装/女士精品', '百褶裙', 29.90, 500, '2020-11-10 00:00:00'),
       (1, '女装/女士精品', '呢绒外套', 399.90, 1200, '2020-11-10 00:00:00'),
       (2, '户外运动', '自行车', 399.90, 1000, '2020-11-10 00:00:00'),
       (2, '户外运动', '山地自行车', 1399.90, 2500, '2020-11-10 00:00:00'),
       (2, '户外运动', '登山杖', 59.90, 1500, '2020-11-10 00:00:00'),
       (2, '户外运动', '骑行装备', 399.90, 3500, '2020-11-10 00:00:00'),
       (2, '户外运动', '运动外套', 799.90, 500, '2020-11-10 00:00:00'),
       (2, '户外运动', '滑板', 499.90, 1200, '2020-11-10 00:00:00');

select *
from goods;

# 1.序号函数
# 1.1 ROW_NUMBER()
# 查询goods数据表中每个商品分类下价格降序排列的各个商品信息
select row_number() over (partition by category_id order by price desc) as row_num,
       id,
       category_id,
       category,
       name,
       price,
       stock
from goods;

# 查询goods数据表中的每个商品分类下价格最高的3种商品信息
select *
from (select row_number() over (partition by category_id order by price desc) as row_num,
             id,
             category_id,
             category,
             name,
             price,
             stock
      from goods) t
where row_num <= 3;

# 1.2 RANK()
# 使用rank()获取goods表中各类别的价格从高到低排序的各商品信息
select rank() over (partition by category_id order by price desc) as row_num,
       id,
       category_id,
       category,
       name,
       price,
       stock
from goods;

# 1.3 DENSE_RANK()
# 使用dense_rank()获取goods表中各类别的价格从高到低排序的各商品信息
select dense_rank() over (partition by category_id order by price desc) as row_num,
       id,
       category_id,
       category,
       name,
       price,
       stock
from goods;

# 2. 分布函数
# 2.1 percent_rank()函数
# (rank - 1) / (rows - 1)
# 计算goods数据表中名称为 女装/女士精品 类别下商品的percent_rank值
# 方式一：
select rank() over w         as r,
       percent_rank() over w as pr,
       id,
       category_id,
       category,
       name,
       price,
       stock
from goods
where category_id = 1 window w as (partition by category_id order by price desc);

# 方式二：
select rank() over (partition by category_id order by price desc)         as r,
       percent_rank() over (partition by category_id order by price desc) as pr,
       id,
       category_id,
       category,
       name,
       price,
       stock
from goods
where category_id = 1;

# 2.2 cume_dist()函数
# 查询goods数据表中小于或等于当前价格的比例
select cume_dist() over (partition by category_id order by price) as cd,
       id,
       category,
       name,
       price
from goods;

# 3.前后函数
# 3.1 lag(expr, n)函数
# 查询goods数据表中前一个商品价格与当前商品价格的差值
select id,
       category,
       name,
       price,
       pre_price,
       price - pre_price as diff_price
from (select id,
             category,
             name,
             price,
             lag(price, 1) over w as pre_price
      from goods
          window w as (partition by category_id order by price)) t;

# 3.2 lead(expr, n)函数
# 查询goods数据表后一个商品价格与当前商品价格的差值
select id,
       category,
       name,
       price,
       pre_price,
       price - pre_price as diff_price
from (select id,
             category,
             name,
             price,
             lead(price, 1) over w as pre_price
      from goods
          window w as (partition by category_id order by price)) t;

# 4.首尾函数
# 4.1 first_value(expr)函数
# 按照价格排序，查询第一个商品的价格信息
select id,
       category,
       name,
       price,
       stock,
       first_value(price) over w as first_price
from goods
    window w as (partition by category_id order by price);

# 4.2 last_value(expr)函数

# 5.其他函数
# 5.1 nth_value(expr, n)函数
# 查询goods表中排名第二和第三的价格信息
select id,
       category,
       name,
       price,
       nth_value(price, 2) over w as second_price,
       nth_value(price, 3) over w as third_price
from goods
    window w as (partition by category_id order by price);

# 5.2 ntile(n)
# 将goods表中的商品按照价格分为三组
select ntile(3) over w as nt,
       id,
       category,
       name,
       price
from goods
    window w as (partition by category_id order by price);


# 新特性2：公用表表达式

create table departments
as
select *
from atguigudb.departments;

# 2.1 普通公用表表达式
# 查询员工所在的部门详细信息
select *
from departments
where department_id in (select distinct department_id
                        from employees);

# cte实现
with cte_emp
         as (select distinct department_id
             from employees)

select *
from departments d
         join cte_emp e
              on d.department_id = e.department_id;

# 2.2 递归公用表表达式
# 找出公司employees表中的所有下下属
with recursive cte
                   as (select employee_id, last_name, manager_id, 1 as n
                       from employees
                       where employee_id = 100
                       union all
                       select a.employee_id, a.last_name, a.manager_id, n + 1
                       from employees as a
                                join cte on a.manager_id = cte.employee_id)
select employee_id, last_name
from cte
where n >= 3;
