package com.examora.model;

import java.time.LocalDate;

public class DeadlineEvent {
    private int id;
    private int examId;
    private String eventType;
    private LocalDate eventDate;
    private boolean isEstimated;
    private String source;
    private java.time.LocalDateTime lastCheckedAt;

    public DeadlineEvent() {}

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

    public String getEventType() {
        return eventType;
    }

    public void setEventType(String eventType) {
        this.eventType = eventType;
    }

    public LocalDate getEventDate() {
        return eventDate;
    }

    public void setEventDate(LocalDate eventDate) {
        this.eventDate = eventDate;
    }

    public boolean isEstimated() {
        return isEstimated;
    }

    public void setEstimated(boolean estimated) {
        isEstimated = estimated;
    }

    public String getSource() {
        return source;
    }

    public void setSource(String source) {
        this.source = source;
    }

    public java.time.LocalDateTime getLastCheckedAt() {
        return lastCheckedAt;
    }

    public void setLastCheckedAt(java.time.LocalDateTime lastCheckedAt) {
        this.lastCheckedAt = lastCheckedAt;
    }
}
