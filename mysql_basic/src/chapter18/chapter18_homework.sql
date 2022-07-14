# 1. 创建数据表
create database test18_mysql80;
use test18_mysql80;

CREATE TABLE students
(
    id      INT PRIMARY KEY AUTO_INCREMENT,
    student VARCHAR(15),
    points  TINYINT
);

# 2. 向表中添加数据如下
INSERT INTO students(student, points)
VALUES ('张三', 89),
       ('李四', 77),
       ('王五', 88),
       ('赵六', 90),
       ('孙七', 90),
       ('周八', 88);

# 3.分别使用rank，dense_rank，row_number函数对学生成绩降序排列情况进行显示
select rank() over (order by points desc)       as 'rank',
       dense_rank() over (order by points desc) as 'dense_rank',
       row_number() over (order by points desc) as row_num,
       student,
       points
from students;

select rank() over w       as 'rank',
       dense_rank() over w as 'dense_rank',
       row_number() over w as row_num,
       student,
       points
from students
    window w as (order by points desc);
