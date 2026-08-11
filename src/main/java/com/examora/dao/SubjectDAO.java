package com.examora.dao;

import com.examora.model.Subject;
import com.examora.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * SubjectDAO performs SQL operations on the 'subjects' table.
 * 
 * WHAT: Data Access Object for Subject records.
 * WHY: Decouples database querying of subjects from the service and controller layers.
 * HOW: standard JDBC Connection and PreparedStatements.
 * WHERE: Placed in the com.examora.dao package.
 */
public class SubjectDAO {

    /**
     * Retrieves all subjects associated with a specific examination.
     * @param examId the targeted exam ID
     * @return List of Subject objects
     */
    public List<Subject> getSubjectsByExamId(int examId) {
        List<Subject> subjects = new ArrayList<>();
        String sql = "SELECT id, name FROM subjects WHERE exam_id = ? ORDER BY name ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, examId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Subject subject = new Subject();
                    subject.setId(rs.getInt("id"));
                    subject.setExamId(examId);
                    subject.setName(rs.getString("name"));
                    subjects.add(subject);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error fetching subjects for exam: " + e.getMessage());
            e.printStackTrace();
        }
        return subjects;
    }
}
