# 第16章

# 1.变量
# 1.1.变量：系统变量(全局系统变量，会话系统变量)  vs  用户自定义变量

# 1.2.查看系统变量
show global variables;

show session variables;

show variables; # 默认查询的是会话系统变量

show global variables like 'admin_%';
show variables like 'character_%';

# 1.3.查看指定系统变量
select @@global.max_connections;
select @@global.character_set_client;

# 报错
select @@session.max_connections;
select @@session.character_set_client;
select @@session.pseudo_thread_id;

select @@character_set_client;
# 先查询会话系统变量，再查询全局系统变量

# 1.4.修改系统变量
# 全局系统变量：
# 方式一：
set @@global.max_connections = 161;
# 方式二：
set global max_connections = 171;
# 针对当前数据库实例有效，一旦重启就失效了

# 会话系统变量
# 方式一：
set @@session.character_set_client = 'gbk';
# 方式二：
set session character_set_connection = 'utf8mb4';
# 针对当前会话有效，一旦结束会话重新建立新的会话就失效了

# 1.5 用户变量
/*
 分类：会话用户变量  vs  局部变量

 会话用户变量：使用 @ 开头，作用域为当前会话
 局部变量：只能使用在存储过程和存储函数中
 */

# 1.6 会话用户变量
create database if not exists dbtest16;
use dbtest16;

create table employees
as
select *
from atguigudb.employees;

create table departments
as
select *
from atguigudb.departments;

# 方式一
set @m1 = 1;
set @m2 := 2;
set @sum := @m1 + @m2;

select @sum;

# 方式二
select @count := count(*)
from employees;
select @count;

select avg(salary)
into @avg_sal
from employees;
select @avg_sal;

# 1.7 局部变量
/*
 (1) 局部变量必须满足：
 局部变量必须使用declare声明，声明并使用在begin...end中（存储过程，存储函数中）
 declare声明的局部变量必须声明在begin的首行位置

 (2) 声明格式
 declare 变量名 类型 [default 值]; # 如果没有default，默认为null

 (3) 赋值：
 方式一：
 set 变量名 = 值
 set 变量名 := 值

 方式二：
 select 字段名或表达式 into 变量名 from 表;

 (4) 使用
 select 局部变量名;
 */

# 举例：
delimiter $
create procedure test_var()
begin
    # 声明局部变量
    declare a int default 0;
    declare b int;
    declare emp_name varchar(25);

    # 赋值
    set a = 1;
    set b := 2;

    select last_name
    into emp_name
    from employees
    where employee_id = 101;

    # 使用
    select a, b, emp_name;
end $
delimiter ;

# 调用过程
call test_var();

# 声明局部变量，并分别赋值为employees表中employee_id为102的last_name和salary
delimiter $
create procedure test_pro()
begin
    declare emp_name varchar(25);
    declare sal double(10, 2) default 0.0;

    select last_name, salary
    into emp_name, sal
    from employees
    where employee_id = 102;

    select emp_name, sal;
end $
delimiter ;

call test_pro();

# 声明两个变量，求和并打印（分别使用会话用户变量、局部变量方式实现）
# 方式一：会话用户变量
set @num1 = 10;
set @num2 = 20;
set @result = @num1 + @num2;
select @result;

# 方式二：局部变量
delimiter $
create procedure add_value()
begin
    declare v1, v2, sum_val int;
    set v1 = 10;
    set v2 = 100;

    set sum_val = v1 + v2;

    select sum_val;
end $
delimiter ;

call add_value();

# 创建存储过程different_salary查询某员工和他领导的薪资差距，并用in参数emp_id输入，用out参数dif_salary输出薪资差距
delimiter $
create procedure different_salary(in emp_id int, out dif_salary double)
begin
    declare emp_salary, mgr_salary double default 0.0;
    declare mgr_id int default 0;

    select salary
    into emp_salary
    from employees
    where employee_id = emp_id;

    select manager_id
    into mgr_id
    from employees
    where employee_id = emp_id;

    select salary
    into mgr_salary
    from employees
    where employee_id = mgr_id;

    set dif_salary = mgr_salary - emp_salary;
end $
delimiter ;

set @emp_id = 102;
call different_salary(@emp_id, @dif_salary);
select @dif_salary;


# 2.定义条件和处理程序
# 2.1 演示
# 2.2 定义条件
# 定义Field_Not_Be_Null错误明与MySQL中违反非空约束的错误类型是ERROR 1048(23000)对应
# 方式一：使用MySQL_error_code

# declare Field_Not_Be_Null condition for 1048;

# 方式二：使用sqlstate_value

# declare Field_Not_Be_Null condition for sqlstate '23000';

# 定义error 1148(42000)错误，名称为command_not_allowed

# declare command_not_allowed condition for 1148;

# declare command_not_allowed condition for sqlstate '42000';

# 2.3 定义处理程序
/*
 举例
 方法一：捕获sqlstate_value
 declare continue handler for sqlstate '42S02' set @info = 'NO_SUCH_TABLE';
 方法二：捕获mysql_error_value
 declare continue handler for 1146 set @info = 'NO_SUCH_TABLE';
 方法三：先定义条件再调用
 declare no_such_table condition for 1146;
 declare continue handler for no_such_table set @info = 'NO_SUCH_TABLE';
 方法四：使用sqlwarning
 declare exit handler for sqlwarning set @info = 'ERROR';
 方法五：使用not found
 declare exit handler for not found set @info = 'NO_SUCH_TABLE';
 方法六：使用sqlexception
 declare exit handler for sqlexception set @info = 'ERROR';
 */

# 2.4 案例处理
delimiter $
create procedure UpdateDataNoCondition()
begin
    # 声明处理程序
    declare continue handler for 1048 set @prc_value = -1;
    # declare continue handler for sqlstate '23000' set @prc_value = -1;

    set @x = 1;
    update employees set email = null where last_name = 'Abel';
    set @x = 2;
    update employees set email = 'aabbel' where last_name = 'Abel';
    set @x = 3;
end $
delimiter ;

call UpdateDataNoCondition();

select @x, @prc_value;

# 创建一个名称为InsertDataWithCondition的存储过程
# 准备过程
alter table departments
    add constraint uk_dept_id unique (department_id);

desc departments;

# 定义存储过程
delimiter $
create procedure InsertDataWithCondition()
begin
    set @x = 1;
    insert into departments(department_name) values ('test');
    set @x = 2;
    insert into departments(department_name) values ('test');
    set @x = 3;
end $
delimiter ;

# [23000][1062] Duplicate entry '0' for key 'departments.uk_dept_id'
call InsertDataWithCondition();

select @x;
# 2

# 删除存储过程
drop procedure InsertDataWithCondition;

# 重新定义存储过程
delimiter $
create procedure InsertDataWithCondition()
begin
    # declare exit handler for 1062 set @pro_value = -1;
    # declare exit handler for sqlstate '23000' set @pro_value = -1;
    declare duplicate_entry condition for 1062;
    declare exit handler for duplicate_entry set @pro_value = -1;

    set @x = 1;
    insert into departments(department_name) values ('test');
    set @x = 2;
    insert into departments(department_name) values ('test');
    set @x = 3;
end $
delimiter ;

call InsertDataWithCondition();
select @x, @pro_value;
# 1 -1  x是1是因为前面已经有插入的值了

# 3.流程控制
# 3.1 分支结构 IF
delimiter $
create procedure test_if()
begin
    declare stu_name varchar(15);
    if
        stu_name is null
    then
        select 'stu_name is null';
    end if;
end $
delimiter ;

call test_if();

drop procedure test_if;

delimiter $
create procedure test_if()
begin
    declare email varchar(25);
    if
        email is null
    then
        select 'email is null';
    else
        select 'email is not null';
    end if;
end $
delimiter ;

call test_if();

drop procedure test_if;

delimiter $
create procedure test_if()
begin
    declare age int default 20;

    if age > 40
    then
        select '中老年';
    elseif age > 18
    then
        select '青壮年';
    elseif age > 8
    then
        select '青少年';
    else
        select '婴幼儿';
    end if;
end $
delimiter ;

call test_if();

# 声明存储过程 update_salary_by_eid1 定义in参数emp_id，输入员工编号
# 判断该员工薪资如果低于8000元且入职时间超过5年，就涨薪500元，否则不变
delimiter $
create procedure update_salary_by_eid1(in emp_id int)
begin
    declare emp_sal double;
    declare emp_year double;

    select salary, datediff(curdate(), hire_date) / 365
    into emp_sal, emp_year
    from employees
    where employee_id = emp_id;

    if emp_sal < 8000 and emp_year >= 5
    then
        update employees
        set salary = salary + 500
        where employee_id = emp_id;
    end if;
end $
delimiter ;

call update_salary_by_eid1(104);
select salary
from employees
where employee_id = 104;

# 声明存储过程update_salary_by_eid2，定义in参数emp_id，输入员工编号
# 判断该员工薪资如果低于9000元并且入职时间超过5年，就涨薪500元，否则就涨薪100元
delimiter $
create procedure update_salary_by_eid2(in emp_id int)
begin
    declare emp_sal double;
    declare emp_year double;

    select salary, datediff(curdate(), hire_date) / 365
    into emp_sal, emp_year
    from employees
    where employee_id = emp_id;

    if emp_sal < 9000 and
       emp_year > 5
    then
        update employees
        set salary = salary + 500
        where employee_id = emp_id;
    else
        update employees
        set salary = salary + 100
        where employee_id = emp_id;
    end if;
end $
delimiter ;

select salary, datediff(curdate(), hire_date) / 365, employee_id
from employees
where salary < 9000
  and datediff(curdate(), hire_date) / 365 >= 5;

call update_salary_by_eid2(103);
call update_salary_by_eid2(104);

select *
from employees
where employee_id in (103, 104);

# 声明存储过程 update_salary_by_eid3，定义in参数emp_id，输入员工编号
# 判断该员工薪资如果低于9000元，就更新薪资为9000元；如果大于9000元且低于10000，奖金比例为null，就更新奖金比例为0.01，其他的涨薪100

delimiter $
create procedure update_salary_by_eid3(in emp_id int)
begin
    declare emp_sal double;
    declare emp_pct double;

    select salary
    into emp_sal
    from employees
    where employee_id = emp_id;

    if emp_sal < 9000
    then
        update employees
        set salary = 9000
        where employee_id = emp_id;
    elseif emp_sal < 10000
    then
        select commission_pct
        into emp_pct
        from employees
        where employee_id = emp_id;

        if emp_pct is null
        then
            update employees
            set commission_pct = 0.01
            where employee_id = emp_id;
        end if;
    else
        update employees
        set salary = salary + 100
        where employee_id = emp_id;
    end if;
end $
delimiter ;

select *
from employees
where employee_id in (102, 103, 104);
call update_salary_by_eid3(102);
call update_salary_by_eid3(103);
call update_salary_by_eid3(104);

# 3.2 分支结构 case

delimiter $
create procedure test_case()
begin
    declare var int default 2;

    case var
        when 1 then select 'var = 1';
        when 2 then select 'var = 2';
        when 3 then select 'var = 3';
        else select 'other value';
        end case;
end $
delimiter ;

call test_case();

drop procedure test_case;

delimiter $
create procedure test_case()
begin
    declare var1 int default 10;
    case
        when var1 >= 100 then select '三位数';
        when var1 >= 10 then select '两位数';
        else select '个位数';
        end case;
end $
delimiter ;

call test_case();

# 声明存储过程update_salary_by_eid4，定义in参数emp_id，输入员工编号
# 判断该员工薪资如果低于9000元，就更新薪资为9000元，薪资大于等于9000元且低于10000的，但是将近比例为null就更新比例为0.01
# 其他的涨薪100元
delimiter $
create procedure update_salary_by_eid4(in emp_id int)
begin
    declare emp_sal double;
    declare emp_pct double;

    select salary, commission_pct
    into emp_sal, emp_pct
    from employees
    where employee_id = emp_id;

    case
        when emp_sal < 9000
            then update employees set salary = 9000 where employee_id = emp_id;
        when emp_sal < 10000 and emp_pct is null
            then update employees set commission_pct = 0.01 where employee_id = emp_id;
        else update employees set salary = salary + 100 where employee_id = emp_id;
        end case;
end $
delimiter ;

select *
from employees
where employee_id in (103, 104, 105);

call update_salary_by_eid4(103);
call update_salary_by_eid4(104);
call update_salary_by_eid4(105);

# 声明存储过程update_salary_by_eid5，定义in参数emp_id，输入员工编号
# 判断该员工的入职年限，如果是0年，涨薪50，如果是1年，涨薪100，如果2年涨薪200，如果3年涨薪300，如果4年涨薪400，其他涨薪500
delimiter $
create procedure update_salary_by_eid5(in emp_id int)
begin
    declare emp_year int;

    select truncate(datediff(hire_date, curdate()) / 365, 0)
    into emp_year
    from employees
    where employee_id = emp_id;

    case emp_year
        when 0 then update employees set salary = salary + 50 where employee_id = emp_id;
        when 1 then update employees set salary = salary + 100 where employee_id = emp_id;
        when 2 then update employees set salary = salary + 200 where employee_id = emp_id;
        when 3 then update employees set salary = salary + 300 where employee_id = emp_id;
        when 4 then update employees set salary = salary + 400 where employee_id = emp_id;
        else update employees set salary = salary + 500 where employee_id = emp_id;
        end case;
end $
delimiter ;

select *
from employees
where employee_id in (101);
call update_salary_by_eid5(101);

# 4.1 循环结构 loop
delimiter $
create procedure test_loop()
begin
    declare num int default 1;

    loop_label:
    loop
        set num = num + 1;
        if num >= 10 then
            leave loop_label;
        end if;
    end loop loop_label;

    select num;
end $
delimiter ;

call test_loop();

# 当市场环境变好时，公司为了奖励大家，决定给大家涨工资，声明存储过程update_salary_loop，声明out参数num，输出循环次数
# 存储过程中实现循环给大家涨薪，涨薪涨为原来的1.1倍，直到全公司的平均薪资达到12000结束
delimiter $
create procedure update_salary_loop(out num int)
begin
    declare avg_sal double;
    declare loop_count int default 0;

    select avg(salary) into avg_sal from employees;

    loop_lab:
    loop
        if avg_sal > 12000 then
            leave loop_lab;
        end if;
        update employees set salary = salary * 1.1;
        select avg(salary) into avg_sal from employees;
        set loop_count = loop_count + 1;
    end loop loop_lab;

    set num = loop_count;
end $
delimiter ;

select avg(salary)
from employees;

call update_salary_loop(@num);
select @num;

# 4.2 循环结构 while
delimiter $
create procedure test_while()
begin
    declare num int default 1;
    while num <= 10
        do
            set num = num + 1;
        end while;
    select num;
end $
delimiter ;

call test_while();

# 市场环境不好，公司决定暂时降低薪资，声明过程update_salary_while，声明out参数num，输出循环次数
# 实现循环给大家降薪为原来90%，直到平均薪资达到5000结束
delimiter $
create procedure update_salary_while(out num int)
begin
    declare avg_sal double;
    declare while_num int default 0;

    select avg(salary) into avg_sal from employees;

    while avg_sal > 5000
        do
            update employees set salary = salary * 0.9;
            select avg(salary) into avg_sal from employees;
            set while_num = while_num + 1;
        end while;
    set num = while_num;
end $
delimiter ;

select avg(salary)
from employees;
call update_salary_while(@num);
select @num;

# 4.3 循环结构 repeat
delimiter $
create procedure test_repeat()
begin
    declare num int default 1;
    repeat
        set num = num + 1;
    until num >= 10 end repeat;
    select num;
end $
delimiter ;

call test_repeat();

# 市场环境变好，给大家涨薪，声明存储过程update_salary_repeat,声明out参数num,输出循环次数
# 循环给大家涨薪为原来的1.15倍，直到平均薪资达到13000结束
delimiter $
create procedure update_salary_repeat(out num int)
begin
    declare avg_sal double;
    declare repeat_num int default 0;

    select avg(salary) into avg_sal from employees;

    repeat
        update employees set salary = salary * 1.15;
        select avg(salary) into avg_sal from employees;
        set repeat_num = repeat_num + 1;
    until avg_sal > 13000 end repeat;

    set num = repeat_num;
end $
delimiter ;

select avg(salary)
from employees;
call update_salary_repeat(@num);
select @num;

# 5.1 leave的使用
# 创建存储过程 leave_begin，声明int类型in参数num，给begin...end添加标记名，并在其中使用if判断num参数值
# 如果num<=0则使用leave退出，=1查询平均薪资，=2查询最低薪资，>2查询最高薪资
# if之后查询表的总人数
delimiter $
create procedure leave_begin(in num int)
begin_label:
begin
    if num <= 0 then
        leave begin_label;
    elseif num = 1 then
        select avg(salary) from employees;
    elseif num = 2 then
        select min(salary) from employees;
    else
        select max(salary) from employees;
    end if;
    select count(*) from employees;
end $
delimiter ;

call leave_begin(2);

# 当市场环境不好时，决定降低大家薪资，声明存储过程leave_while，声明out参数num输出循环次数，存储过程使用while
# 循环给大家降低薪资为原来薪资的90%，直到全公司的平均薪资小于等于10000，并统计循环次数
delimiter $
create procedure leave_while(out num int)
begin
    declare avg_sal double;
    declare while_num int default 0;

    select avg(salary) into avg_sal from employees;

    while_label:
    while true
        do
            if avg_sal < 10000 then
                leave while_label;
            end if;

            update employees set salary = salary * 0.9;
            select avg(salary) into avg_sal from employees;
            set while_num = while_num + 1;
        end while;
    set num = while_num;
end $
delimiter ;

select avg(salary)
from employees;
call leave_while(@num);
select @num;

# 5.2 iterate
# 定义局部变量num，初始为0，循环执行num++操作，如果num<10继续执行循环，如果num > 15,则退出循环
delimiter $
create procedure test_iterate()
begin
    declare num int default 0;
    loop_label:
    loop
        set num = num + 1;
        if num < 10 then
            iterate loop_label;
        elseif num > 15 then
            leave loop_label;
        end if;
        select 'test';
    end loop;
    select num;
end $
delimiter ;

call test_iterate();

# 6.游标的使用
/*
 声明游标
 打开游标
 使用游标
 关闭游标
 */

# 创建存储过程get_count_by_limit_total_salary，声明in参数 limit_total_salary，double类型
# 声明out参数total_count，int类型，函数的功能可以实现累加薪资最高的几个员工的薪资值
# 直到薪资总和达到limit_total_salary参数的值，返回累加的人数给total_count
delimiter $
create procedure get_count_by_limit_total_salary(in limit_total_salary double, out total_count int)
begin
    # 声明变量
    declare sum_sal double default 0.0;
    declare emp_sal double;
    declare emp_count int default 0;

    # 声明游标
    declare emp_cursor cursor for select salary from employees order by salary desc;

    # 打开游标
    open emp_cursor;

    while sum_sal < limit_total_salary
        do
            # 使用游标
            fetch emp_cursor into emp_sal;
            set sum_sal = sum_sal + emp_sal;
            set emp_count = emp_count + 1;
        end while;

    set total_count = emp_count;

    # 关闭游标
    close emp_cursor;
end $
delimiter ;

call get_count_by_limit_total_salary(200000, @total_count);
select @total_count;
