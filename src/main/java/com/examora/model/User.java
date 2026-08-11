package com.examora.model;

import java.time.LocalDateTime;

/**
 * User represents a registered student in the EXAMORA system.
 * 
 * WHAT: It is a Model (POJO) representing the 'users' table in MySQL.
 * WHY: We need it to pass user data between the controller, services, and the database.
 * HOW: Holds private fields (id, username, email, passwordHash, etc.) with getters/setters.
 * WHERE: It belongs in the com.examora.model package.
 */
public class User {
    private int id;
    private String username;
    private String email;
    private String passwordHash;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private String background;
    private String goal;
    private String targetTimeline;

    // Constructors
    public User() {}

    public User(String username, String email, String passwordHash) {
        this.username = username;
        this.email = email;
        this.passwordHash = passwordHash;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getBackground() {
        return background;
    }

    public void setBackground(String background) {
        this.background = background;
    }

    public String getGoal() {
        return goal;
    }

    public void setGoal(String goal) {
        this.goal = goal;
    }

    public String getTargetTimeline() {
        return targetTimeline;
    }

    public void setTargetTimeline(String targetTimeline) {
        this.targetTimeline = targetTimeline;
    }

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", username='" + username + '\'' +
                ", email='" + email + '\'' +
                ", background='" + background + '\'' +
                ", goal='" + goal + '\'' +
                ", targetTimeline='" + targetTimeline + '\'' +
                '}';
    }
}
