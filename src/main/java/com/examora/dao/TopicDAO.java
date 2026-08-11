package com.examora.dao;

import com.examora.model.Topic;
import com.examora.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

/**
 * TopicDAO performs SQL operations on the 'topics', 'topic_trends', and 'user_topics' tables.
 * 
 * WHAT: Data Access Object for Topic records.
 * WHY: Fetches invariant topic details, maps trend provenance, and handles study scope selections.
 * HOW: Executes parameterized JDBC statements with transaction rollbacks on failures.
 * WHERE: Placed in the com.examora.dao package.
 */
public class TopicDAO {

    /**
     * Retrieves all topics inside a subject, including respective exam trend details.
     * @param subjectId ID of the parent subject
     * @param examId ID of the exam for trend mapping
     * @return List of Topic objects containing filled trend details
     */
    public List<Topic> getTopicsBySubjectId(int subjectId, int examId) {
        List<Topic> topics = new ArrayList<>();
        
        String sql = "SELECT t.id, t.subject_id, t.name, t.description, t.difficulty, t.estimated_hours, t.unit_id, " +
                     "tr.priority, tr.historical_frequency, tr.recent_frequency, tr.years_appeared, tr.number_of_questions, tr.verification_status, " +
                     "tr.source_url, tr.source_title, tr.retrieved_at, tr.weightage " +
                     "FROM topics t " +
                     "LEFT JOIN topic_trends tr ON t.id = tr.topic_id AND tr.exam_id = ? " +
                     "WHERE t.subject_id = ? " +
                     "ORDER BY t.id ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, examId);
            stmt.setInt(2, subjectId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Topic topic = mapRowToTopic(rs);
                    topics.add(topic);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error fetching topics for subject: " + e.getMessage());
            e.printStackTrace();
        }
        return topics;
    }

    public List<Topic> getTopicsByUnitId(int unitId, int examId) {
        List<Topic> topics = new ArrayList<>();
        String sql = "SELECT t.id, t.subject_id, t.name, t.description, t.difficulty, t.estimated_hours, t.unit_id, " +
                     "tr.priority, tr.historical_frequency, tr.recent_frequency, tr.years_appeared, tr.number_of_questions, tr.verification_status, " +
                     "tr.source_url, tr.source_title, tr.retrieved_at, tr.weightage " +
                     "FROM topics t " +
                     "LEFT JOIN topic_trends tr ON t.id = tr.topic_id AND tr.exam_id = ? " +
                     "WHERE t.unit_id = ? " +
                     "ORDER BY t.id ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, examId);
            stmt.setInt(2, unitId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Topic topic = mapRowToTopic(rs);
                    topics.add(topic);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error fetching topics by unit ID: " + e.getMessage());
            e.printStackTrace();
        }
        return topics;
    }

    public List<com.examora.model.SubTopic> getSubTopicsByTopicId(int topicId) {
        List<com.examora.model.SubTopic> subTopics = new ArrayList<>();
        String sql = "SELECT id, topic_id, name, description FROM sub_topics WHERE topic_id = ? ORDER BY id ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, topicId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    com.examora.model.SubTopic sub = new com.examora.model.SubTopic();
                    sub.setId(rs.getInt("id"));
                    sub.setTopicId(rs.getInt("topic_id"));
                    sub.setName(rs.getString("name"));
                    sub.setDescription(rs.getString("description"));
                    subTopics.add(sub);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return subTopics;
    }

    public List<String> getPrerequisiteNamesForTopic(int topicId) {
        List<String> prerequisites = new ArrayList<>();
        String sql = "SELECT p.name FROM topic_prerequisites tp JOIN topics p ON tp.prerequisite_topic_id = p.id WHERE tp.topic_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, topicId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    prerequisites.add(rs.getString("name"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return prerequisites;
    }

    private Topic mapRowToTopic(ResultSet rs) throws SQLException {
        Topic topic = new Topic();
        topic.setId(rs.getInt("id"));
        topic.setSubjectId(rs.getInt("subject_id"));
        topic.setName(rs.getString("name"));
        topic.setDescription(rs.getString("description"));
        topic.setDifficulty(rs.getString("difficulty"));
        topic.setEstimatedHours(rs.getInt("estimated_hours"));
        topic.setUnitId(rs.getInt("unit_id"));

        topic.setPriority(rs.getString("priority") != null ? rs.getString("priority") : "MEDIUM");
        topic.setHistoricalFrequency(rs.getString("historical_frequency") != null ? rs.getString("historical_frequency") : "MEDIUM");
        topic.setRecentFrequency(rs.getString("recent_frequency") != null ? rs.getString("recent_frequency") : "MEDIUM");
        topic.setYearsAppeared(rs.getString("years_appeared") != null ? rs.getString("years_appeared") : "N/A");
        topic.setNumberOfQuestions(rs.getInt("number_of_questions"));
        topic.setVerificationStatus(rs.getString("verification_status") != null ? rs.getString("verification_status") : "ESTIMATED");

        topic.setTrendSourceUrl(rs.getString("source_url") != null ? rs.getString("source_url") : "N/A");
        topic.setTrendSourceTitle(rs.getString("source_title") != null ? rs.getString("source_title") : "AI Generated Trend Estimate");
        
        Timestamp retrieved = rs.getTimestamp("retrieved_at");
        if (retrieved != null) {
            topic.setTrendRetrievedAt(retrieved.toLocalDateTime());
        }

        double w = rs.getDouble("weightage");
        if (rs.wasNull()) {
            topic.setWeightage(null);
        } else {
            topic.setWeightage(w);
        }
        return topic;
    }

    /**
     * Saves user topic selection checkboxes to the user_topics table inside a SQL Transaction.
     * @param userId the user ID
     * @param topicIds list of selected topic IDs
     * @return true if save operation completes successfully
     */
    public boolean saveUserTopicSelections(int userId, List<Integer> topicIds) {
        String deleteSql = "DELETE FROM user_topics WHERE user_id = ?";
        String insertSql = "INSERT INTO user_topics (user_id, topic_id) VALUES (?, ?)";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Begin Transaction

            // 1. Delete existing selections for this user
            try (PreparedStatement stmt = conn.prepareStatement(deleteSql)) {
                stmt.setInt(1, userId);
                stmt.executeUpdate();
            }

            // 2. Insert new selections
            if (topicIds != null && !topicIds.isEmpty()) {
                try (PreparedStatement stmt = conn.prepareStatement(insertSql)) {
                    for (int topicId : topicIds) {
                        stmt.setInt(1, userId);
                        stmt.setInt(2, topicId);
                        stmt.addBatch();
                    }
                    stmt.executeBatch();
                }
            }

            conn.commit(); // Commit all steps
            return true;

        } catch (SQLException e) {
            System.err.println("Error saving user topic selections: " + e.getMessage());
            if (conn != null) {
                try {
                    conn.rollback(); // Rollback on failure
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
     * Retrieves all selected topics for a user, including their trend metadata.
     * @param userId the user ID
     * @param examId active exam ID to pull trends
     * @return List of Topic objects currently selected by the student
     */
    public List<Topic> getSelectedTopicsForUser(int userId, int examId) {
        List<Topic> topics = new ArrayList<>();
        String sql = "SELECT t.id, t.subject_id, t.name, t.description, t.difficulty, t.estimated_hours, " +
                     "tr.priority, tr.historical_frequency, tr.recent_frequency, tr.years_appeared, tr.number_of_questions, tr.verification_status, " +
                     "tr.source_url, tr.source_title, tr.retrieved_at " +
                     "FROM topics t " +
                     "JOIN user_topics ut ON t.id = ut.topic_id " +
                     "LEFT JOIN topic_trends tr ON t.id = tr.topic_id AND tr.exam_id = ? " +
                     "WHERE ut.user_id = ? " +
                     "ORDER BY t.id ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, examId);
            stmt.setInt(2, userId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Topic topic = new Topic();
                    topic.setId(rs.getInt("id"));
                    topic.setSubjectId(rs.getInt("subject_id"));
                    topic.setName(rs.getString("name"));
                    topic.setDescription(rs.getString("description"));
                    topic.setDifficulty(rs.getString("difficulty"));
                    topic.setEstimatedHours(rs.getInt("estimated_hours"));

                    // Map trend elements
                    topic.setPriority(rs.getString("priority") != null ? rs.getString("priority") : "MEDIUM");
                    topic.setHistoricalFrequency(rs.getString("historical_frequency") != null ? rs.getString("historical_frequency") : "MEDIUM");
                    topic.setRecentFrequency(rs.getString("recent_frequency") != null ? rs.getString("recent_frequency") : "MEDIUM");
                    topic.setYearsAppeared(rs.getString("years_appeared") != null ? rs.getString("years_appeared") : "N/A");
                    topic.setNumberOfQuestions(rs.getInt("number_of_questions"));
                    topic.setVerificationStatus(rs.getString("verification_status") != null ? rs.getString("verification_status") : "ESTIMATED");

                    // Map provenance elements
                    topic.setTrendSourceUrl(rs.getString("source_url") != null ? rs.getString("source_url") : "N/A");
                    topic.setTrendSourceTitle(rs.getString("source_title") != null ? rs.getString("source_title") : "AI Generated Trend Estimate");
                    
                    Timestamp retrieved = rs.getTimestamp("retrieved_at");
                    if (retrieved != null) {
                        topic.setTrendRetrievedAt(retrieved.toLocalDateTime());
                    }

                    topics.add(topic);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error fetching selected topics: " + e.getMessage());
            e.printStackTrace();
        }
        return topics;
    }

    public int getTotalEstimatedHours(List<Integer> topicIds) {
        if (topicIds == null || topicIds.isEmpty()) {
            return 0;
        }
        
        StringBuilder sb = new StringBuilder("SELECT SUM(estimated_hours) FROM topics WHERE id IN (");
        for (int i = 0; i < topicIds.size(); i++) {
            sb.append("?");
            if (i < topicIds.size() - 1) {
                sb.append(",");
            }
        }
        sb.append(")");
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sb.toString())) {
            for (int i = 0; i < topicIds.size(); i++) {
                stmt.setInt(i + 1, topicIds.get(i));
            }
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error calculating total estimated hours: " + e.getMessage());
            e.printStackTrace();
        }
        return 0;
    }
}
