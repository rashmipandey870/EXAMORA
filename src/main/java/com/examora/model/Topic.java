package com.examora.model;

import java.time.LocalDateTime;

/**
 * Topic represents a specific syllabus module inside a subject.
 * 
 * WHAT: Model POJO mapping to the 'topics' table in MySQL.
 * WHY: Holds the topic parameters and associated trend intelligence/provenance data.
 * HOW: Declares static topic parameters and trend-specific fields populated via SQL joins.
 * WHERE: Placed in the com.examora.model package.
 */
public class Topic {
    private int id;
    private int subjectId;
    private String name;
    private String description;
    private String difficulty; // EASY, MEDIUM, HARD
    private int estimatedHours;

    // Trend & Provenance details populated from topic_trends and sources tables
    private String priority; // VERY HIGH, HIGH, MEDIUM, LOW
    private String historicalFrequency; // HIGH, MEDIUM, LOW
    private String recentFrequency; // HIGH, MEDIUM, LOW
    private String yearsAppeared; // e.g. "2021,2022,2024"
    private int numberOfQuestions;
    private String verificationStatus; // VERIFIED, AI_GENERATED, ESTIMATED
    private String trendSourceUrl;
    private String trendSourceTitle;
    private LocalDateTime trendRetrievedAt;

    // Phase 16 expanded fields
    private Double weightage;
    private double computedYieldScore;
    private int unitId;
    private java.util.List<SubTopic> subTopics = new java.util.ArrayList<>();
    private java.util.List<String> prerequisites = new java.util.ArrayList<>();

    // Constructors
    public Topic() {}

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getSubjectId() {
        return subjectId;
    }

    public void setSubjectId(int subjectId) {
        this.subjectId = subjectId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getDifficulty() {
        return difficulty;
    }

    public void setDifficulty(String difficulty) {
        this.difficulty = difficulty;
    }

    public int getEstimatedHours() {
        return estimatedHours;
    }

    public void setEstimatedHours(int estimatedHours) {
        this.estimatedHours = estimatedHours;
    }

    public String getPriority() {
        return priority;
    }

    public void setPriority(String priority) {
        this.priority = priority;
    }

    public String getHistoricalFrequency() {
        return historicalFrequency;
    }

    public void setHistoricalFrequency(String historicalFrequency) {
        this.historicalFrequency = historicalFrequency;
    }

    public String getRecentFrequency() {
        return recentFrequency;
    }

    public void setRecentFrequency(String recentFrequency) {
        this.recentFrequency = recentFrequency;
    }

    public String getYearsAppeared() {
        return yearsAppeared;
    }

    public void setYearsAppeared(String yearsAppeared) {
        this.yearsAppeared = yearsAppeared;
    }

    public int getNumberOfQuestions() {
        return numberOfQuestions;
    }

    public void setNumberOfQuestions(int numberOfQuestions) {
        this.numberOfQuestions = numberOfQuestions;
    }

    public String getVerificationStatus() {
        return verificationStatus;
    }

    public void setVerificationStatus(String verificationStatus) {
        this.verificationStatus = verificationStatus;
    }

    public String getTrendSourceUrl() {
        return trendSourceUrl;
    }

    public void setTrendSourceUrl(String trendSourceUrl) {
        this.trendSourceUrl = trendSourceUrl;
    }

    public String getTrendSourceTitle() {
        return trendSourceTitle;
    }

    public void setTrendSourceTitle(String trendSourceTitle) {
        this.trendSourceTitle = trendSourceTitle;
    }

    public LocalDateTime getTrendRetrievedAt() {
        return trendRetrievedAt;
    }

    public void setTrendRetrievedAt(LocalDateTime trendRetrievedAt) {
        this.trendRetrievedAt = trendRetrievedAt;
    }

    public Double getWeightage() {
        return weightage;
    }

    public void setWeightage(Double weightage) {
        this.weightage = weightage;
    }

    public double getComputedYieldScore() {
        return computedYieldScore;
    }

    public void setComputedYieldScore(double computedYieldScore) {
        this.computedYieldScore = computedYieldScore;
    }

    public int getUnitId() {
        return unitId;
    }

    public void setUnitId(int unitId) {
        this.unitId = unitId;
    }

    public java.util.List<SubTopic> getSubTopics() {
        return subTopics;
    }

    public void setSubTopics(java.util.List<SubTopic> subTopics) {
        this.subTopics = subTopics;
    }

    public void addSubTopic(SubTopic subTopic) {
        this.subTopics.add(subTopic);
    }

    public java.util.List<String> getPrerequisites() {
        return prerequisites;
    }

    public void setPrerequisites(java.util.List<String> prerequisites) {
        this.prerequisites = prerequisites;
    }

    public void addPrerequisite(String prerequisite) {
        this.prerequisites.add(prerequisite);
    }

    // Expose priority score and allocation explanations
    private double priorityScore;
    private String allocationExplanation;

    public double getPriorityScore() {
        return priorityScore;
    }

    public void setPriorityScore(double priorityScore) {
        this.priorityScore = priorityScore;
    }

    public String getAllocationExplanation() {
        return allocationExplanation;
    }

    public void setAllocationExplanation(String allocationExplanation) {
        this.allocationExplanation = allocationExplanation;
    }
}
