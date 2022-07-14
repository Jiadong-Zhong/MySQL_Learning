# 查看GBK字符集的比较规则
show collation like 'gbk%';

# 查看UTF8字符集的比较规则
show collation like 'utf8%';

#查看服务器的字符集和比较规则
SHOW VARIABLES LIKE '%_server';

#查看数据库的字符集和比较规则
SHOW VARIABLES LIKE '%_database';

#查看具体数据库的字符集
SHOW CREATE DATABASE dbtest1;

#修改具体数据库的字符集
ALTER DATABASE dbtest1 DEFAULT CHARACTER SET 'utf8' COLLATE 'utf8_general_ci';

use dbtest1;

#查看表的字符集
show create table emp1;
#查看表的比较规则
show table status from dbtest1 like '%emp1';
#修改表的字符集和比较规则
ALTER TABLE emp1 DEFAULT CHARACTER SET 'utf8' COLLATE 'utf8_general_ci';


