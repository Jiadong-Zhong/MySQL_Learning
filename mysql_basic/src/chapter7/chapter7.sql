# 单行函数

# 数值函数
# 基本操作
select abs(-123),
       abs(32),
       sign(-23),
       sign(43),
       pi(),
       ceil(32.32),
       ceiling(-43.23),
       floor(32.32),
       floor(-43.23),
       mod(12, 5)
from dual;

# 取随机数
select rand(), rand(), rand(10), rand(10), rand(-1), rand(-1)
from dual;

# 四舍五入和截断
select round(123.456), round(123.456, 0), round(123.456, 1), round(123.456, 2), round(123.456, -1)
from dual;

select truncate(123.456, 0), truncate(123.456, 1), truncate(129.45, -1)
from dual;

# 单行函数可以嵌套
select truncate(round(123.456, 2), 0)
from dual;

# 角度与弧度转换
select radians(30), radians(45), radians(60), radians(90), degrees(2 * pi()), degrees(radians(60))
from dual;

# 三角函数
select sin(radians(30)), degrees(asin(1)), tan(radians(45)), degrees(atan(1))
from dual;

# 指数和对数
select pow(2, 5), pow(2, 4), exp(2)
from dual;

select ln(exp(2)), log(exp(2)), log10(10), log2(4)
from dual;

# 进制转换
# conv(num, f1, f2) 将f1进制下的num转换成f2进制
select bin(10), hex(10), oct(10), conv(10, 2, 8)
from dual;

# 字符串函数
select ascii('Abcdfsf'), length('hello'), char_length('hello'), length('我们'), char_length('我们')
from dual;

select concat(emp.last_name, ' works for ', mgr.last_name) "details"
from employees emp
         join employees mgr on emp.manager_id = mgr.employee_id;

select concat_ws('-', 'hello', 'world', 'hello', 'beijing')
from dual;

# 字符串的索引从1开始
select insert('hello', 2, 3, 'a'), replace('hello', 'll', 'mmm')
from dual;

select upper('hello'), lower('HelLo')
from dual;

select last_name, salary
from employees
where last_name = 'King';

select left('hello', 2), right('hello', 3), right('hello', 13)
from dual;

# lpad:右对齐效果
# rpad:左对齐效果
select employee_id, last_name, lpad(salary, 10, '*')
from employees;

select trim('    h  el  lo   '), ltrim('    h  el  lo   '), trim('o' from 'ooheollo')
from dual;

select repeat('hello', 4), space(5), strcmp('abc', 'abd')
from dual;

select substr('hello', 2, 2), locate('l', 'hello')
from dual;

select elt(2, 'a', 'b', 'c', 'd'), field('mm', 'gg', 'jj', 'mm', 'dd', 'mm'), find_in_set('mm', 'gg,mm,jj,dd,mm')
from dual;

select employee_id, nullif(length(first_name), length(last_name))
from employees;

# 日期和时间函数
# 获取时间日期函数
select curdate(),
       current_date(),
       curtime(),
       current_time(),
       now(),
       sysdate(),
       utc_date(),
       utc_time()
from dual;

# 日期与时间戳的转换
select unix_timestamp(), from_unixtime(1649684710), unix_timestamp('2021-10-01 12:12:32')
from dual;

# 获取月份、星期、星期数、天数
select year(curdate()),
       month(curdate()),
       day(curdate()),
       hour(curtime()),
       minute(now()),
       second(SYSDATE())
from dual;

select monthname('2021-10-26'),
       dayname('2022-4-11'),
       weekday('2022-4-11'),
       quarter(curdate()),
       week(curdate()),
       dayofyear(now()),
       dayofmonth(now()),
       dayofweek(now())
from dual;

# 日期的操作函数
select extract(second from now()), extract(day from now()), extract(hour_minute from now())
from dual;

# 时间和秒钟转换函数
select time_to_sec(curtime()), sec_to_time(79152)
from dual;

# 计算日期和时间的函数
select date_add(now(), interval 1 year),
       date_add(now(), interval -1 year),
       adddate(now(), interval 1 day),
       date_add(now(), interval '1_1' minute_second)
from dual;

# makedate返回给定年份的第多少天，下方例子返回今年的第12天
select addtime(now(), 20),
       subtime(now(), 30),
       subtime(now(), '1:1:3'),
       datediff(now(), '2022-5-1'),
       timediff(now(), '2022-4-11 22:05:10'),
       from_days(366),
       to_days('0000-12-25'),
       last_day(now()),
       makedate(year(now()), 12),
       maketime(10, 21, 23),
       period_add(20200101010101, 10)
from dual;

# 日期的格式化和解析
# 格式化
select date_format(curdate(), '%Y-%M-%D'),
       date_format(curdate(), '%Y-%m-%d'),
       time_format(curtime(), '%H:%i:%S'),
       time_format(curtime(), '%h:%i:%S'),
       date_format(now(), '%Y-%M-%D %h:%i:%S %W %w %T %r')
from dual;

# 解析：格式化的逆过程
select str_to_date('2022-April-11th 10:18:25 Monday 1', '%Y-%M-%D %h:%i:%S %W')
from dual;

select get_format(date, 'USA')
from dual;

select date_format(curdate(), get_format(date, 'USA'))
from dual;

# 流程控制函数
# IF(VALUE, VALUE1, VALUE2)
select last_name, salary, if(salary >= 6000, '高工资', '低工资') "details"
from employees;

select last_name, commission_pct, if(commission_pct is not null, commission_pct, 0) "details"
from employees;

# IFNULL(VALUE1, VALUE2)
select last_name, commission_pct, ifnull(commission_pct, 0) "details"
from employees;

# CASE WHEN ... THEN ... WHEN ... THEN ... ELSE ... END
# 类似java的if ... else if ...
select last_name,
       salary,
       case
           when salary >= 15000 then '白骨精'
           when salary >= 10000 then '潜力股'
           when salary >= 8000 then '小屌丝'
           else '草根' end "details"
from employees;

# CASE ... WHEN ... THEN ... WHEN ... THEN ... ELSE ... END

/*
 查询部门号为10，20，30的员工信息
 若部门号为10，则打印其工资的1.1倍
 20号1.2倍，30号1.3倍，其他1.4倍
 */
select employee_id,
       last_name,
       department_id,
       salary,
       case department_id
           when 10 then salary * 1.1
           when 20 then salary * 1.2
           when 30 then salary * 1.3
           else salary * 1.4 end "details"
from employees;

/*
 查询部门号为10，20，30的员工信息
 若部门号为10，则打印其工资的1.1倍
 20号1.2倍，30号1.3倍
 */
select employee_id,
       last_name,
       department_id,
       salary,
       case department_id
           when 10 then salary * 1.1
           when 20 then salary * 1.2
           when 30 then salary * 1.3
           end "details"
from employees
where department_id in (10, 20, 30);

# 加密与解密
select md5('mysql'), sha('mysql')
from dual;

# 信息函数
select version(), connection_id(), database(), schema(), user(), current_user(), charset('尚硅谷'), collation('尚硅谷')
from dual;

# 其他函数
select format(123.125, 2)
from dual;

select conv(16, 10, 2), conv(8888, 10, 16)
from dual;

select inet_aton('192.168.1.100'), INET_NTOA(3232235876)
from dual;

# 用于测试表达式的执行时间
select benchmark(10000000, md5('mysql'))
from dual;

select charset('atguigu'), charset(convert('atguigu' using 'utf8mb3'))
from dual;
