package com.examora.dao;

import com.examora.model.StudyTask;
import com.examora.model.StudyPlan;
import com.examora.model.Topic;
import com.examora.util.DBConnection;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * StudyTaskDAO handles SQL operations for the 'study_tasks' table.
 * 
 * WHAT: Data Access Object for Study Tasks.
 * WHY: Saves plan schedules, updates completion logs, and resolves dashboard statistics.
 * HOW: Executes parameterized JDBC operations with transactional integrity.
 * WHERE: Placed in the com.examora.dao package.
 */
public class StudyTaskDAO {

    /**
     * Saves a list of StudyTask objects inside a single SQL Transaction.
     * Uses batching to ensure high database performance.
     * 
     * @param tasks the list of tasks to insert
     * @return true if all tasks save successfully
     */
    public boolean saveStudyTasks(List<StudyTask> tasks) {
        if (tasks == null || tasks.isEmpty()) {
            return true;
        }

        String sql = "INSERT INTO study_tasks (study_plan_id, topic_id, scheduled_date, scheduled_hours, completed_hours, status, is_revision, is_mock_test, task_mode) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Begin Transaction

            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                for (StudyTask task : tasks) {
                    stmt.setInt(1, task.getStudyPlanId());
                    stmt.setInt(2, task.getTopicId());
                    stmt.setDate(3, Date.valueOf(task.getScheduledDate()));
                    stmt.setDouble(4, task.getScheduledHours());
                    stmt.setDouble(5, task.getCompletedHours());
                    stmt.setString(6, task.getStatus());
                    stmt.setBoolean(7, task.isRevision());
                    stmt.setBoolean(8, task.isMockTest());
                    stmt.setString(9, task.getTaskMode() != null ? task.getTaskMode() : "LEARN");
                    stmt.addBatch();
                }
                stmt.executeBatch();
            }

            conn.commit(); // Commit all steps
            return true;

        } catch (SQLException e) {
            System.err.println("Error saving study tasks: " + e.getMessage());
            if (conn != null) {
                try {
                    conn.rollback(); // Rollback transaction on failure
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        return false;
    }

    /**
     * Retrieves all study tasks scheduled for a specific plan, joined with their descriptive labels.
     * @param planId the StudyPlan ID
     * @return List of StudyTasks sorted chronologically
     */
    public List<StudyTask> getTasksForPlan(int planId) {
        List<StudyTask> tasks = new ArrayList<>();
        
        String sql = "SELECT st.id, st.study_plan_id, st.topic_id, st.scheduled_date, st.scheduled_hours, st.completed_hours, st.status, st.is_revision, st.is_mock_test, st.task_mode, " +
                     "t.name AS topic_name, s.name AS subject_name " +
                     "FROM study_tasks st " +
                     "JOIN topics t ON st.topic_id = t.id " +
                     "JOIN subjects s ON t.subject_id = s.id " +
                     "WHERE st.study_plan_id = ? " +
                     "ORDER BY st.scheduled_date ASC, st.is_mock_test ASC, st.is_revision ASC, t.id ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, planId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    StudyTask task = new StudyTask();
                    task.setId(rs.getInt("id"));
                    task.setStudyPlanId(rs.getInt("study_plan_id"));
                    task.setTopicId(rs.getInt("topic_id"));
                    task.setScheduledDate(rs.getDate("scheduled_date").toLocalDate());
                    task.setScheduledHours(rs.getDouble("scheduled_hours"));
                    task.setCompletedHours(rs.getDouble("completed_hours"));
                    task.setStatus(rs.getString("status"));
                    task.setRevision(rs.getBoolean("is_revision"));
                    task.setMockTest(rs.getBoolean("is_mock_test"));
                    task.setTaskMode(rs.getString("task_mode"));
                    
                    // Map joined descriptors
                    task.setTopicName(rs.getString("topic_name"));
                    task.setSubjectName(rs.getString("subject_name"));
                    
                    tasks.add(task);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error fetching tasks for plan: " + e.getMessage());
            e.printStackTrace();
        }

        if (!tasks.isEmpty()) {
            try {
                StudyPlan plan = new StudyPlanDAO().getStudyPlanById(planId);
                if (plan != null) {
                    int daysRemaining = (int) java.time.temporal.ChronoUnit.DAYS.between(plan.getStartDate(), plan.getEndDate());
                    if (daysRemaining <= 0) daysRemaining = 1;
                    List<Topic> selectedTopics = new TopicDAO().getSelectedTopicsForUser(plan.getUserId(), plan.getExamId());
                    
                    Map<Integer, Double> topicLearnHours = new HashMap<>();
                    Map<Integer, Double> topicPracticeHours = new HashMap<>();
                    Map<Integer, Double> topicRevisionHours = new HashMap<>();
                    
                    for (StudyTask task : tasks) {
                        int tId = task.getTopicId();
                        double hrs = task.getScheduledHours();
                        if ("LEARN".equalsIgnoreCase(task.getTaskMode())) {
                            topicLearnHours.put(tId, topicLearnHours.getOrDefault(tId, 0.0) + hrs);
                        } else if ("PRACTICE".equalsIgnoreCase(task.getTaskMode())) {
                            topicPracticeHours.put(tId, topicPracticeHours.getOrDefault(tId, 0.0) + hrs);
                        } else if ("REVISION".equalsIgnoreCase(task.getTaskMode())) {
                            topicRevisionHours.put(tId, topicRevisionHours.getOrDefault(tId, 0.0) + hrs);
                        }
                    }

                    Map<Integer, Topic> topicMap = new HashMap<>();
                    for (Topic t : selectedTopics) {
                        topicMap.put(t.getId(), t);
                    }

                    com.examora.service.TopicPriorityService priorityService = new com.examora.service.TopicPriorityService();
                    for (StudyTask task : tasks) {
                        Topic t = topicMap.get(task.getTopicId());
                        if (t != null) {
                            double lHrs = topicLearnHours.getOrDefault(t.getId(), 0.0);
                            double pHrs = topicPracticeHours.getOrDefault(t.getId(), 0.0);
                            double rHrs = topicRevisionHours.getOrDefault(t.getId(), 0.0);
                            String exp = priorityService.getAllocationExplanation(t, plan.getUserId(), daysRemaining, lHrs, pHrs, rHrs);
                            task.setAllocationExplanation(exp);
                        } else {
                            task.setAllocationExplanation("Topic information not available.");
                        }
                    }
                }
            } catch (Exception e) {
                System.err.println("Error populating transient task explanations: " + e.getMessage());
                e.printStackTrace();
            }
        }
        return tasks;
    }

    /**
     * Retrieves all study tasks scheduled on a specific day for an active plan.
     * @param planId the StudyPlan ID
     * @param date target date
     * @return List of StudyTasks scheduled on this day
     */
    public List<StudyTask> getTasksForDate(int planId, LocalDate date) {
        List<StudyTask> tasks = new ArrayList<>();
        String sql = "SELECT st.id, st.study_plan_id, st.topic_id, st.scheduled_date, st.scheduled_hours, st.completed_hours, st.status, st.is_revision, st.is_mock_test, st.task_mode, " +
                     "t.name AS topic_name, s.name AS subject_name " +
                     "FROM study_tasks st " +
                     "JOIN topics t ON st.topic_id = t.id " +
                     "JOIN subjects s ON t.subject_id = s.id " +
                     "WHERE st.study_plan_id = ? AND st.scheduled_date = ? " +
                     "ORDER BY st.is_mock_test ASC, st.is_revision ASC, t.id ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, planId);
            stmt.setDate(2, Date.valueOf(date));

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    StudyTask task = new StudyTask();
                    task.setId(rs.getInt("id"));
                    task.setStudyPlanId(rs.getInt("study_plan_id"));
                    task.setTopicId(rs.getInt("topic_id"));
                    task.setScheduledDate(rs.getDate("scheduled_date").toLocalDate());
                    task.setScheduledHours(rs.getDouble("scheduled_hours"));
                    task.setCompletedHours(rs.getDouble("completed_hours"));
                    task.setStatus(rs.getString("status"));
                    task.setRevision(rs.getBoolean("is_revision"));
                    task.setMockTest(rs.getBoolean("is_mock_test"));
                    task.setTaskMode(rs.getString("task_mode"));
                    task.setTopicName(rs.getString("topic_name"));
                    task.setSubjectName(rs.getString("subject_name"));
                    tasks.add(task);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error fetching tasks for date: " + e.getMessage());
            e.printStackTrace();
        }
        return tasks;
    }

    /**
     * Updates the status and logs target completed hours dynamically in the database.
     * @param taskId ID of the task
     * @param status status label (PENDING, COMPLETED)
     * @return true if update succeeds
     */
    public boolean updateTaskStatus(int taskId, String status) {
        String sql = "UPDATE study_tasks SET status = ?, " +
                     "completed_hours = CASE WHEN ? = 'COMPLETED' THEN scheduled_hours ELSE 0.00 END, " +
                     "completed_at = CASE WHEN ? = 'COMPLETED' THEN CURRENT_TIMESTAMP ELSE NULL END " +
                     "WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, status);
            stmt.setString(2, status);
            stmt.setString(3, status);
            stmt.setInt(4, taskId);

            int affected = stmt.executeUpdate();
            return affected > 0;
        } catch (SQLException e) {
            System.err.println("Error updating task status: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Calculates user consistency streaks (current and longest streak).
     * 
     * @param userId the user ID
     * @return Map containing currentStreak and longestStreak
     */
    public Map<String, Integer> calculateStreaks(int userId) {
        Map<String, Integer> streaks = new HashMap<>();
        streaks.put("currentStreak", 0);
        streaks.put("longestStreak", 0);

        String sql = "SELECT DISTINCT DATE(completed_at) AS comp_date " +
                     "FROM study_tasks t " +
                     "JOIN study_plans p ON t.study_plan_id = p.id " +
                     "WHERE p.user_id = ? AND t.status = 'COMPLETED' AND t.completed_at IS NOT NULL " +
                     "ORDER BY comp_date DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            List<LocalDate> dates = new ArrayList<>();
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    java.sql.Date d = rs.getDate("comp_date");
                    if (d != null) {
                        dates.add(d.toLocalDate());
                    }
                }
            }

            if (dates.isEmpty()) {
                return streaks;
            }

            LocalDate today = LocalDate.now();
            LocalDate yesterday = today.minusDays(1);

            // Calculate current streak
            int currentStreak = 0;
            LocalDate firstDate = dates.get(0);
            if (firstDate.equals(today) || firstDate.equals(yesterday)) {
                currentStreak = 1;
                LocalDate expected = firstDate.minusDays(1);
                for (int i = 1; i < dates.size(); i++) {
                    LocalDate current = dates.get(i);
                    if (current.equals(expected)) {
                        currentStreak++;
                        expected = current.minusDays(1);
                    } else {
                        break;
                    }
                }
            }

            // Calculate longest streak
            int longestStreak = 0;
            int tempStreak = 0;
            LocalDate expected = null;
            for (LocalDate current : dates) {
                if (expected == null) {
                    tempStreak = 1;
                    expected = current.minusDays(1);
                } else if (current.equals(expected)) {
                    tempStreak++;
                    expected = current.minusDays(1);
                } else {
                    if (tempStreak > longestStreak) {
                        longestStreak = tempStreak;
                    }
                    tempStreak = 1;
                    expected = current.minusDays(1);
                }
            }
            if (tempStreak > longestStreak) {
                longestStreak = tempStreak;
            }

            streaks.put("currentStreak", currentStreak);
            streaks.put("longestStreak", longestStreak);

        } catch (SQLException e) {
            System.err.println("Error calculating streaks: " + e.getMessage());
            e.printStackTrace();
        }
        return streaks;
    }

    /**
     * Resolves the 7-day study performance metrics (scheduled vs completed hours) for the given plan.
     * Guaranteed to return exactly 7 rows (last 7 days chronologically).
     * 
     * @param planId the study plan ID
     * @return List of day performance records
     */
    public List<Map<String, Object>> getWeeklyPerformanceMetrics(int planId) {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT d.scheduled_date, " +
                     "COALESCE(SUM(t.scheduled_hours), 0.0) AS scheduled_hours, " +
                     "COALESCE(SUM(t.completed_hours), 0.0) AS completed_hours " +
                     "FROM ( " +
                     "    SELECT CURDATE() AS scheduled_date " +
                     "    UNION SELECT DATE_SUB(CURDATE(), INTERVAL 1 DAY) " +
                     "    UNION SELECT DATE_SUB(CURDATE(), INTERVAL 2 DAY) " +
                     "    UNION SELECT DATE_SUB(CURDATE(), INTERVAL 3 DAY) " +
                     "    UNION SELECT DATE_SUB(CURDATE(), INTERVAL 4 DAY) " +
                     "    UNION SELECT DATE_SUB(CURDATE(), INTERVAL 5 DAY) " +
                     "    UNION SELECT DATE_SUB(CURDATE(), INTERVAL 6 DAY) " +
                     ") d " +
                     "LEFT JOIN study_tasks t ON DATE(t.scheduled_date) = d.scheduled_date AND t.study_plan_id = ? " +
                     "GROUP BY d.scheduled_date " +
                     "ORDER BY d.scheduled_date ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, planId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> dayMap = new HashMap<>();
                    dayMap.put("date", rs.getDate("scheduled_date").toLocalDate());
                    dayMap.put("scheduledHours", rs.getDouble("scheduled_hours"));
                    dayMap.put("completedHours", rs.getDouble("completed_hours"));
                    list.add(dayMap);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error fetching weekly performance metrics: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Resolves the highest-priority pending study tasks to display as weak areas requiring focus.
     * Groups by topic to prevent listing the same topic multiple times.
     * 
     * @param planId active StudyPlan ID
     * @param examId active Exam ID to pull weights
     * @param limit maximum records to pull
     * @return List of StudyTasks representing priority weak modules
     */
    public List<StudyTask> getHighestPriorityPendingTopics(int planId, int examId, int limit) {
        List<StudyTask> tasks = new ArrayList<>();
        String sql = "SELECT st.id, st.study_plan_id, st.topic_id, st.scheduled_date, st.scheduled_hours, st.completed_hours, st.status, st.is_revision, st.is_mock_test, st.task_mode, " +
                     "t.name AS topic_name, s.name AS subject_name, tr.priority AS priority " +
                     "FROM study_tasks st " +
                     "JOIN topics t ON st.topic_id = t.id " +
                     "JOIN subjects s ON t.subject_id = s.id " +
                     "LEFT JOIN topic_trends tr ON t.id = tr.topic_id AND tr.exam_id = ? " +
                     "WHERE st.id IN ( " +
                     "    SELECT MIN(sub_st.id) " +
                     "    FROM study_tasks sub_st " +
                     "    WHERE sub_st.study_plan_id = ? AND sub_st.status = 'PENDING' AND sub_st.is_mock_test = FALSE AND sub_st.is_revision = FALSE " +
                     "    GROUP BY sub_st.topic_id " +
                     ") " +
                     "ORDER BY tr.priority = 'VERY HIGH' DESC, tr.priority = 'HIGH' DESC, tr.priority = 'MEDIUM' DESC, t.id ASC " +
                     "LIMIT ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, examId);
            stmt.setInt(2, planId);
            stmt.setInt(3, limit);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    StudyTask task = new StudyTask();
                    task.setId(rs.getInt("id"));
                    task.setStudyPlanId(rs.getInt("study_plan_id"));
                    task.setTopicId(rs.getInt("topic_id"));
                    task.setScheduledDate(rs.getDate("scheduled_date").toLocalDate());
                    task.setScheduledHours(rs.getDouble("scheduled_hours"));
                    task.setCompletedHours(rs.getDouble("completed_hours"));
                    task.setStatus(rs.getString("status"));
                    task.setRevision(rs.getBoolean("is_revision"));
                    task.setMockTest(rs.getBoolean("is_mock_test"));
                    task.setTaskMode(rs.getString("task_mode"));
                    task.setTopicName(rs.getString("topic_name"));
                    task.setSubjectName(rs.getString("subject_name"));
                    task.setPriority(rs.getString("priority"));
                    tasks.add(task);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error fetching priority pending topics: " + e.getMessage());
            e.printStackTrace();
        }
        return tasks;
    }

    /**
     * Calculates task completion statistics for progress bar mappings.
     * @param planId active StudyPlan ID
     * @return Map containing statistics (totalHours, completedHours, totalTasks, completedTasks)
     */
    public Map<String, Object> getTaskCompletionMetrics(int planId) {
        Map<String, Object> metrics = new HashMap<>();
        String sql = "SELECT COUNT(id) AS total_tasks, " +
                     "SUM(CASE WHEN status = 'COMPLETED' THEN 1 ELSE 0 END) AS completed_tasks, " +
                     "SUM(scheduled_hours) AS total_hours, " +
                     "SUM(completed_hours) AS completed_hours " +
                     "FROM study_tasks WHERE study_plan_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, planId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    metrics.put("totalTasks", rs.getInt("total_tasks"));
                    metrics.put("completedTasks", rs.getInt("completed_tasks"));
                    metrics.put("totalHours", rs.getDouble("total_hours"));
                    metrics.put("completedHours", rs.getDouble("completed_hours"));
                    return metrics;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error fetching task completion metrics: " + e.getMessage());
            e.printStackTrace();
        }

        // Fallback default values
        metrics.put("totalTasks", 0);
        metrics.put("completedTasks", 0);
        metrics.put("totalHours", 0.0);
        metrics.put("completedHours", 0.0);
        return metrics;
    }

    public double getWeightedSyllabusCompletionPercentage(int planId) {
        String sql = "SELECT " +
                     "  COALESCE(SUM(CASE WHEN st.is_completed = 1 THEN t.estimated_hours ELSE 0 END), 0.0) AS completed_hours, " +
                     "  COALESCE(SUM(t.estimated_hours), 0.0) AS total_hours " +
                     "FROM ( " +
                     "  SELECT topic_id, " +
                     "    CASE WHEN SUM(CASE WHEN status = 'COMPLETED' AND task_mode = 'LEARN' THEN 1 ELSE 0 END) = SUM(CASE WHEN task_mode = 'LEARN' THEN 1 ELSE 0 END) AND SUM(CASE WHEN task_mode = 'LEARN' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS is_completed " +
                     "  FROM study_tasks " +
                     "  WHERE study_plan_id = ? " +
                     "  GROUP BY topic_id " +
                     ") st " +
                     "JOIN topics t ON st.topic_id = t.id";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, planId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    double total = rs.getDouble("total_hours");
                    if (total == 0.0) return 0.0;
                    return (rs.getDouble("completed_hours") / total) * 100.0;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting weighted syllabus progress: " + e.getMessage());
            e.printStackTrace();
        }
        return 0.0;
    }

    public double getPYQYearAttemptsRatio(int userId, int examId) {
        String sql = "SELECT " +
                     "  (SELECT COUNT(*) FROM (" +
                     "     SELECT pq.year " +
                     "     FROM pyq_questions pq " +
                     "     LEFT JOIN pyq_attempts pa ON pq.id = pa.question_id AND pa.user_id = ? " +
                     "     WHERE pq.exam_id = ? " +
                     "     GROUP BY pq.year " +
                     "     HAVING COUNT(pq.id) = COUNT(DISTINCT pa.question_id)" +
                     "  ) AS completed) AS completed_years, " +
                     "  (SELECT COUNT(DISTINCT year) FROM pyq_year_coverage WHERE exam_id = ?) AS total_years";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, examId);
            stmt.setInt(3, examId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    int total = rs.getInt("total_years");
                    if (total == 0) return 0.0;
                    return ((double) rs.getInt("completed_years") / total) * 100.0;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting PYQ year attempts ratio: " + e.getMessage());
            e.printStackTrace();
        }
        return 0.0;
    }

    public int getRevisionDueCount(int planId) {
        String sql = "SELECT COUNT(*) FROM study_tasks WHERE study_plan_id = ? AND task_mode = 'REVISION' AND status = 'PENDING' AND scheduled_date < CURDATE()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, planId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting revision due count: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }
}
