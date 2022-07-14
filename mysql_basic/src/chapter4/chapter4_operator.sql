# 算术运算符  + - * / div % mod

SELECT 100, 100 + 0, 100 - 0, 100 + 50, 100 + 50 - 30, 100 + 35.5, 100 - 35.5
FROM dual;

# 在java中，结果是1001
# 在sql中， + 没有连接作用，只表示加法运算，会将字符串转换为数值
SELECT 100 + '1'
FROM dual;

# 此时将'a'看作0处理
SELECT 100 + 'a'
FROM dual;

# NULL 参与运算都为null
SELECT 100 + NULL
FROM dual;

SELECT 100,
       100 * 1,
       100 * 1.0,
       100 / 1.0,
       100 / 2,
       100 + 2 * 5 / 2,
       100 / 3,
       100 DIV 0
FROM dual;

# 取模
SELECT 12 % 3, 12 % 5, 12 MOD -5, -12 % 5, -12 % -5
FROM dual;

# 查询员工id为偶数的员工信息
SELECT employee_id, last_name
FROM employees
WHERE employee_id % 2 = 0;

# 比较运算符

# =  <=>  <> != < <= > >=
# 字符串存在隐式转换，如果转换数值不成功，则看作0
SELECT 1 = 2, 1 != 2, 1 = '1', 1 = 'a', 0 = 'a'
FROM dual;

# 如果字符串和字符串比较，则比较ASCII码
SELECT 'a' = 'a', 'ab' = 'ab', 'a' = 'b'
FROM dual;

# 只要有null参与判断，就为null
SELECT 1 = NULL, NULL = NULL
FROM dual;

# 查询表中commission_pct为null的信息
SELECT last_name, salary, commission_pct
FROM employees
# WHERE salary = 6000;
WHERE commission_pct <=> NULL;

# <=> 安全等于，可以对null判断
SELECT 1 <=> 2, 1 <=> '1', 1 <=> 'a', 0 <=> 'a'
FROM dual;

SELECT 1 <=> NULL, NULL <=> NULL
FROM dual;

# IS NULL   IS NOT NULL   ISNULL()
SELECT last_name, salary, commission_pct
FROM employees
WHERE commission_pct IS NULL;

SELECT last_name, salary, commission_pct
FROM employees
WHERE commission_pct IS NOT NULL;

SELECT last_name, salary, commission_pct
FROM employees
WHERE ISNULL(commission_pct);

# LEAST()  GREATEST()

SELECT LEAST('g', 'b', 't', 'm'), GREATEST('g', 'b', 't', 'm')
FROM dual;

SELECT LEAST(first_name, last_name), LEAST(LENGTH(first_name), LENGTH(last_name))
FROM employees;

# BETWEEN 条件下界 AND 条件上界 (包含边界)
# 查询工资在6000到8000的员工信息
SELECT employee_id, last_name, salary
FROM employees
WHERE salary BETWEEN 6000 AND 8000;

# 交换6000 8000后查询不到数据
SELECT employee_id, last_name, salary
FROM employees
WHERE salary BETWEEN 8000 AND 6000;

# 查询工资不在6000到8000的员工信息
SELECT employee_id, last_name, salary
FROM employees
WHERE salary NOT BETWEEN 6000 AND 8000;

# IN(set)   NOT IN(set)
# 查询部门为10, 20, 30部门员工信息
SELECT employee_id, salary, department_id
FROM employees
WHERE department_id IN (10, 20, 30);

# 查询工资不是6000, 7000, 8000的员工信息
SELECT last_name, salary, department_id
FROM employees
WHERE salary NOT IN (6000, 7000, 8000);

# LIKE : 模糊查询
# 查询last_name中包含字符'a'的员工信息
# % 代表不确定个数的字符(0, 1, 或多个)
SELECT last_name
FROM employees
WHERE last_name LIKE '%a%';

# 查询以'a'开头的员工信息
SELECT last_name
FROM employees
WHERE last_name LIKE 'a%';

# 查询last_name中包含字符'a'且包含字符'e'的员工信息
SELECT last_name
FROM employees
WHERE last_name LIKE '%a%'
  AND last_name LIKE '%e%';

# 查询第二个字符是'a'的员工信息
# _代表一个不确定字符
SELECT last_name
FROM employees
WHERE last_name LIKE '_a%';

# 查询第二个字符是_且第三个字符是'a'的员工信息
# 需要使用转义字符 \
SELECT last_name
FROM employees
WHERE last_name LIKE '_\_a%';

# 正则表达式 REGEXP   RLIKE
SELECT 'shkstart' REGEXP '^s', 'shkstart' REGEXP 't$', 'shkstart' REGEXP 'hk'
FROM dual;

SELECT 'atguigu' REGEXP 'gu.gu', 'atguigu' REGEXP '[ab]'
FROM dual;

# 逻辑运算符  OR || AND && NOT ! XOR
SELECT last_name, salary, department_id
FROM employees
WHERE department_id = 50
  AND salary > 6000;

# 位运算符  & | ^ ~ >> <<
SELECT 12 & 5, 12 | 5, 12 ^ 5
FROM dual;

SELECT 10 & ~1
FROM dual;

SELECT 4 << 1, 8 >> 1
FROM dual