package com.examora.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * StudyTask represents an individual learning session, revision slot, or mock test.
 * 
 * WHAT: Model POJO mapping to the 'study_tasks' table in MySQL.
 * WHY: Contains scheduled properties (date, target hours, type, status) for a specific topic.
 * HOW: Declares attributes, getters, setters, and UI display helpers (topicName, subjectName).
 * WHERE: Placed in the com.examora.model package.
 */
public class StudyTask {
    private int id;
    private int studyPlanId;
    private int topicId;
    private LocalDate scheduledDate;
    private double scheduledHours;
    private double completedHours;
    private String status; // PENDING, COMPLETED, MISSED, SKIPPED
    private boolean isRevision;
    private boolean isMockTest;
    private String taskMode; // LEARN, PRACTICE, REVISION
    private LocalDateTime createdAt;

    // UI Helper attributes (populated via JOIN queries for rendering convenience)
    private String topicName;
    private String subjectName;
    private String priority;

    // Constructors
    public StudyTask() {}

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getStudyPlanId() {
        return studyPlanId;
    }

    public void setStudyPlanId(int studyPlanId) {
        this.studyPlanId = studyPlanId;
    }

    public int getTopicId() {
        return topicId;
    }

    public void setTopicId(int topicId) {
        this.topicId = topicId;
    }

    public LocalDate getScheduledDate() {
        return scheduledDate;
    }

    public void setScheduledDate(LocalDate scheduledDate) {
        this.scheduledDate = scheduledDate;
    }

    public double getScheduledHours() {
        return scheduledHours;
    }

    public void setScheduledHours(double scheduledHours) {
        this.scheduledHours = scheduledHours;
    }

    public double getCompletedHours() {
        return completedHours;
    }

    public void setCompletedHours(double completedHours) {
        this.completedHours = completedHours;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public boolean isRevision() {
        return isRevision;
    }

    public void setRevision(boolean revision) {
        isRevision = revision;
    }

    public boolean isMockTest() {
        return isMockTest;
    }

    public void setMockTest(boolean mockTest) {
        isMockTest = mockTest;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public String getTopicName() {
        return topicName;
    }

    public void setTopicName(String topicName) {
        this.topicName = topicName;
    }

    public String getSubjectName() {
        return subjectName;
    }

    public void setSubjectName(String subjectName) {
        this.subjectName = subjectName;
    }

    public String getPriority() {
        return priority;
    }

    public void setPriority(String priority) {
        this.priority = priority;
    }

    public String getTaskMode() {
        return taskMode;
    }

    public void setTaskMode(String taskMode) {
        this.taskMode = taskMode;
    }

    private String allocationExplanation;

    public String getAllocationExplanation() {
        return allocationExplanation;
    }

    public void setAllocationExplanation(String allocationExplanation) {
        this.allocationExplanation = allocationExplanation;
    }
}
