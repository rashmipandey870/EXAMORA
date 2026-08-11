package com.examora.model;

import java.time.LocalDate;

/**
 * Exam represents a target examination.
 * 
 * WHAT: Model POJO mapping to the 'exams' table in MySQL.
 * WHY: Contains parameters defining the exam name, target year, and deadline date.
 * HOW: Declares attributes (id, name, examYear, examDate, isCustom) with getters/setters.
 * WHERE: Placed in the com.examora.model package.
 */
public class Exam {
    private int id;
    private String name;
    private int examYear;
    private LocalDate examDate;
    private boolean isCustom;
    private String conductingBody;
    private String eligibilityCriteria;
    private String minEducationLevel;
    private String eligibleStreams;
    private String goalTags;
    private String examPatternSummary;
    private String typicalApplicationWindow;
    private String typicalExamDateWindow;
    private String officialWebsiteUrl;
    private String syllabusAvailabilityStatus;
    private java.time.LocalDateTime lastVerifiedAt;
    private boolean isRollingExam;
    private boolean isVerifiedDates;

    // Constructors
    public Exam() {}

    public Exam(int id, String name, int examYear, LocalDate examDate, boolean isCustom) {
        this.id = id;
        this.name = name;
        this.examYear = examYear;
        this.examDate = examDate;
        this.isCustom = isCustom;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getExamYear() {
        return examYear;
    }

    public void setExamYear(int examYear) {
        this.examYear = examYear;
    }

    public LocalDate getExamDate() {
        return examDate;
    }

    public void setExamDate(LocalDate examDate) {
        this.examDate = examDate;
    }

    public boolean isCustom() {
        return isCustom;
    }

    public void setCustom(boolean custom) {
        isCustom = custom;
    }

    public String getConductingBody() {
        return conductingBody;
    }

    public void setConductingBody(String conductingBody) {
        this.conductingBody = conductingBody;
    }

    public String getEligibilityCriteria() {
        return eligibilityCriteria;
    }

    public void setEligibilityCriteria(String eligibilityCriteria) {
        this.eligibilityCriteria = eligibilityCriteria;
    }

    public String getMinEducationLevel() {
        return minEducationLevel;
    }

    public void setMinEducationLevel(String minEducationLevel) {
        this.minEducationLevel = minEducationLevel;
    }

    public String getEligibleStreams() {
        return eligibleStreams;
    }

    public void setEligibleStreams(String eligibleStreams) {
        this.eligibleStreams = eligibleStreams;
    }

    public String getGoalTags() {
        return goalTags;
    }

    public void setGoalTags(String goalTags) {
        this.goalTags = goalTags;
    }

    public String getExamPatternSummary() {
        return examPatternSummary;
    }

    public void setExamPatternSummary(String examPatternSummary) {
        this.examPatternSummary = examPatternSummary;
    }

    public String getTypicalApplicationWindow() {
        return typicalApplicationWindow;
    }

    public void setTypicalApplicationWindow(String typicalApplicationWindow) {
        this.typicalApplicationWindow = typicalApplicationWindow;
    }

    public String getTypicalExamDateWindow() {
        return typicalExamDateWindow;
    }

    public void setTypicalExamDateWindow(String typicalExamDateWindow) {
        this.typicalExamDateWindow = typicalExamDateWindow;
    }

    public String getOfficialWebsiteUrl() {
        return officialWebsiteUrl;
    }

    public void setOfficialWebsiteUrl(String officialWebsiteUrl) {
        this.officialWebsiteUrl = officialWebsiteUrl;
    }

    public String getSyllabusAvailabilityStatus() {
        return syllabusAvailabilityStatus;
    }

    public void setSyllabusAvailabilityStatus(String syllabusAvailabilityStatus) {
        this.syllabusAvailabilityStatus = syllabusAvailabilityStatus;
    }

    public java.time.LocalDateTime getLastVerifiedAt() {
        return lastVerifiedAt;
    }

    public void setLastVerifiedAt(java.time.LocalDateTime lastVerifiedAt) {
        this.lastVerifiedAt = lastVerifiedAt;
    }

    public boolean isRollingExam() {
        return isRollingExam;
    }

    public void setRollingExam(boolean rollingExam) {
        isRollingExam = rollingExam;
    }

    public boolean isVerifiedDates() {
        return isVerifiedDates;
    }

    public void setVerifiedDates(boolean verifiedDates) {
        isVerifiedDates = verifiedDates;
    }
}
