package com.examora.dao;

import com.examora.model.PYQAttempt;
import com.examora.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * PYQAttemptDAO handles database operations for tracking practice question attempts.
 */
public class PYQAttemptDAO {

    public boolean saveAttempt(PYQAttempt attempt) {
        String sql = "INSERT INTO pyq_attempts (user_id, question_id, selected_option, is_correct) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, attempt.getUserId());
            ps.setInt(2, attempt.getQuestionId());
            ps.setString(3, attempt.getSelectedOption());
            ps.setBoolean(4, attempt.isCorrect());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error saving pyq attempt: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public List<PYQAttempt> getAttemptsForUser(int userId) {
        List<PYQAttempt> list = new ArrayList<>();
        String sql = "SELECT id, user_id, question_id, selected_option, is_correct, attempted_at FROM pyq_attempts WHERE user_id = ? ORDER BY attempted_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PYQAttempt attempt = new PYQAttempt();
                    attempt.setId(rs.getInt("id"));
                    attempt.setUserId(rs.getInt("user_id"));
                    attempt.setQuestionId(rs.getInt("question_id"));
                    attempt.setSelectedOption(rs.getString("selected_option"));
                    attempt.setCorrect(rs.getBoolean("is_correct"));
                    attempt.setAttemptedAt(rs.getTimestamp("attempted_at").toLocalDateTime());
                    list.add(attempt);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error loading pyq attempts: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    public double getTopicAccuracy(int userId, int topicId) {
        String sql = "SELECT SUM(CASE WHEN a.is_correct = 1 THEN 1 ELSE 0 END) AS correct_count, COUNT(*) AS total_count " +
                     "FROM pyq_attempts a " +
                     "JOIN pyq_questions q ON a.question_id = q.id " +
                     "WHERE a.user_id = ? AND q.topic_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, topicId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int total = rs.getInt("total_count");
                    if (total == 0) return 1.0; // Default accuracy is 100% if no attempts
                    int correct = rs.getInt("correct_count");
                    return (double) correct / total;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting topic accuracy: " + e.getMessage());
            e.printStackTrace();
        }
        return 1.0;
    }

    public List<java.util.Map<String, Object>> getWeakestTopicsForUser(int userId, int limit) {
        List<java.util.Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT q.topic_id, t.name AS topic_name, s.name AS subject_name, " +
                     "SUM(CASE WHEN a.is_correct = 1 THEN 1 ELSE 0 END) AS correct_count, " +
                     "COUNT(*) AS total_count, " +
                     "(SUM(CASE WHEN a.is_correct = 1 THEN 1 ELSE 0 END) / COUNT(*)) AS accuracy " +
                     "FROM pyq_attempts a " +
                     "JOIN pyq_questions q ON a.question_id = q.id " +
                     "JOIN topics t ON q.topic_id = t.id " +
                     "JOIN subjects s ON t.subject_id = s.id " +
                     "WHERE a.user_id = ? " +
                     "GROUP BY q.topic_id, t.name, s.name " +
                     "ORDER BY accuracy ASC, total_count DESC " +
                     "LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> map = new java.util.HashMap<>();
                    map.put("topicId", rs.getInt("topic_id"));
                    map.put("topicName", rs.getString("topic_name"));
                    map.put("subjectName", rs.getString("subject_name"));
                    map.put("correctCount", rs.getInt("correct_count"));
                    map.put("totalCount", rs.getInt("total_count"));
                    map.put("accuracy", rs.getDouble("accuracy"));
                    list.add(map);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error loading weakest topics: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }
}
