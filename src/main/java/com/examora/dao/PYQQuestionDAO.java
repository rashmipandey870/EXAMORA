package com.examora.dao;

import com.examora.model.PYQQuestion;
import com.examora.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class PYQQuestionDAO {

    public List<PYQQuestion> getQuestionsForExam(int examId) {
        List<PYQQuestion> list = new ArrayList<>();
        String sql = "SELECT id, exam_id, subject_id, topic_id, year, question_text, options_json, correct_answer, explanation, difficulty, marks, is_verified, source FROM pyq_questions WHERE exam_id = ? ORDER BY id ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, examId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    PYQQuestion q = new PYQQuestion();
                    q.setId(rs.getInt("id"));
                    q.setExamId(rs.getInt("exam_id"));
                    q.setSubjectId(rs.getInt("subject_id"));
                    q.setTopicId(rs.getInt("topic_id"));
                    
                    int yr = rs.getInt("year");
                    q.setYear(rs.wasNull() ? null : yr);
                    
                    q.setQuestionText(rs.getString("question_text"));
                    q.setOptionsJson(rs.getString("options_json"));
                    q.setCorrectAnswer(rs.getString("correct_answer"));
                    q.setExplanation(rs.getString("explanation"));
                    q.setDifficulty(rs.getString("difficulty"));
                    q.setMarks(rs.getDouble("marks"));
                    q.setVerified(rs.getBoolean("is_verified"));
                    q.setSource(rs.getString("source"));
                    list.add(q);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error loading pyq questions: " + e.getMessage());
            e.printStackTrace();
        }
        return list;
    }

    public PYQQuestion getQuestionById(int id) {
        String sql = "SELECT id, exam_id, subject_id, topic_id, year, question_text, options_json, correct_answer, explanation, difficulty, marks, is_verified, source FROM pyq_questions WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    PYQQuestion q = new PYQQuestion();
                    q.setId(rs.getInt("id"));
                    q.setExamId(rs.getInt("exam_id"));
                    q.setSubjectId(rs.getInt("subject_id"));
                    q.setTopicId(rs.getInt("topic_id"));
                    int yr = rs.getInt("year");
                    q.setYear(rs.wasNull() ? null : yr);
                    q.setQuestionText(rs.getString("question_text"));
                    q.setOptionsJson(rs.getString("options_json"));
                    q.setCorrectAnswer(rs.getString("correct_answer"));
                    q.setExplanation(rs.getString("explanation"));
                    q.setDifficulty(rs.getString("difficulty"));
                    q.setMarks(rs.getDouble("marks"));
                    q.setVerified(rs.getBoolean("is_verified"));
                    q.setSource(rs.getString("source"));
                    return q;
                }
            }
        } catch (SQLException e) {
            System.err.println("Error loading pyq question by id: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
}
