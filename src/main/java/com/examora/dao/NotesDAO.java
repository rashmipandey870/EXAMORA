package com.examora.dao;

import com.examora.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class NotesDAO {

    public String getCachedNotes(int topicId) {
        String sql = "SELECT notes_content FROM topic_notes WHERE topic_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, topicId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("notes_content");
                }
            }
        } catch (SQLException e) {
            System.err.println("Error fetching cached notes: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    public boolean cacheNotes(int topicId, String content) {
        String sql = "INSERT INTO topic_notes (topic_id, notes_content) VALUES (?, ?) ON DUPLICATE KEY UPDATE notes_content = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, topicId);
            stmt.setString(2, content);
            stmt.setString(3, content);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error caching notes: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public int getAIRequestsCountInLast24Hours(int userId) {
        String sql = "SELECT COUNT(*) FROM ai_requests WHERE user_id = ? AND request_type = 'NOTES' AND created_at >= NOW() - INTERVAL 1 DAY";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting AI request counts: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }

    public boolean logAIRequest(int userId, String prompt, String response) {
        String sql = "INSERT INTO ai_requests (user_id, request_type, prompt, response) VALUES (?, 'NOTES', ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setString(2, prompt);
            stmt.setString(3, response);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error logging AI request: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
}
