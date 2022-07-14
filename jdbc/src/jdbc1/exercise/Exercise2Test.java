package jdbc1.exercise;

import jdbc1.bean.Student;
import jdbc1.util.JDBCUtils;
import org.junit.Test;

import java.lang.reflect.Field;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.util.Scanner;

public class Exercise2Test {
    // 问题一，向表中添加一条数据
    @Test
    public void testInsert() {
        Scanner sc = new Scanner(System.in);
        System.out.println("四级/六级：");
        int type = sc.nextInt();
        System.out.println("身份证号：");
        String IDCard = sc.next();
        System.out.println("准考证号：");
        String examCard = sc.next();
        System.out.println("学会姓名：");
        String studentName = sc.next();
        System.out.println("所在城市：");
        String location = sc.next();
        System.out.println("考试成绩：");
        int grade = sc.nextInt();


        String sql = "insert into examstudent(Type, IDCard, ExamCard, StudentName, Location, Grade) values(?,?,?,?,?,?)";
        int insertCount = update(sql, type, IDCard, examCard, studentName, location, grade);
        if (insertCount > 0) {
            System.out.println("添加成功");
        } else {
            System.out.println("添加失败");
        }
    }

    public int update(String sql, Object... args) {
        Connection connection = null;
        PreparedStatement ps = null;
        try {
            connection = JDBCUtils.getConnection();
            ps = connection.prepareStatement(sql);

            for (int i = 0; i < args.length; i++) {
                ps.setObject(i + 1, args[i]);
            }
            /*
                ps.execute()
                如果执行的是查询操作，返回结果集，返回true
                如果执行的是增删改查，无返回值，返回false
             */
            return ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            JDBCUtils.closeResource(connection, ps);
        }
        return 0;
    }


    // 问题2，根据身份证号或者准考证号查询学生成绩信息
    @Test
    public void queryStudent() {
        Scanner sc = new Scanner(System.in);
        String flag;
        System.out.println("请输入您要输入的类型：");
        System.out.println("a:准考证号");
        System.out.println("b:身份证号");
        flag = sc.next();

        switch (flag) {
            case "a" -> {
                System.out.println("请输入准考证号：");
                String examCard = sc.next();
                String sql = "select FlowID flowId, Type type, IDCard idCard, ExamCard examCard, StudentName studentName, Location location, Grade grade from examstudent where ExamCard = ? ";
                Student s = getInstance(Student.class, sql, examCard);
                if (s != null) {
                    printStudent(s);
                } else {
                    System.out.println("查无此人！请重新进入程序");
                }
            }
            case "b" -> {
                System.out.println("请输入身份证号：");
                String idCard = sc.next();
                String sql = "select FlowID flowId, Type type, IDCard idCard, ExamCard examCard, StudentName studentName, Location location, Grade grade from examstudent where IDCard = ? ";
                Student s = getInstance(Student.class, sql, idCard);
                if (s != null) {
                    printStudent(s);
                } else {
                    System.out.println("查无此人！请重新进入程序");
                }
            }
            default -> System.out.println("您的输入有误！请重新进入程序");
        }
    }

    public <T> T getInstance(Class<T> clazz, String sql, Object... args) {
        Connection connection = null;
        PreparedStatement ps = null;
        ResultSet resultSet = null;
        try {
            connection = JDBCUtils.getConnection();
            ps = connection.prepareStatement(sql);
            for (int i = 0; i < args.length; i++) {
                ps.setObject(i + 1, args[i]);
            }

            // 执行并返回结果集
            resultSet = ps.executeQuery();
            // 获取结果集的元数据
            ResultSetMetaData rsmd = resultSet.getMetaData();
            // 获取结果集的列数
            int columnCount = rsmd.getColumnCount();

            // 处理结果集
            if (resultSet.next()) { // 判断结果集下一条是否有数据，有数据返回true，指针下移，返回false，指针不下移
                // 获取当前这条数据的各个字段值
                T t = clazz.getDeclaredConstructor().newInstance();

                for (int i = 0; i < columnCount; i++) {
                    Object columnVal = resultSet.getObject(i + 1);
                    String columnLabel = rsmd.getColumnLabel(i + 1);
                    Field declaredField = clazz.getDeclaredField(columnLabel);
                    declaredField.setAccessible(true);
                    declaredField.set(t, columnVal);
                }
                return t;
            }

        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            // 关闭资源
            JDBCUtils.closeResource(connection, ps, resultSet);
        }
        return null;
    }

    public void printStudent(Student s) {
        System.out.println("========查询结果========");
        System.out.println("流水号:\t" + s.getFlowId());
        System.out.println("四级/六级:\t" + s.getType());
        System.out.println("身份证号:\t" + s.getIdCard());
        System.out.println("准考证号:\t" + s.getExamCard());
        System.out.println("学生姓名:\t" + s.getStudentName());
        System.out.println("区域:\t" + s.getLocation());
        System.out.println("成绩:\t" + s.getGrade());
    }


    // 问题三、根据考号删除学生信息
    @Test
    public void testDeleteByExamCard() {
        Scanner sc = new Scanner(System.in);
        System.out.println("请输入学生的考号：");
        String examCard = sc.next();
        // 查询指定准考证号的学生
        String querySql = "select FlowID flowId, Type type, IDCard idCard, ExamCard examCard, StudentName studentName, Location location, Grade grade from examstudent where ExamCard = ? ";
        Student s = getInstance(Student.class, querySql, examCard);
        if (s != null) {
            String deleteSql = "delete from examstudent where ExamCard = ?";
            int deleteCount = update(deleteSql, examCard);
            if (deleteCount > 0) {
                System.out.println("删除成功");
            }
        } else {
            System.out.println("查无此人，请重新输入");
        }
    }

    @Test
    public void testDeleteByExamCard1() {
        Scanner sc = new Scanner(System.in);
        System.out.println("请输入学生的考号：");
        String examCard = sc.next();
        String deleteSql = "delete from examstudent where ExamCard = ?";
        int deleteCount = update(deleteSql, examCard);
        if (deleteCount > 0) {
            System.out.println("删除成功");
        } else {
            System.out.println("查无此人，请重新输入");
        }
    }
}
