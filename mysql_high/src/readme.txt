第5章 存储引擎

1.查看存储引擎
show engines;

2.查看默认的存储引擎
select @@default_storage_engine

3.设置默认存储引擎
创建表时通过参数  ENGINE = 引擎名  来指定
修改表的存储引擎通过 ALTER TABLE 表名 ENGINE = 引擎名 来修改

4.引擎介绍
    InnoDB：具备外键支持功能的事务存储引擎
        优点：
            支持事务，支持事务的提交和回滚
            更新、删除操作效率更高
            支持行级锁
        缺点：
            效率差一些、内存要求高(聚簇索引)

    MyISAM：非事务处理存储引擎
        优点：
            访问速度快，对count(*)查询效率高
            适合读和插入为主的应用
        缺点：
            不支持事务，崩溃后无法恢复

第6章 索引的数据结构
1.为什么使用索引
    索引是存储引擎用于快速找到数据记录的一种数据结构
2.索引及其优缺点
    优点：
        降低IO成本
        可以通过唯一索引保证数据的唯一性
        可以加速表和表之间的连接
        可以显著减少查询中分组和排序的时间
    缺点：
        创建和维护索引需要耗费时间
        索引需要占磁盘空间
        会降低更新表的速度
3.InnoDB索引的推演
    在一个页中查找：
        以主键为搜索条件，使用二分
        以其他列作为搜索条件，从最小记录开始依次遍历
    在很多页中查找：
        需要首先定位数据所在的页，然后在所在页中查找记录，在没有索引情况下，需要从第一个页依次查找，十分耗时，因此需要使用索引
    设计索引：
        一步一步迭代为B+树
        为什么B+树通常不超过4层，因为一个页有16kb，4层就可以存放相当多的记录
    常见索引概念：
        聚簇索引：是一种数据存储方式，即所谓的索引即数据，数据即索引，叶子节点存放的是完整的记录
            优点：
                数据访问更快
                节省IO操作
            缺点：
                插入速度严重依赖于插入顺序
                更新主键代价很高
                二级索引访问需要两次索引查找
            限制：
                InnoDB中才有聚簇索引
                表只能有一个聚簇索引
                如果没有定义主键，会选择非空的唯一索引代替，如果没有这样的索引，会隐式的定义一个主键来作为局促索引
                选用有序的顺序id
        二级索引(辅助索引、非聚簇索引)：
            需要一次回表
        联合索引：
            多个字段联合创建索引
    B+树索引的注意事项：
        根页面位置万年不动
        内节点中目录项记录的唯一性
        一个页面最少存储两条记录
4.MyISAM中的索引方案
    同样使用B+树作为索引结构
    MyISAM中没有聚簇索引
    MyISAM索引存储的是地址
    MyISAM一定要回表查询，可以没有主键
5.索引的代价
    空间上：索引都要占有存储空间
    时间上：增删改操作需要维护索引
6.MySQL数据结构选择的合理性：
    磁盘的IO数是至关重要的

    哈希结构查询效率很高，但是不适合范围查询，且没有顺序，无法单独的一个键或者几个索引键进行查询，如果列的重复值较多，会发生Hash冲突，效率降低
    但是InnoDB有自适应哈希索引，如果某个数据经常被访问，当满足一定条件时，会存放到哈希表中

    AVL树的深度也比较深，IO次数也比较多
    为了减少IO，使树更加矮胖，使用B树，但是B树的非叶子节点也会存放数据
    B+树非叶子节点不存放数据，查询效率更稳定，一般只需要1-3次IO

第7章 InnoDB数据存储结构
1.数据库的存储结构：页
    磁盘与内存交互的基本单位：页
    InnoDB页的默认大小为16KB

    页的上层概念是区，一个区有64个页，一个区大小为1MB
    区的上层结构是段，段是数据库中的分配单位
    段的上层结构是表空间

2.页的内部结构
    按类型划分：
        数据页(保存B+树节点)，系统页，Undo页，事务数据页
    页的结构：
        文件头 38字节
        页头 56字节
        最大和最小记录 26字节
        用户记录 不确定
        空闲记录 不确定
        页目录 不确定
        文件尾 8字节

    第一部分：文件头和文件尾
        文件头：
            4字节 页的校验和 检测数据是否一致(当内存和磁盘进行IO操作时，如果因为某些原因没有能够正常完成，则头尾的校验和会不一致，就可以检测出数据不一致)
            4字节 页号 通过页号唯一定位页号
            4字节 上一页的页号
            4字节 下一页的页号
            8字节 页面被最后修改时对应的日志序列位置
            2字节 页的类型 主要由日志页、索引页、系统页、Undo日志页等
            8字节 仅在系统表空间的一个页中定义，代表文件至少被刷新到了对应的LSN值 同样也是为了校验页的完整性
            4字节 页属于的表空间
        文件尾：
            4字节 校验和
            4字节 页面被最后修改时对应的日志序列位置(LSN)
    第二部分：空闲空间，用户记录，最大最小记录
        空间空间，按照指定行格式存储到用户记录中
        用户空间，按照指定行格式存储数据
        最大最小记录，都是由13个字节组成，前5个字节是记录头信息(详见Compact行格式)，后8个字节是固定部分，分别代表infimum和supremum
    第三部分：页目录和页头
        页目录 方便在页中快速查找到记录
            将所有记录分为几个组
            第一组，就是最小记录所在的组，只有1条记录。最后一组是最大记录所在组，会有1-8条记录，其余4-8条之间，目的是让其余的组尽量平分
            每组中最后一条记录的头信息中会存储一共多少小记录，作为n_owned字段
            页目录用来存储每组最后一条记录的地址偏移量，这个偏移量也称为槽(slot)
        页头 56字节
            2字节 PAGE_N_DIR_SLOTS 在页目录中的槽数量
            2字节 PAGE_HEAP_TOP 还未使用的空间最小地址，也就是说该地址之后就是空闲空间
            2字节 PAGE_N_HEAP 本页中的记录和数量(包括最小和最大记录以及标记为删除的记录)
            2字节 PAGE_FREE 第一个已经标记为删除的记录地址
            2字节 PAGE_GARBAGE 已删除记录占用的字节数
            2字节 PAGE_LAST_INSERT 最后插入记录的位置
            2字节 PAGE_DIRECTION 记录插入的方向 如果新插入的记录主键值比上一条记录的大，就说插入方向是右边，反之就是左边
            2字节 PAGE_N_DIRECTION 一个方向连续插入的记录数量
            2字节 PAGE_N_RECS 该页中记录的数量(不包括最小和最大记录以及被标记位删除的记录)
            8字节 PAGE_MAX_TRX_ID 修改当前页的最大事务ID，该值仅在二级索引中定义
            2字节 PAGE_LEVEL 当前页在B+树中所处的层级
            8字节 PAGE_INDEX_ID 索引ID，表示当前页属于哪个索引
            10字节 PAGE_BTR_SEG_LEAF B+树叶字段的头部信息，仅在B+树的Root页定义
            10字节 PAGE_BTR_SEG_TOP B+树非叶字段的头部信息，仅在B+树的Root页定义

3.InnoDB行格式：通过 SELECT @@innodb_default_row_format; 查看

    Compact行格式：
        变长字段长度列表 记录变长字段实际上存储的长度
        NULL值列表 将可以为NULL的列统一管理
        记录头信息(5字节)：
            delete_mask 标记当前记录是否被删除 删除记录实际上只是做一个标记，所有被删除的记录会组成一个垃圾链表，这个链表占用的空间就是可重用空间
            min_rec_mask 每层非叶子节点的最小记录都会添加该标记
            record_type 记录类型：0表示普通记录，1表示非叶子节点记录，2表示最小记录，3表示最大记录
            heap_no 当前记录在本页中的位置 0和1分别表示最小记录和最大记录，由MySQL自动添加，不用手动插入，因此也称为伪记录或者虚拟记录
            n_owned 该组元素的个数
            next_record 从当前记录真实数据到下一条记录真实数据的地址偏移量
        记录的真实数据
            除了定义的数据之外，还有三个隐藏列
            6字节 DB_ROW_ID 如果没有手动定义主键，就会选取一个唯一键作为主键，如果没有唯一键，就用row_id作为主键
            6字节 DB_TRX_ID 事务ID
            7字节 DB_ROLL_PTR 回滚指针
    Dynamic和Compressed行格式
        行溢出：字段存储空间超过页的大小，就会出现行溢出，在Compact和Redundant行格式中，就会进行分页存储
        Dynamic和Compressed遇到行溢出时，会将所有数据都放在溢出页中
        Compressed的行数据会以zlib的算法进行压缩
    Redundant行格式
        字段长度偏移列表 会将该条记录所有列(包括隐藏列)的长度信息都按照逆序存储到字段长度偏移列表
        记录头信息(6字节)：
            相比Compact，多了n_field和1byte_offs_flag两个属性，没有record_type属性
        真实数据

4.区、段与碎片区
    因为随机IO十分慢，因此尽量要顺序IO，所以引入区，区内存储的是物理位置上连续的64个页

    B+树只有叶子节点存放数据，但是页内可能存放叶子节点也可能存放非叶子节点，为了提高效率，将叶子节点的集合划分为一个段，非叶子结点的集合也分为一个段

    假如表中只有很少的数据，只有几条记录，会十分浪费空间，为了解决这个问题，引入了碎片区，碎片区的页可以用于不同的目的，碎片区直属于表空间
        在之后为某段分配存储空间的策略：
            在刚开始插入数据时，由于数据量较小，所以是以碎片区的单个页面为单位存储的
            当段已经占用了32个碎片区之后，就以完整的区为单位来分配存储空间

    区的分类：
        空间区(FREE)：没有用到这个区内的任何页
        有剩余空间的碎片区(FREE_FRAG)：表示碎片区中海油可用的页面
        没有剩余空间的碎片区(FULL_FRAG)：表示碎片区中的所有页面都被使用，没有空闲页面
        附属于某段的区(FSEG)：每个索引都可以分为叶子节点段和非叶子节点段

5.表空间
    可以看做是InnoDB存储引擎结构的最高层，所有数据都存放在表空间中

    独立表空间：
        每张表都有独立的表空间
        使用命令 show variables like 'innodb_file_per_table'; 查看表空间类型

    系统表空间：
        整个MySQL进程只有一个系统表空间，记录有关整个系统信息的页面

第8章 索引的创建与设计原则
    1.索引的声明与使用
        分类：
            功能逻辑：普通索引、唯一索引、主键索引、全文索引
            物理实现：聚簇索引、非聚簇索引
            作用字段个数：单列索引、联合索引

        普通索引：没有附加任何限制条件
        唯一索引：声明UNIQUE参数的字段，一个表内可以有多个唯一索引
        主键索引：特殊的唯一性索引，一个表内最多只有一个主键索引
        单列索引：单个字段上创建的索引，一个表可以有多个单列索引
        多列索引(联合索引)：多个字段组合上创建一个索引，使用遵循最左前缀原则
        全文索引：适合大型数据集

        索引的创建：
            1.创建表时添加索引(隐式)
                在声明有主键约束、唯一性约束、外键约束的字段上，会自动的添加相关的索引

                创建普通索引(显式)
                    CREATE TABLE table_name [col_name data_type]
                    [UNIQUE | FULLTEXT | SPATIAL] [INDEX | KEY] [index_name] (col_name [length]) [ASC | DESC]

                    性能分析工具，EXPLAIN + SQL语句，可以分析是否使用到索引
                创建唯一索引(显式)
                    UNIQUE INDEX index_name(col_name)
                创建主键索引(隐式)
                    通过定义主键约束来添加主键索引
                创建联合索引(显式)
                    显式声明联合索引
                创建全文索引(显式)
                    只能在char、varchar、text列创建
                创建空间索引(显式)

            2.表已经创建成功后添加索引
                ALTER TABLE ... ADD ... INDEX ...
                CREATE INDEX ... ON ...

        索引的删除
            ALTER TABLE ... DROP INDEX ...
            DROP INDEX ... ON ...
            删除联合索引的列时，如果要删除的列为索引的组成部分，则该列也会从索引中删除，如果所有列都删除，则整个索引也会删除

    2.MySQL8.0索引新特性
        支持降序索引，可以进行反向扫描
        隐藏索引，将待删除的索引设置为隐藏索引，使查询优化器不再使用这个索引，确认设置为隐藏后系统不受任何影响，就可以彻底删除索引(软删除)

    3.索引的设计原则
        索引设计不合理或者缺少索引都会造成性能障碍

        哪些情况适合创建索引
            1.字段的数值有唯一性索引
            2.频繁作为WHERE查询条件的字段
            3.经常GROUP BY和ORDER BY的列
                如果同时需要GROUP BY和ORDER BY，建立联合索引，将GROUP BY的字段写前面，ORDER BY的写后面
            4.UPDATE、DELETE的WHERE条件列
                因为我们需要先根据WHERE条件列检索出来记录再进行删除，因此对WHERE字段添加索引能大幅提升效率
                但是需要注意的是：只有更新的字段是非索引字段，提升的效率就会更明显，这是因为非索引字段更新不需要维护索引
            5.DISTINCT字段
            6.多表JOIN连接时，创建索引的注意事项
                连接表的数量尽量不要超过3张
                对WHERE条件创建索引
                对连接的字段创建索引，但是需要注意该字段在多张表的类型必须一致
            7.使用列的类型小的创建索引
                类型大小指的是数据范围的大小
            8.使用字符串前缀创建索引
                使用字符串前缀作为索引能够大幅节省空间
                但是无法使用索引排序，因为看不到后续的字符，可能出现前缀相同，后面其他字符不同的情况
            9.区分度高(散列度高)的列适合作为索引
            10.使用最频繁的列放在联合索引的最左侧
            11.在多个字段都要创建索引的情况下，联合索引优于单值索引

        单张表的索引数量建议不超过6个，因为索引也会占用空间且会影响增删改等语句的性能，优化器在优化时也会分析较多的索引会耗费时间

    4.哪些情况不适合创建索引
        1.WHERE中使用不到的字段
        2.数据量小的表最好不要使用索引
        3.有大量重复数据的列上不要建立索引
            当重复度高于10%的时候也不需要使用索引
        4.避免对经常更新的表创建过多的索引
        5.不建议用无序的值作为索引
        6.删除不再使用或者很少使用的索引
        7.不要定义冗余或重复的索引

第9章 性能分析工具的使用
    数据库调优的目标：响应时间更快、吞吐量更大
    1.数据库服务器的优化步骤
        观察服务器状态：
            是否存在周期性波动，如果存在，加缓存或更改缓存失效策略
            如果不存在周期性波动或者仍然有不规则延迟或卡顿，开启慢查询，使用EXPLAIN，SHOW PROFILING查看是SQL执行时间长还是等待时间长
                如果是SQL等待时间长，调优服务器参数
                如果是SQL执行时间长，需要索引设计优化，JOIN表优化，表设计优化
            如果还没有解决，查看是否达到SQL查询的瓶颈，如果没有，重新检查，否则读写分离、分库分表
    2.查看系统性能参数
        SHOW [GLOBAL | SESSION] STATUS LIKE '参数';
        一些常用的性能参数如下：
            Connections：连接MySQL服务器的次数
            Uptime：MySQL服务器的上线时间
            Slow_queries：慢查询的次数
            Innodb_rows_read：Select查询返回的行数
            Innodb_rows_inserted：执行INSERT操作插入的行数
            Innodb_rows_updated：执行UPDATE操作修改的行数
            Innodb_rows_deleted：执行DELETE操作删除的行数
            Com_select：查询操作的次数
            Com_insert：插入操作的次数，对于批量插入的INSERT操作，只累加一次
            Com_update：更新操作的次数
            Com_delete：删除操作的次数
    3.统计SQL查询的成本：last_query_cost
        这个参数是查看使用了多少个数据页的查询
        但是并不能代表实际的效率，有时候数据页增加了不少但是查询时间并没有增加多少，因为有缓冲池的作用
        使用场景：在多种查询方式可选时，对于比较开销很有用
            位置决定效率：如果页就在缓冲池中，效率就是最高的
            批量决定效率：如果单页随机读，则效率很低
    4.定位执行慢的SQL：慢查询日志
        超过参数long_query_time值的SQL就会记录到慢查询日志中，默认为10s
        默认是没有开启慢查询日志的，如果不是调优需要时，不建议开启

        开启慢查询日志参数
            slow_query_log参数设置开启慢查询日志
            开启后，日志保存在slow_query_log_file保存的路径中
            修改long_query_time阈值
        查看慢查询数据
            SHOW GLOBAL STATUS LIKE '%Slow_queries';
        慢查询日志分析工具
            查看帮助信息
            mysqldumpslow --help
        关闭慢查询日志
            和开启方式一致
        删除慢查询日志
            和正常删除文件一致
            重建日志文件：
                mysqladmin -uroot -p flush-logs slow
    5.查看SQL执行成本：SHOW PROFILE
        如果在show profile中出现了以下任何一条，则sql语句需要优化
            converting HEAP to MyISAM：查询结果太大，内存不够
            Creating tmp table：创建临时表，先拷贝数据到临时表，用完再删除
            Copying to tmp table on disk：把内存中临时表赋值到磁盘上，警惕！
            locked
        show profile命令将被弃用，可以通过information_schema中profiling中查看
    6.分析查询语句：EXPLAIN
        可以用EXPLAIN或DESCRIBE工具做针对性的分析查询语句
            id 在一个大的查询语句中每个SELECT关键字都对应一个唯一的id
                id如果相同，可以认为是一组，从上往下顺序执行
                在所有组中，id值越大，优先级越高越先执行
                id的每个值代表一趟查询，越少越好
            select_type SELECT关键字对应的那个查询的类型
                确定小查询在大查询中扮演一个什么角色
            table 表名
            partitions 匹配的分区信息
            type 针对单表的访问方法，从上到下效率依次减小
                system：表中只有一条记录，并且该表使用的存储引擎的统计数据是精确的，比如MyISAM、Memory，那么该表的访问方法就是system
                const：根据主键或者唯一二级索引列与常数进行等值匹配时，就是const
                eq_ref：如果被驱动表是通过主键或者唯一耳机索引列等值匹配的方式访问(如果该主键或者唯一二级索引是联合索引，所有的索引列都必须进行等值比较)，则为eq_ref
                ref：当普通二级索引与常量进行等值匹配
                fulltext
                ref_or_null：如果等值匹配时该索引列的值也可以为null时
                index_merge：or两边的字段都使用索引进行查询
                unique_subquery：在一些包含IN子查询中，如果优化器决定将IN子查询转换为EXISTS子查询，而且子查询可以使用到主键进行等值匹配
                index_subquery
                range：索引获取范围区间的记录
                index：索引覆盖，但是需要扫描全部的索引记录
                all：全表扫描
            possible_keys 可能用到的索引
            key 实际上使用的索引
            key_len 实际使用到的索引长度(单位：字节)，检查是否充分用上索引，值越大越好，主要针对联合索引有一定参考意义
            ref 当使用索引列等值查询时，与索引列进行等值匹配的对象信息
            rows 预估的需要读取的记录条数
            filtered 某个表经过搜索条件过滤后剩余记录条数的百分比
                更关注在连接查询中驱动表对应的执行计划记录的filtered值，决定了被驱动表要执行的次数(rows * filtered)
            Extra 一些额外信息
                更准确的理解MySQL到底将如何执行给定的查询语句
                No tables used：当查询语句没有FROM时
                Impossible where：当WHERE语句永远为FALSE时
                Using where：当使用全表扫描并且WHERE语句中有针对该表的搜索条件时，当使用索引来访问并且WHERE语句中有盖索引包含的列之外的其他搜索条件时
                No matching min/max row：当查询有MIN或MAX聚合函数，但是没有符合WHERE搜索条件的记录时
                Using index：查询列表以及搜索条件中指包含属于某个索引的列，也就是可以使用覆盖索引时
                Using index condition：虽然出现了索引列，但是却不能使用到索引
                Using join buffer：在连接查询时，当驱动表不能有效利用索引加快访问速度，MySQL会分配join buffer的内存块来加速查询速度
                Not exists：当使用左外连接时，如果WHERE子句包含要求被驱动表的某列等于NULL的搜索条件，而且那列又是不允许存储NULL的
                Using union：用union索引合并的方式查询
                Using intersect：使用intersect索引
                Using sort_union：使用sort_union索引合并的方式查询
                Zero limit：limit参数为0时
                Using filesort：需要使用文件排序的方式执行查询
                    无法用到索引，只能再内存中或者磁盘中进行排序上进行排序时称为文件排序
                Using temporary：需要建立内部临时表来查询时

        EXPLAIN不考虑各种Cache
        EXPLAIN不能显示MySQL在查询时所作的优化工作
        EXPLAIN不会告诉关于触发器、存储过程的信息或用户自定义函数对查询的影响情况
        部分信息是估算的，并非精确值

    7.EXPLAIN的进一步使用
        EXPLAIN可以输出四种格式：传统格式、JSON格式、TREE格式以及可视化输出
        EXPLAIN FORMAT=JSON|TREE ...

        SHOW WARNINGS
            在EXPLAIN之后，可以使用这个语句查看一些扩展信息，MESSAGE就是优化器重写后的语句

    8.分析优化器执行计划：trace
        OPTIMIZER_TRACE可以跟踪优化器做出的各种决策

    9.MySQL监控分析视图-sys schema

第10章 索引优化与查询优化
    索引失效、没有充分利用到索引——索引建立
    关联查询太多JOIN——SQL优化
    服务器调优及各个参数设置——调整my.conf
    数据过多——分库分表

    SQL查询优化的技术有很多，大方向可以分为物理查询优化和逻辑查询优化
        物理查询优化是通过索引和表连接等技术来进行优化
        逻辑查询优化是通过SQL等价变换提升查询效率

    索引失效案例：
        1) 全值匹配不会失效
        2) 最佳左前缀原则
            如果左边的值没有确定，则无法使用此索引
        3) 主键插入顺序
            建议让主键依次递增
        4) 计算、函数、类型转换(自动或手动)导致索引失效
        5) 类型转换导致索引失效
        6) 范围条件右边的列索引失效
            这里右边主要看建立索引的，而不是SQL语句的，因为优化器会自动调整
        7) 不等于索引失效
        8) IS NULL可以使用索引，IS NOT NULL不可以使用索引
        9) LIKE 以 % 开头索引失效
        10) OR前后存在非索引的列
        11) 数据库和表的字符集统一使用utf8mb4
            不同的字符集在比较前需要进行转换，就会造成索引失效

        对于单列索引，尽量选择针对当前query过滤性更好的索引
        组合索引，当前query中过滤性最好的字段在索引字段顺序中越靠前越好
        组合索引尽量选择query中where语句中更多字段的索引
        组合索引如果某个字段可能出现范围查询时，尽量放在索引次序的最后面

    关联查询优化：
        情况1：左外连接
            JOIN左侧的表称为驱动表，右侧的的表称为被驱动表
            对被驱动表添加索引，可以大幅提升效率
            对驱动表添加索引无法避免全表查询
        情况2：内连接
            对于内连接来说，查询优化器是可以决定谁作为驱动表，谁作为被驱动表出现的
            被驱动表上有索引成本是比较低的，如果连接条件中只有一个字段有索引，则有索引的字段所在表会被作为被驱动表
            在连接条件都存在索引的情况下，会选择数据量较小的表作为驱动表，即小表驱动大表

    JOIN语句原理
        MySQL只支持一种表间关联方式，就是嵌套循环(Nested Loop Join)

        简单嵌套循环连接
            从驱动表中一条一条取出数据，然后遍历被驱动表匹配
        索引嵌套循环连接
            为了减少内存表数据的匹配次数，通过被驱动表的索引来匹配，要求被驱动表上必须有索引
        块嵌套循环连接
            为了减少IO次数，不再逐条读取驱动表数据，而是一块一块读取，引入join buffer缓冲区，一次读取一块进行一次性匹配

        整体效率比较：INLJ > BNLJ > SNLJ
        小结果集驱动大结果集(本质是减少外层循环的数据数量)
        为被驱动表匹配的条件增加索引
        增加join buffer size
        减少驱动表不必要字段的查询(增加join buffer缓存的数目)
        使用Join代替子查询

        Hash Join
            从8.0.20开始废弃BNLJ，默认使用Hash Join
            更适合大数据集连接，优化器使用两个表中较小的表在内存中建立关于Join Key的散列表，然后扫描较大表并探测散列表，找出与Hash表匹配的行

    子查询优化：
        子查询可以通过一个SQL语句实现比较复杂的查询，但是执行效率不高：
            因为需要为内存查询语句的结果建立一个临时表，查询完毕后再撤销，这样会消耗很多CPU和IO资源
            子查询的结果集存储的临时表不会存在索引，所以查询也比较慢

            尽量不使用NOT IN或者NOT EXIST，用LEFT JOIN ... ON ... WHERE ... IS NULL替代

    排序优化：
        MySQL支持两种排序，FileSort和Index
            Index排序效率更高
            FileSort一般在内存中排序，占用CPU较多
        优化建议：
            使用WHERE字句和ORDER BY字句中使用索引，在WHERE字句避免全表扫描，ORDER BY字句中避免使用FileSort排序
            尽量使用index完成ORDER BY，如果两个字段后面是相同的列就是用单列索引，如果不同就是用联合索引
            无法使用index时，需要对FileSort方式进行调优

        ORDER BY时不LIMIT，索引失效
        增加LIMIT过滤条件，使用上索引(如果查询的字段是索引内字段，也可以使用索引)
        ORDER BY时顺序错误，索引失效
        ORDER BY时规则不一致，索引失效(顺序错、方向反都无法使用索引)
        无过滤，不索引

        FileSort算法：双路排序和单路排序
            双路排序(慢)：两次扫描磁盘，先取ORDER BY的列进行排序，然后扫描已经排序好的列表
            单路排序(快)：先读取所有列，然后在buffer中进行排序，效率快一些，但是会使用更多的空间
                加入数据较多，超过sort_buffer的大小，则反而会增加大量的IO，得不偿失

        ORDER BY时尽量不要SELECT *，只查询需要使用的字段

    GROUP BY优化
        原则与ORDER BY几乎一致
        先排序再分组，遵循最左前缀匹配原则
        WHERE效率高于HAVING

    优化分页查询：
         在索引上完成排序分页操作，最后根据主键关联回表查询所需要的其他列内容
            SELECT * FROM student t, (SELECT id FROM student ORDER BY id LIMIT 2000000, 10) a WHERE t.id = a.id;
         主键自增的表，可以把limit查询转换为某个位置的查询

    优先考虑覆盖索引
        一个索引包含了满足查询结果的数据就叫覆盖索引
        它包括在查询里的SELECT、JOIN和WHERE用到的所有列
        即 索引列 + 主键 包含 SELECT 到 FROM 之间查询的列

        覆盖索引的利弊
            好处：
                1.避免InnoDB表进行索引的二次查询(回表)
                2.可以把随机IO变成顺序IO加快查询效率
                    由于覆盖索引可以减少树的搜索次数，能够显著提升查询性能，所以使用覆盖索引是一个常用的性能优化手段
            弊端：
                索引字段的维护总是有代价的

    如何给字符串添加索引
        前缀索引，需要设置合适的长度，可以做的既节省空间，又不用额外增加太多的查询成本，前缀的区分度越高越好
        使用前缀索引就用不上覆盖索引对查询性能的优化了，在使用前缀索引之前时需要考虑抉择

    索引下推：
        Index Condition Pushdown(ICP)，是一种在存储引擎层使用索引过滤数据的优化方式
        如果没有ICP，通过索引定位到行的位置后，需要进行回表然后再进行筛选
        开启ICP后，如果部分WHERE条件可以使用索引中的列进行筛选，则会先进行筛选，满足条件的数据才进行回表查询

        好处：可以减少回表的次数，但是加速效果取决于ICP筛选掉的数据的比例

        通过语句set optimizer_switch = 'index_condition_pushdown=off/on'来关闭/开启索引下推

    其他查询优化策略
        EXISTS和IN的区分
            SELECT * FROM A WHERE cc IN (SELECT cc FROM B)
            SELECT * FROM A WHERE EXISTS (SELECT cc FROM B WHERE B.cc=A.cc)
            哪个表小就用哪个表驱动，A表小用EXISTS，B表小用IN

        COUNT(*)与COUNT(具体字段)效率
            COUNT(*)和COUNT(1)没有本质区别
            InnoDB引擎中，COUNT(具体字段)尽量采用二级索引，因为主键采用的是聚簇索引，包含的信息明显会大于二级索引(非聚簇索引)，对于COUNT(*)和COUNT(1)来说，系统会自动采用空间更小的耳机索引来统计

        关于SELECT(*)
            尽量不要写SELECT(*)，MySQL在解析过程中，会查询数据字典将*按序转换成所有列名，会大大耗费资源和时间，且无法使用覆盖索引

        LIMIT 1对优化的影响
            针对全表扫描的语句，如果确定结果集只有一条，那么加上LIMIT 1就不再继续扫描了，这样会加快查询速度
            如果已经对字段建立了唯一索引，那么可以通过索引进行查询，不会全表扫描，就不需要加上了

        多使用COMMIT
            在程序中尽量多使用COMMIT
                COMMIT所能释放的资源：
                    回滚段上用于恢复数据的信息
                    被程序语句获得的锁
                    redo / undo log buffer中的空间
                    管理上述资源的内部花费

    淘宝数据库的主键是如何设计的
        自增ID的问题：(除了简单都是问题)
            1.可靠性不高
                存在自增ID回溯的问题
            2.安全性不高
                对外暴露的接口可以非常容易猜测对应的信息，比如/User/1/这样的接口，非常容易猜测用户ID的值为多少，总用户数量有多少，也可以非常容易的通过接口进行数据爬取
            3.性能差
                自增ID需要在数据库服务端生成
            4.交互多
                业务还需要额外执行一次类似last_insert_id()的函数才能知道刚才插入的自增值，多一次网络的交互
            5.局部唯一性
                是局部唯一而不是全局唯一，对于分布式系统，十分麻烦

        业务字段做主键：
            尽量不要使用跟业务有关的字段做主键，因为无法预测在项目生命周期中，哪个业务字段会因为项目的业务需求而有重复，或者重用之类的情况出现

        淘宝的主键设计：
            猜测：订单ID = 时间 + 去重字段 + 用户ID后6位尾号

        推荐的主键设计：
            非核心业务：对应表的主键自增ID，如告警、日志、监控等信息
            核心业务：至少全局唯一且单调递增

            最简单的设计：UUID
                全局唯一，占用36字节，数据无序，插入性能差

            改造UUID：
                将时间高低位互换，高位在前就可保证递增
                MySQL8使用二进制保存，只需要占16字节

            如果不是8.0，手动设置主键


第11章 数据库的设计规范
    范式：在关系型数据库中，关于数据表设计的基本原则、规则就称为范式
        常见的有六种范式，按照级别从低到高分别为：
            第一范式1NF
            第二范式2NF
            第三范式3NF
            巴斯-科德范式BCNF
            第四范式4NF
            第五范式5NF又称完美范式
        满足高阶的范式一定符合低阶范式的要求

        键和相关属性的概念：
            数据表中常用的集中键和属性的定义：
                超键：能唯一标识元组的属性集叫做超键
                候选键：超键不包括多余的属性，就是候选键
                主键：从候选键中选择一个作为主键
                外键：如果数据表R1中某属性不是该表的主键，而是另一个表R2的主键，那么这个属性集就是数据表R1的外键
                主属性：包含在任一候选键中的属性称为主属性
                非主属性：不包含在任何一个候选键中的属性

        第一范式：
            确保数据表中每个字段的值都有原子性，就是字段不可再分
            原子性具有一定主观性
        第二范式：
            满足第一范式的基础上，数据内每个记录都是可以唯一标识的，所有非主键字段都必须完全依赖主键，不能只依赖主键的一部分
            1NF表示字段属性是要原子性的，2NF表示一张表就是一个独立对象，一张表只表达一个意思
        第三范式：
            在满足第二范式的基础上，确保主键中每个非主键字段都和主键字段直接相关，要求表中非主键字段不能依赖于其他非主键字段

        有点：有助于消除数据冗余，3NF通常被认为在性能、扩展性和数据完整性方面达到了最好的平衡
        缺点：可能降低查询效率。因为范式等级越高，设计出来的表就会越多

    反范式化：
        有的数据看似荣誉，但是对业务是十分重要的，因此需要遵循业务优先的原则，首先满足业务需求，再尽量减少冗余

        为了满足某种商业目标，数据库性能比规范化数据库更重要
        在数据库规范化的同时，要综合考虑数据库的性能
        通过在给定的表中添加额外的字段，以大量减少需要从中搜索信息所需的时间
        通过在给定的表中插入计算列，以方便查询

        反范式的问题：
            存储空间变大了
            一个表中的字段修改，另一个表中冗余字段也需要同步修改，否则数据不一致
            如果更新频繁，会非常消耗资源
            在数据量小的情况下，体现不出优势，可能会让数据库的设计更加复杂

        反范式的使用场景：
            冗余信息有价值或者能大幅度提高查询效率的时候，才会采取反范式化
            增加冗余字段的建议：
                不需要经常修改，查询时不可或缺
            历史快照、历史数据的需要
                反范式化优化常用在数据仓库中，它通常存储历史数据

    巴斯范式BCNF
        是在3NF基础上改进，也称为修正的第三范式或扩充的第三范式
        若一个关系达到了第三范式，并且只有一个候选键，或者每个候选键都是单属性，则达到BCNF
        一般来说，数据库设计符合3NF或BCNF就可以了

    第四范式、第五范式，了解即可

    ER模型
        ER模型也叫实体关系模型，是用来描述现实生活中客观存在的事物、事物的属性，以及事物之间关系的一种数据模型。
        ER模型可以描述信息需求和信息特性，帮助我们理清业务逻辑，从而设计出优秀的数据库

        ER模型有三个要素，分别是实体、属性和关系
            实体可以看做是数据对象，在ER模型中用矩形来标识，实体分为强实体和弱实体，强实体指不依赖于其他实体的实体，弱实体指依赖于其他实体
            属性指实体的联系，在ER模型中用椭圆形来表示
            关系指实体和实体之间的联系，用菱形表示

        关系类型：一对一，一对多，多对多

        ER模型转换为数据表：
            原则：
                一个实体通常转换成一个数据表
                一个多对多的关系，通常也转换为一个数据表
                一对一或者一对多通常使用外键表达
                属性转换为字段

    数据表的设计原则
        “三少一多”
        数据表的个数越少越好
        数据表中的字段个数越少越好
        数据表中联合主键的字段个数越少越好
        使用主键和外键越多越好

    数据库对象编写建议

    PowerDesigner的使用
        数据库建模工具，可以只做数据流程图、概念数据模型、物理数据模型，几乎包括了数据库模型设计的全过程


第12章 数据库其他调优策略
    数据库调优的措施
        调优的目标：吞吐量更大，响应速度更快，减少系统瓶颈

        如何定位调优问题：
            用户的反馈，日志分析，服务器资源使用监控，数据库内部状况监控，其他

        调优的维度和步骤
            第一步：选择合适的DBMS
            第二步：优化表设计
            第三步：优化逻辑查询
            第四步：优化物理查询
            第五步：使用Redis或Memcached作为缓存
            第六步：库级优化
                读写分离，数据分片

    优化MySQL服务器
        优化服务器的硬件
            硬件性能直接决定数据库的性能
            1.配置较大的内存
            2.配置高速磁盘系统
            3.合理分布磁盘IO
            4.配置多处理器

        优化MySQL参数：
            innodb_buffer_pool_size：表示表和索引的最大缓存，值越大，查询速度越快，但是值太大会影响操作系统的性能
            key_buffer_size：索引缓冲区的大小
            table_cache：同时打开表的大树，值越大能同时打开的表的个数越多
            query_cache_size：查询缓冲区的大小
            query_cache_type：是0时则不使用查询缓冲区，但是并不会释放query_cache_size配置的缓冲区内存
            sort_buffer_size：需要进行排序的线程分配的缓冲区的大小
            join_buffer_size：联合查询操作所能使用的缓冲区大小
            read_buffer_size：每个线程连续扫描时为扫描的每个表分配的缓冲区的大小
            innodb_flush_log_at_trx_commit：何时将缓冲区的数据写入日志文件
                为0表示每秒1次将数据写入日志文件并将日志写入磁盘
                为1表示每次提交事务时将数据写入日志文件并将日志写入磁盘
                为2时表示每次提交事务时将数据写入日志文件，每隔1s将日志文件写入磁盘
            innodb_log_buffer_size：事务日志所使用的缓冲区
            max_connection：允许连接到MySQL数据库的最大数量
            back_log：控制MySQL监听TCP端口时设置的积压请求栈的大小(即超过max_connection以后需要等待的栈大小)
            thread_cache_size：线程池缓存线程数量的大小
            wait_timeout：一个请求的最大连接时间
            interactive_timeout：服务器在关闭连接前等待行动的秒数

    优化数据库结构
        拆分表：冷热数据分离
            将操作频率很高的数据放在一个表中(热数据)
            不常用的放在一个表中(冷数据)
        增加中间表
        增加冗余字段
        优化数据类型
            优先选择符合存储需要的最小的数据类型
                对整数类型数据进行优化
                既可以用文本类型也可以用整数类型的字段，要选择整数类型
                尽量避免TEXT、BLOB数据类型
        优化插入记录的速度
            避免使用ENUM类型
            使用TINYINT代替
            使用TIMESTAMP存储时间
            使用DECIMAL存储浮点数

        优化插入记录的速度
            MyISAM的表：
                禁用索引
                禁用唯一性检查
                使用批量插入
                使用LOAD DATA INFILE批量导入
            InnoDB的表：
                禁用唯一性检查
                禁用外键检查
                禁止自动提交

        使用非空约束
            如果业务允许，尽量使用非空约束

        分析表、检查表、优化表
            分析表主要是分析关键词的分布，检查表主要是检查表是否存在错误，优化表主要是消除删除或者更新造成的空间浪费

            分析表：
                使用ANALYZE TABLE分析表的过程中，数据库系统会自动对表加一个只读锁
            检查表：
                在执行过程中也会加上只读锁
            优化表：
                在执行过程中也会加上制度所


        修改数据类型，节省空间的同时要考虑到数据不能超过取值范围
        增加冗余字段的时候，不要忘了确保数据一致性
        把大表拆分，也意味着查询会增加新的连接，从而增加额外的开销和运维成本

    大表优化
        限定查询的范围
        读写分离
        垂直拆分
        水平拆分
            能够支持非常大的数据量的存储，但是分片事务难以解决，跨节点Join性能较差，因此尽量不要对数据分片

    其他调优策略：
        服务器语句超时处理
        创建全局通用表空间
        隐藏索引对调优的帮助


第13章 事务基础知识
    数据库事务概述
        事务是数据库区别于文件系统的重要特性之一
        只有InnoDB支持事务
        事务：一组逻辑操作单元，使数据从一种状态变换到另一种状态
        事务处理的原则：保证所有事务都作为一个工作单元来执行，要么所有操作都被提交，修改永久保存，要么放弃所有修改，回滚到最初状态

        事务的ACID特性
            原子性(atomicity)
            一致性(consistency)
            隔离性(isolation)
            持久性(durability)

            原子性是基础，隔离性是手短，一致性是约束条件，持久性是目的

        事务的状态
            活动的(active) 操作正在执行中
            部分提交的(partially committed) 操作执行完成，但是影响没有刷新到磁盘时，就是部分提交的
            失败的(failed) 活动的或者部分提交的，可能遇到某些错误而无法继续执行
            中止的(aborted) 失败的状态，回滚操作执行完毕后，就是中止的
            提交的(committed) 将部分提交的数据同步到磁盘上之后，就是提交

    如何使用事务
        显式事务
            开启关键字：start transaction 或 begin
            start transaction 后面可以跟 read only / read write(默认) + (with consistent snapshot)
            read only 只读事务，但是可以对临时表进行增删改
            read write 读写事务
            with consistent snapshot 启用一致性读
            保存点 savepoint，可以回滚到事务中某个过程

        隐式事务
            set autocommit = false; 针对DML操作是有效的，对DDL操作无效

            在autocommit为true的情况下，使用start transaction或begin开启事务

        隐式提交数据的情况：
            DDL操作
            隐式使用或修改表，ALTER USER、CREATE USER、GRANT，RENAME USER，REVOKE等语句
            事务控制或关于锁定的语句
                上一个事务还没有提交或回滚时又使用START TRANSACTION或者BEGIN开启事务，上一个事务就会提交
                在autocommit为false时更改为on时也会提交事务
                使用LOCK TABLES、UNLOCK TABLES也会隐式提交事务
            加载数据的语句
                LOAD DATA
            复制的语句
                START SLAVE、STOP SLAVE、RESET SLAVE、CHANGE MASTER TO等
            其他
                ANALYZE TABLE、CACHE INDEX、CHECK TABLE、FLUSH、OPTIMIZE TABLE、REPAIR TABLE、RESET等语句

        completion_type
            为0时是默认情况，当执行commit时会提交事务，在执行下一个事务时，还需要使用start transaction或者begin开启
            为1时，提交事务后，相当于执行了commit and chain，开启一个链式事务，当提交事务后会开启一个相同隔离级别的事务
            为2时，commit = commit and release， 也就是提交后，会自动与服务器断开连接

    事务隔离级别
        数据并发问题
            脏写 事务A修改了另一个未提交事务B修改过的数据
            脏读 事务A读取到已经被事务B更新但是还没提交的数据
            不可重复度 事务A读取了字段，事务B更新了字段，事务A再次读取同一个字段，值不同
            幻读 事务A读取了一个字段，事务B插入了新的行，事务A再次读取，读取到了多的行
                注意删除了数据，再读数据变少不属于幻读，可以归为不可重复读的问题
        SQL中的四种隔离级别
            并发问题的严重性
            脏写 > 脏读 > 不可重复读 > 幻读

            都解决了脏写
            READ UNCOMMITTED 读未提交
                非加锁读，还会发生脏读、不可重复读、幻读
            READ COMMITTED 读已提交
                非加锁读，解决了脏读，会发生不可重复读、幻读
            REPEATABLE READ 可重复读
                非加锁读，解决了脏读、不可重复读，会发生幻读
            SERIALIZABLE 串行化
                是加锁读，解决了脏读、不可重复读、幻读

        使用show variables like 'transaction_isolation';查看隔离级别
        使用SET [GLOBAL|SESSION] TRANSACTION_ISOLATION = 隔离级别;设置隔离级别
            取值：READ-UNCOMMITTED、READ-COMMITTED、REPEATABLE-READ、SERIALIZABLE

    事务的分类：
        扁平事务
            BEGIN开始，COMMIT结束
        带有保存点的扁平事务
            设置了一个保存在，可以回滚到事务中较早的一个状态
        链事务
            一个事务由多个子事务组成
        嵌套事务
            顶层事务控制各层事务，顶层事务之下嵌套的事务是子事务
        分布式事务
            是分布式环境下运行的扁平事务

第14章 MySQL的事务日志
    事务的原子性、一致性、和持久性由redo日志和undo日志来保证
        REDO LOG，提供再写入操作，恢复提交事务修改的页操作，用来保证事务的持久性
            记录的是“物理级别”上的页修改操作，主要为了保证事务的可靠性
        UNDO LOG，回滚行记录到某个特定版本，用来保证事务的原子性、一致性
            记录的是逻辑操作日志，主要用于事务回滚(undo log记录了每个修改的逆操作)和一致性非锁定读

    REDO日志
        为什么需要UNDO日志
            事务要求持久性，对于一个已经提交的事务，在事务提交后即使系统发生了崩溃，所作的修改也不能丢失
            只需要把修改的内容记录一下就可以在即使系统崩溃，重启后也能恢复出来
            InnoDB引擎事务采用了WAL技术(Write-Ahead Logging)，就是先写日志，再写磁盘，这里日志就是redo log

        REDO日志的好处
            好处：
                降低刷盘评率
                占用空间小
            特点：
                REDO日志是顺序写入磁盘的
                事务执行过程中，REDO LOG不断记录
                    REDO LOG是存储引擎层产生的，而BIN LOG是数据库层产生的
                    假如对表有10万行记录的插入，插入过程会一直往REDO LOG记录，而BIN LOG不会记录，只有事务提交后，才会一次写入到BIN LOG文件中

        REDO日志的组成
            可以简单分为两个部分：
                重做日志的缓冲(redo log buffer)，保存在内存中，容易丢失
                    默认大小为16M，课通过参数innodb_log_buffer_size设置
                重做日志文件(redo log file)，保存在硬盘中，是持久的

        REDO的整体流程
            1.先将原始数据从磁盘中读入内存中，修改数据的内存拷贝
            2.生成一条重做日志并写入redo log buffer，记录的是数据被修改后的值
            3.当事务commit时，将redo log buffer中的内容刷新到redo log file，对redo log file采用追加写的方式
            4.定期将内存中修改的数据刷新到磁盘中

        REDO LOG的刷盘策略
            这里的刷盘是指redo log buffer刷盘到redo log file，实际上并不是刷到磁盘中，只是输入到文件系统缓存(page cache, 操作系统为了提高写入效率的优化)
            参数innodb_flush_log_at_trx_commit参数控制刷盘策略
                为0表示每次事务提交不刷盘(InnoDB有后台线程，会每隔1s，同步redo log)
                为1表示每次事务提交都进行同步，刷盘操作(默认值)，效率稍差，但是十分可靠，可以真正保证数据的一致性和持久性
                为2表示每次事务提交时只把redo log buffer写入page cache，不进行同步，什么时候刷盘由操作系统决定，有丢失数据的风险，但是效率最高