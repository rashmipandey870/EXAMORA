package com.examora.model;

public class PYQQuestion {
    private int id;
    private int examId;
    private int subjectId;
    private int topicId;
    private Integer year;
    private String questionText;
    private String optionsJson; // e.g. ["A", "B", "C", "D"]
    private String correctAnswer;
    private String explanation;
    private String difficulty;
    private double marks;
    private boolean isVerified;
    private String source;

    public PYQQuestion() {}

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getExamId() {
        return examId;
    }

    public void setExamId(int examId) {
        this.examId = examId;
    }

    public int getSubjectId() {
        return subjectId;
    }

    public void setSubjectId(int subjectId) {
        this.subjectId = subjectId;
    }

    public int getTopicId() {
        return topicId;
    }

    public void setTopicId(int topicId) {
        this.topicId = topicId;
    }

    public Integer getYear() {
        return year;
    }

    public void setYear(Integer year) {
        this.year = year;
    }

    public String getQuestionText() {
        return questionText;
    }

    public void setQuestionText(String questionText) {
        this.questionText = questionText;
    }

    public String getOptionsJson() {
        return optionsJson;
    }

    public void setOptionsJson(String optionsJson) {
        this.optionsJson = optionsJson;
    }

    public java.util.Map<String, String> getParsedOptions() {
        try {
            com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
            return mapper.readValue(this.optionsJson,
                new com.fasterxml.jackson.core.type.TypeReference<java.util.Map<String, String>>() {});
        } catch (Exception e) {
            // This fallback should never trigger on real post-migration data.
            // If it does, log loudly server-side — do not let it silently mask a real data problem.
            System.err.println("CRITICAL: Failed to parse optionsJson for question ID " + this.getId()
                + " — options_json value: " + this.optionsJson + " — error: " + e.getMessage());
            return java.util.Collections.emptyMap();
        }
    }

    public String getCorrectAnswer() {
        return correctAnswer;
    }

    public void setCorrectAnswer(String correctAnswer) {
        this.correctAnswer = correctAnswer;
    }

    public String getExplanation() {
        return explanation;
    }

    public void setExplanation(String explanation) {
        this.explanation = explanation;
    }

    public String getDifficulty() {
        return difficulty;
    }

    public void setDifficulty(String difficulty) {
        this.difficulty = difficulty;
    }

    public double getMarks() {
        return marks;
    }

    public void setMarks(double marks) {
        this.marks = marks;
    }

    public boolean isVerified() {
        return isVerified;
    }

    public void setVerified(boolean verified) {
        isVerified = verified;
    }

    public String getSource() {
        return source;
    }

    public void setSource(String source) {
        this.source = source;
    }
}
