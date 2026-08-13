package com.examora.dao;

import com.examora.model.PYQStaging;
import com.examora.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class PYQStagingDAO {

    public boolean saveStagingQuestion(PYQStaging q) {
        String sql = "INSERT INTO pyq_pdf_staging (exam_id, subject_id, year, source_pdf_filename, source_url, " +
                     "extracted_question_text, extracted_options_json, extracted_correct_answer, extracted_explanation, " +
                     "suggested_topic_id, suggested_difficulty, review_status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, q.getExamId());
            ps.setInt(2, q.getSubjectId());
            ps.setInt(3, q.getYear());
            ps.setString(4, q.getSourcePdfFilename());
            ps.setString(5, q.getSourceUrl());
            ps.setString(6, q.getExtractedQuestionText());
            ps.setString(7, q.getExtractedOptionsJson());
            ps.setString(8, q.getExtractedCorrectAnswer());
            ps.setString(9, q.getExtractedExplanation());
            ps.setInt(10, q.getSuggestedTopicId());
            ps.setString(11, q.getSuggestedDifficulty());
            ps.setString(12, q.getReviewStatus());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error saving pyq staging question: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public List<PYQStaging> getPendingStagingQuestions() {
        List<PYQStaging> list = new ArrayList<>();
        String sql = "SELECT id, exam_id, subject_id, year, source_pdf_filename, source_url, extracted_question_text, " +
                     "extracted_options_json, extracted_correct_answer, extracted_explanation, suggested_topic_id, " +
                     "suggested_difficulty, review_status, created_at FROM pyq_pdf_staging WHERE review_status = 'PENDING_REVIEW' ORDER BY id ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                PYQStaging q = new PYQStaging();
                q.setId(rs.getInt("id"));
                q.setExamId(rs.getInt("exam_id"));
                q.setSubjectId(rs.getInt("subject_id"));
                q.setYear(rs.getInt("year"));
                q.setSourcePdfFilename(rs.getString("source_pdf_filename"));
                q.setSourceUrl(rs.getString("source_url"));
                q.setExtractedQuestionText(rs.getString("extracted_question_text"));
                q.setExtractedOptionsJson(rs.getString("extracted_options_json"));
                q.setExtractedCorrectAnswer(rs.getString("extracted_correct_answer"));
                q.setExtractedExplanation(rs.getString("extracted_explanation"));
                q.setSuggestedTopicId(rs.getInt("suggested_topic_id"));
                q.setSuggestedDifficulty(rs.getString("suggested_difficulty"));
                q.setReviewStatus(rs.getString("review_status"));
                q.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
                list.add(q);
            }
        } catch (SQLException e) {
            System.err.println("Error listing pending staging questions: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    public PYQStaging getStagingQuestionById(int id) {
        String sql = "SELECT id, exam_id, subject_id, year, source_pdf_filename, source_url, extracted_question_text, " +
                     "extracted_options_json, extracted_correct_answer, extracted_explanation, suggested_topic_id, " +
                     "suggested_difficulty, review_status, created_at FROM pyq_pdf_staging WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PYQStaging q = new PYQStaging();
                    q.setId(rs.getInt("id"));
                    q.setExamId(rs.getInt("exam_id"));
                    q.setSubjectId(rs.getInt("subject_id"));
                    q.setYear(rs.getInt("year"));
                    q.setSourcePdfFilename(rs.getString("source_pdf_filename"));
                    q.setSourceUrl(rs.getString("source_url"));
                    q.setExtractedQuestionText(rs.getString("extracted_question_text"));
                    q.setExtractedOptionsJson(rs.getString("extracted_options_json"));
                    q.setExtractedCorrectAnswer(rs.getString("extracted_correct_answer"));
                    q.setExtractedExplanation(rs.getString("extracted_explanation"));
                    q.setSuggestedTopicId(rs.getInt("suggested_topic_id"));
                    q.setSuggestedDifficulty(rs.getString("suggested_difficulty"));
                    q.setReviewStatus(rs.getString("review_status"));
                    q.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
                    return q;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error getting staging question: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateStagingQuestion(PYQStaging q) {
        String sql = "UPDATE pyq_pdf_staging SET year = ?, extracted_question_text = ?, extracted_options_json = ?, " +
                     "extracted_correct_answer = ?, extracted_explanation = ?, suggested_topic_id = ?, suggested_difficulty = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, q.getYear());
            ps.setString(2, q.getExtractedQuestionText());
            ps.setString(3, q.getExtractedOptionsJson());
            ps.setString(4, q.getExtractedCorrectAnswer());
            ps.setString(5, q.getExtractedExplanation());
            ps.setInt(6, q.getSuggestedTopicId());
            ps.setString(7, q.getSuggestedDifficulty());
            ps.setInt(8, q.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error updating staging question: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateStagingStatus(int id, String status) {
        String sql = "UPDATE pyq_pdf_staging SET review_status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error updating staging status: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public boolean promoteToLive(int stagingId) {
        PYQStaging sq = getStagingQuestionById(stagingId);
        if (sq == null) return false;

        String insertSql = "INSERT INTO pyq_questions (exam_id, subject_id, topic_id, question_text, options_json, correct_answer, explanation, difficulty, marks, year, is_verified, source) " +
                           "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, TRUE, ?)";
        
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                    ps.setInt(1, sq.getExamId());
                    ps.setInt(2, sq.getSubjectId());
                    ps.setInt(3, sq.getSuggestedTopicId());
                    ps.setString(4, sq.getExtractedQuestionText());
                    ps.setString(5, sq.getExtractedOptionsJson());
                    ps.setString(6, sq.getExtractedCorrectAnswer());
                    ps.setString(7, sq.getExtractedExplanation());
                    ps.setString(8, sq.getSuggestedDifficulty());
                    ps.setDouble(9, 2.0);
                    ps.setInt(10, sq.getYear());
                    ps.setString(11, sq.getSourceUrl());
                    
                    if (ps.executeUpdate() <= 0) {
                        conn.rollback();
                        return false;
                    }
                }
                
                String updateSql = "UPDATE pyq_pdf_staging SET review_status = 'APPROVED' WHERE id = ?";
                try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                    ps.setInt(1, stagingId);
                    ps.executeUpdate();
                }
                
                String updateCoverageSql = "INSERT INTO pyq_year_coverage (exam_id, subject_id, year, question_count, verified_count, ingestion_status) " +
                                           "VALUES (?, ?, ?, 1, 1, 'COMPLETE') " +
                                           "ON DUPLICATE KEY UPDATE question_count = question_count + 1, verified_count = verified_count + 1, ingestion_status = 'COMPLETE'";
                try (PreparedStatement ps = conn.prepareStatement(updateCoverageSql)) {
                    ps.setInt(1, sq.getExamId());
                    ps.setInt(2, sq.getSubjectId());
                    ps.setInt(3, sq.getYear());
                    ps.executeUpdate();
                }
                
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        } catch (SQLException e) {
            System.err.println("Error promoting staging question: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
}
