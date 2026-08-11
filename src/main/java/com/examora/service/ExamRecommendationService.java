package com.examora.service;

import com.examora.model.Exam;
import com.examora.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ExamRecommendationService {

    public List<Exam> getRecommendedExams(String background, String goal, String targetTimeline) {
        List<Exam> recommendations = new ArrayList<>();
        
        // Match minimum education level by mapping background token to educational level
        String minEducation = "ANY";
        if ("CLASS_12_PCM".equals(background)) {
            minEducation = "HIGH_SCHOOL";
        } else if ("B_TECH_CSE".equals(background) || "B_TECH_STEM".equals(background) || "COMMERCE".equals(background) || "SCIENCE_GRAD".equals(background)) {
            minEducation = "GRADUATION";
        } else if ("WORKING_PROFESSIONAL".equals(background)) {
            minEducation = "GRADUATION"; // Assuming graduate background
        }
        
        // Resolve timeline target year
        Integer targetYear = null;
        if (targetTimeline != null && !targetTimeline.isEmpty() && !"EXPLORING".equals(targetTimeline)) {
            try {
                targetYear = Integer.parseInt(targetTimeline);
            } catch (NumberFormatException e) {
                // Ignore and treat as exploring
            }
        }
        
        String query = "SELECT id, name, exam_year, exam_date, is_custom, conducting_body, eligibility_criteria, min_education_level, eligible_streams, goal_tags, exam_pattern_summary, typical_application_window, typical_exam_date_window, official_website_url, syllabus_availability_status, last_verified_at, is_rolling_exam, is_verified_dates " +
                       "FROM exams " +
                       "WHERE (min_education_level = 'ANY' OR min_education_level = ?) " +
                       "  AND (eligible_streams = 'ANY' OR FIND_IN_SET(?, eligible_streams) > 0) " +
                       "  AND (goal_tags = 'ANY' OR ? = 'EXPLORING' OR FIND_IN_SET(?, goal_tags) > 0) " +
                       "  AND (is_rolling_exam = TRUE OR ? IS NULL OR exam_year = ?) " +
                       "ORDER BY name ASC";
                       
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(query)) {
             
            ps.setString(1, minEducation);
            ps.setString(2, background);
            ps.setString(3, goal);
            ps.setString(4, goal);
            
            // Set timeline filters using safe setNull calls
            if (targetYear == null) {
                ps.setNull(5, java.sql.Types.INTEGER);
                ps.setNull(6, java.sql.Types.INTEGER);
            } else {
                ps.setInt(5, targetYear);
                ps.setInt(6, targetYear);
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
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
                    
                    recommendations.add(exam);
                }
            }
            
        } catch (SQLException e) {
            System.err.println("Error matching recommended exams: " + e.getMessage());
            e.printStackTrace();
        }
        
        return recommendations;
    }
}
