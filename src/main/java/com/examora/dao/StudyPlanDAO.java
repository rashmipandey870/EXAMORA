package com.examora.dao;

import com.examora.model.StudyPlan;
import com.examora.util.DBConnection;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/**
 * StudyPlanDAO handles SQL operations for the 'study_plans' table.
 * 
 * WHAT: Data Access Object for Study Plans.
 * WHY: Manages planner metadata, creation blocks, and user status deactivations.
 * HOW: standard JDBC Connection and PreparedStatement operations.
 * WHERE: Placed in the com.examora.dao package.
 */
public class StudyPlanDAO {

    /**
     * Saves a new StudyPlan configuration and sets its generated database ID.
     * @param plan the StudyPlan object
     * @return true if save operation succeeds
     */
    public boolean saveStudyPlan(StudyPlan plan) {
        String sql = "INSERT INTO study_plans (user_id, exam_id, start_date, end_date, daily_study_hours, preferred_days, status, " +
                     "target_syllabus_completion_date, target_pyq_completion_date, revision_buffer_days, learn_pct, practice_pct, revision_pct) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, plan.getUserId());
            stmt.setInt(2, plan.getExamId());
            stmt.setDate(3, Date.valueOf(plan.getStartDate()));
            stmt.setDate(4, Date.valueOf(plan.getEndDate()));
            stmt.setDouble(5, plan.getDailyStudyHours());
            stmt.setString(6, plan.getPreferredDays());
            stmt.setString(7, plan.getStatus());
            
            stmt.setDate(8, plan.getTargetSyllabusCompletionDate() != null ? Date.valueOf(plan.getTargetSyllabusCompletionDate()) : null);
            stmt.setDate(9, plan.getTargetPyqCompletionDate() != null ? Date.valueOf(plan.getTargetPyqCompletionDate()) : null);
            stmt.setInt(10, plan.getRevisionBufferDays());
            stmt.setInt(11, plan.getLearnPct());
            stmt.setInt(12, plan.getPracticePct());
            stmt.setInt(13, plan.getRevisionPct());

            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                return false;
            }

            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    plan.setId(generatedKeys.getInt(1));
                    return true;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error saving study plan: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Deactivates all active study plans for a student by setting status to 'ARCHIVED'.
     * @param userId the student's user ID
     * @return true if update succeeds
     */
    public boolean deactivateActivePlans(int userId) {
        String sql = "UPDATE study_plans SET status = 'ARCHIVED' WHERE user_id = ? AND status = 'ACTIVE'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.err.println("Error archiving active study plans: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Retrieves the active study plan for a user.
     * @param userId the student's user ID
     * @return StudyPlan object, or null if none is currently active
     */
    public StudyPlan getActiveStudyPlan(int userId) {
        String sql = "SELECT id, user_id, exam_id, start_date, end_date, daily_study_hours, preferred_days, status, created_at, " +
                     "target_syllabus_completion_date, target_pyq_completion_date, revision_buffer_days, learn_pct, practice_pct, revision_pct " +
                     "FROM study_plans WHERE user_id = ? AND status = 'ACTIVE' LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    StudyPlan plan = new StudyPlan();
                    plan.setId(rs.getInt("id"));
                    plan.setUserId(rs.getInt("user_id"));
                    plan.setExamId(rs.getInt("exam_id"));
                    plan.setStartDate(rs.getDate("start_date").toLocalDate());
                    plan.setEndDate(rs.getDate("end_date").toLocalDate());
                    plan.setDailyStudyHours(rs.getDouble("daily_study_hours"));
                    plan.setPreferredDays(rs.getString("preferred_days"));
                    plan.setStatus(rs.getString("status"));
                    plan.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
                    
                    Date syllabusDate = rs.getDate("target_syllabus_completion_date");
                    plan.setTargetSyllabusCompletionDate(syllabusDate != null ? syllabusDate.toLocalDate() : null);
                    
                    Date pyqDate = rs.getDate("target_pyq_completion_date");
                    plan.setTargetPyqCompletionDate(pyqDate != null ? pyqDate.toLocalDate() : null);
                    
                    plan.setRevisionBufferDays(rs.getInt("revision_buffer_days"));
                    plan.setLearnPct(rs.getInt("learn_pct"));
                    plan.setPracticePct(rs.getInt("practice_pct"));
                    plan.setRevisionPct(rs.getInt("revision_pct"));
                    return plan;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error fetching active study plan: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    public StudyPlan getStudyPlanById(int planId) {
        String sql = "SELECT id, user_id, exam_id, start_date, end_date, daily_study_hours, preferred_days, status, created_at, " +
                     "target_syllabus_completion_date, target_pyq_completion_date, revision_buffer_days, learn_pct, practice_pct, revision_pct " +
                     "FROM study_plans WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, planId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    StudyPlan plan = new StudyPlan();
                    plan.setId(rs.getInt("id"));
                    plan.setUserId(rs.getInt("user_id"));
                    plan.setExamId(rs.getInt("exam_id"));
                    plan.setStartDate(rs.getDate("start_date").toLocalDate());
                    plan.setEndDate(rs.getDate("end_date").toLocalDate());
                    plan.setDailyStudyHours(rs.getDouble("daily_study_hours"));
                    plan.setPreferredDays(rs.getString("preferred_days"));
                    plan.setStatus(rs.getString("status"));
                    plan.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
                    
                    Date syllabusDate = rs.getDate("target_syllabus_completion_date");
                    plan.setTargetSyllabusCompletionDate(syllabusDate != null ? syllabusDate.toLocalDate() : null);
                    
                    Date pyqDate = rs.getDate("target_pyq_completion_date");
                    plan.setTargetPyqCompletionDate(pyqDate != null ? pyqDate.toLocalDate() : null);
                    
                    plan.setRevisionBufferDays(rs.getInt("revision_buffer_days"));
                    plan.setLearnPct(rs.getInt("learn_pct"));
                    plan.setPracticePct(rs.getInt("practice_pct"));
                    plan.setRevisionPct(rs.getInt("revision_pct"));
                    return plan;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error fetching study plan by ID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
}
