package com.examora.model;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.LocalDateTime;
import java.util.Collections;
import java.util.Map;

public class PYQStaging {
    private int id;
    private int examId;
    private int subjectId;
    private int year;
    private String sourcePdfFilename;
    private String sourceUrl;
    private String extractedQuestionText;
    private String extractedOptionsJson;
    private String extractedCorrectAnswer;
    private String extractedExplanation;
    private int suggestedTopicId;
    private String suggestedDifficulty;
    private String reviewStatus;
    private LocalDateTime createdAt;

    private static final ObjectMapper mapper = new ObjectMapper();

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getExamId() { return examId; }
    public void setExamId(int examId) { this.examId = examId; }

    public int getSubjectId() { return subjectId; }
    public void setSubjectId(int subjectId) { this.subjectId = subjectId; }

    public int getYear() { return year; }
    public void setYear(int year) { this.year = year; }

    public String getSourcePdfFilename() { return sourcePdfFilename; }
    public void setSourcePdfFilename(String sourcePdfFilename) { this.sourcePdfFilename = sourcePdfFilename; }

    public String getSourceUrl() { return sourceUrl; }
    public void setSourceUrl(String sourceUrl) { this.sourceUrl = sourceUrl; }

    public String getExtractedQuestionText() { return extractedQuestionText; }
    public void setExtractedQuestionText(String extractedQuestionText) { this.extractedQuestionText = extractedQuestionText; }

    public String getExtractedOptionsJson() { return extractedOptionsJson; }
    public void setExtractedOptionsJson(String extractedOptionsJson) { this.extractedOptionsJson = extractedOptionsJson; }

    public String getExtractedCorrectAnswer() { return extractedCorrectAnswer; }
    public void setExtractedCorrectAnswer(String extractedCorrectAnswer) { this.extractedCorrectAnswer = extractedCorrectAnswer; }

    public String getExtractedExplanation() { return extractedExplanation; }
    public void setExtractedExplanation(String extractedExplanation) { this.extractedExplanation = extractedExplanation; }

    public int getSuggestedTopicId() { return suggestedTopicId; }
    public void setSuggestedTopicId(int suggestedTopicId) { this.suggestedTopicId = suggestedTopicId; }

    public String getSuggestedDifficulty() { return suggestedDifficulty; }
    public void setSuggestedDifficulty(String suggestedDifficulty) { this.suggestedDifficulty = suggestedDifficulty; }

    public String getReviewStatus() { return reviewStatus; }
    public void setReviewStatus(String reviewStatus) { this.reviewStatus = reviewStatus; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public Map<String, String> getParsedOptions() {
        if (extractedOptionsJson == null || extractedOptionsJson.trim().isEmpty()) {
            return Collections.emptyMap();
        }
        try {
            return mapper.readValue(extractedOptionsJson, new TypeReference<Map<String, String>>() {});
        } catch (Exception e) {
            System.err.println("Warning: failed to parse staging options JSON: " + e.getMessage());
            return Collections.emptyMap();
        }
    }
}
