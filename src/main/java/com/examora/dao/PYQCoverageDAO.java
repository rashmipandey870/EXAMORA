package com.examora.dao;

import com.examora.model.PYQCoverage;
import com.examora.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * PYQCoverageDAO manages access to database stats for year-wise question bank availability.
 */
public class PYQCoverageDAO {

    public List<PYQCoverage> getCoverageForSubject(int examId, int subjectId) {
        List<PYQCoverage> list = new ArrayList<>();
        String sql = "SELECT c.id, c.exam_id, c.subject_id, c.year, " +
                     "       (SELECT COUNT(*) FROM pyq_questions q WHERE q.subject_id = c.subject_id AND q.year = c.year) AS question_count, " +
                     "       (SELECT COUNT(*) FROM pyq_questions q WHERE q.subject_id = c.subject_id AND q.year = c.year AND q.is_verified = TRUE) AS verified_count, " +
                     "       c.source_url, c.ingestion_status " +
                     "FROM pyq_year_coverage c WHERE c.exam_id = ? AND c.subject_id = ? ORDER BY c.year DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, examId);
            ps.setInt(2, subjectId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PYQCoverage cov = new PYQCoverage();
                    cov.setId(rs.getInt("id"));
                    cov.setExamId(rs.getInt("exam_id"));
                    cov.setSubjectId(rs.getInt("subject_id"));
                    cov.setYear(rs.getInt("year"));
                    cov.setQuestionCount(rs.getInt("question_count"));
                    cov.setVerifiedCount(rs.getInt("verified_count"));
                    cov.setSourceUrl(rs.getString("source_url"));
                    cov.setIngestionStatus(rs.getString("ingestion_status"));
                    list.add(cov);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error loading pyq coverage for subject: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    public Map<String, Integer> getSummaryStats(int examId) {
        Map<String, Integer> stats = new HashMap<>();
        String sql = "SELECT COUNT(*) AS total_years, SUM(CASE WHEN ingestion_status = 'COMPLETE' THEN 1 ELSE 0 END) AS complete_years " +
                     "FROM pyq_year_coverage WHERE exam_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, examId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.put("totalYears", rs.getInt("total_years"));
                    stats.put("completeYears", rs.getInt("complete_years"));
                }
            }
        } catch (SQLException e) {
            System.err.println("Error loading pyq summary stats: " + e.getMessage());
            e.printStackTrace();
        }
        
        if (!stats.containsKey("totalYears")) {
            stats.put("totalYears", 0);
            stats.put("completeYears", 0);
        }
        return stats;
    }
}
