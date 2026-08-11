package com.examora.dao;

import com.examora.model.DeadlineEvent;
import com.examora.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class DeadlineEventDAO {

    public List<DeadlineEvent> getDeadlineEventsForExam(int examId) {
        List<DeadlineEvent> events = new ArrayList<>();
        String sql = "SELECT id, exam_id, event_type, event_date, is_estimated, source, last_checked_at FROM deadline_events WHERE exam_id = ? ORDER BY event_date ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, examId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    DeadlineEvent event = new DeadlineEvent();
                    event.setId(rs.getInt("id"));
                    event.setExamId(rs.getInt("exam_id"));
                    event.setEventType(rs.getString("event_type"));
                    event.setEventDate(rs.getDate("event_date").toLocalDate());
                    event.setEstimated(rs.getBoolean("is_estimated"));
                    event.setSource(rs.getString("source"));
                    
                    java.sql.Timestamp ts = rs.getTimestamp("last_checked_at");
                    if (ts != null) {
                        event.setLastCheckedAt(ts.toLocalDateTime());
                    }
                    events.add(event);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error fetching deadline events for exam: " + e.getMessage());
            e.printStackTrace();
        }
        return events;
    }
}
