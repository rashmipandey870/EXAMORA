package com.examora.dao;

import com.examora.model.Exam;
import com.examora.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * ExamDAO manages SQL operations for the 'exams' and 'user_exams' tables.
 * 
 * WHAT: Data Access Object for Exam configurations.
 * WHY: Provides standard APIs to fetch exams, select targets via transactions, and fetch user focus targets.
 * HOW: standard JDBC Connection management and prepared statement transactions.
 * WHERE: Placed in the com.examora.dao package.
 */
public class ExamDAO {

    /**
     * Retrieves all standardized examinations available in the system.
     * @return List of Exams
     */
    public List<Exam> getAllExams() {
        List<Exam> exams = new ArrayList<>();
        String sql = "SELECT id, name, exam_year, exam_date, is_custom, conducting_body, eligibility_criteria, min_education_level, eligible_streams, goal_tags, exam_pattern_summary, typical_application_window, typical_exam_date_window, official_website_url, syllabus_availability_status, last_verified_at, is_rolling_exam, is_verified_dates FROM exams ORDER BY name ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                exams.add(mapRowToExam(rs));
            }
        } catch (SQLException e) {
            System.err.println("Error fetching all exams: " + e.getMessage());
            e.printStackTrace();
        }
        return exams;
    }

    /**
     * Sets an exam as the active target for a user.
     * Runs in a SQL Transaction to ensure only ONE exam is active for a user at any time.
     * 
     * @param userId ID of the student
     * @param examId ID of the exam
     * @return true if successful, false otherwise
     */
    public boolean selectExamForUser(int userId, int examId) {
        String deactivateSql = "UPDATE user_exams SET is_active = FALSE WHERE user_id = ?";
        String checkExistSql = "SELECT COUNT(*) FROM user_exams WHERE user_id = ? AND exam_id = ?";
        String updateActiveSql = "UPDATE user_exams SET is_active = TRUE WHERE user_id = ? AND exam_id = ?";
        String insertActiveSql = "INSERT INTO user_exams (user_id, exam_id, is_active) VALUES (?, ?, TRUE)";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Begin SQL Transaction

            // 1. Deactivate any existing active exams for this user
            try (PreparedStatement stmt = conn.prepareStatement(deactivateSql)) {
                stmt.setInt(1, userId);
                stmt.executeUpdate();
            }

            // 2. Check if the user already has this exam mapped
            boolean exists = false;
            try (PreparedStatement stmt = conn.prepareStatement(checkExistSql)) {
                stmt.setInt(1, userId);
                stmt.setInt(2, examId);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        exists = true;
                    }
                }
            }

            // 3. Update existing row to active, or insert a new mapping row
            if (exists) {
                try (PreparedStatement stmt = conn.prepareStatement(updateActiveSql)) {
                    stmt.setInt(1, userId);
                    stmt.setInt(2, examId);
                    stmt.executeUpdate();
                }
            } else {
                try (PreparedStatement stmt = conn.prepareStatement(insertActiveSql)) {
                    stmt.setInt(1, userId);
                    stmt.setInt(2, examId);
                    stmt.executeUpdate();
                }
            }

            conn.commit(); // Commit Transaction if all steps succeeded
            return true;

        } catch (SQLException e) {
            System.err.println("Error selecting exam for user inside transaction: " + e.getMessage());
            if (conn != null) {
                try {
                    conn.rollback(); // Rollback transaction on failure
                    System.out.println("Transaction rolled back successfully.");
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true); // Reset connection state
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        return false;
    }

    /**
     * Retrieves the active targeted exam for a user.
     * @param userId ID of the student
     * @return Exam target object, or null if none is selected or active
     */
    public Exam getActiveExamForUser(int userId) {
        String sql = "SELECT e.id, e.name, e.exam_year, e.exam_date, e.is_custom, e.conducting_body, e.eligibility_criteria, e.min_education_level, e.eligible_streams, e.goal_tags, e.exam_pattern_summary, e.typical_application_window, e.typical_exam_date_window, e.official_website_url, e.syllabus_availability_status, e.last_verified_at, e.is_rolling_exam, e.is_verified_dates " +
                     "FROM exams e " +
                     "JOIN user_exams ue ON e.id = ue.exam_id " +
                     "WHERE ue.user_id = ? AND ue.is_active = TRUE LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRowToExam(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error fetching active exam for user: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    private Exam mapRowToExam(ResultSet rs) throws SQLException {
        Exam exam = new Exam();
        exam.setId(rs.getInt("id"));
        exam.setName(rs.getString("name"));
        exam.setExamYear(rs.getInt("exam_year"));
        
        java.sql.Date d = rs.getDate("exam_date");
        if (d != null) {
            exam.setExamDate(d.toLocalDate());
        }
        
        exam.setCustom(rs.getBoolean("is_custom"));
        exam.setConductingBody(rs.getString("conducting_body"));
        exam.setEligibilityCriteria(rs.getString("eligibility_criteria"));
        exam.setMinEducationLevel(rs.getString("min_education_level"));
        exam.setEligibleStreams(rs.getString("eligible_streams"));
        exam.setGoalTags(rs.getString("goal_tags"));
        exam.setExamPatternSummary(rs.getString("exam_pattern_summary"));
        exam.setTypicalApplicationWindow(rs.getString("typical_application_window"));
        exam.setTypicalExamDateWindow(rs.getString("typical_exam_date_window"));
        exam.setOfficialWebsiteUrl(rs.getString("official_website_url"));
        exam.setSyllabusAvailabilityStatus(rs.getString("syllabus_availability_status"));
        
        java.sql.Timestamp ts = rs.getTimestamp("last_verified_at");
        if (ts != null) {
            exam.setLastVerifiedAt(ts.toLocalDateTime());
        }
        
        exam.setRollingExam(rs.getBoolean("is_rolling_exam"));
        exam.setVerifiedDates(rs.getBoolean("is_verified_dates"));
        return exam;
    }
}
