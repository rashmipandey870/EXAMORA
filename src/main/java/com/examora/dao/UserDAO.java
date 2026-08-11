package com.examora.dao;

import com.examora.model.User;
import com.examora.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

/**
 * UserDAO performs SQL operations on the 'users' table.
 * 
 * WHAT: It is a Data Access Object (DAO) representing the database interface for Users.
 * WHY: We need it to encapsulate all SQL queries related to users, keeping SQL out of our servlets.
 * HOW: Uses standard JDBC PreparedStatements to prevent SQL injection, returning User objects.
 * WHERE: It belongs in the com.examora.dao package.
 */
public class UserDAO {

    /**
     * Creates a new user record in the database.
     * @param user User model containing username, email, and password_hash.
     * @return true if insertion succeeded, false otherwise.
     */
    public boolean createUser(User user) {
        String sql = "INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getPasswordHash());
            
            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected > 0) {
                // Retrieve the auto-generated user ID
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        user.setId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            System.err.println("Error creating user: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Retrieves a user by their username.
     * @param username the username to search for.
     * @return User object if found, null otherwise.
     */
     public User getUserByUsername(String username) {
        String sql = "SELECT id, username, email, password_hash, created_at, updated_at, background, goal, target_timeline FROM users WHERE username = ?";
        return queryUser(sql, username);
    }

    /**
     * Retrieves a user by their email address.
     * @param email the email to search for.
     * @return User object if found, null otherwise.
     */
    public User getUserByEmail(String email) {
        String sql = "SELECT id, username, email, password_hash, created_at, updated_at, background, goal, target_timeline FROM users WHERE email = ?";
        return queryUser(sql, email);
    }

    /**
     * Retrieves a user by their database ID.
     * @param id user database ID.
     * @return User object if found, null otherwise.
     */
    public User getUserById(int id) {
        String sql = "SELECT id, username, email, password_hash, created_at, updated_at, background, goal, target_timeline FROM users WHERE id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRowToUser(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error fetching user by ID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Updates the user's onboarding profile.
     * @param id user database ID.
     * @param background user background field.
     * @param goal user goal field.
     * @param targetTimeline user target timeline field.
     * @return true if successful, false otherwise.
     */
    public boolean updateUserProfile(int id, String background, String goal, String targetTimeline) {
        String sql = "UPDATE users SET background = ?, goal = ?, target_timeline = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, background);
            stmt.setString(2, goal);
            stmt.setString(3, targetTimeline);
            stmt.setInt(4, id);
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("Error updating user profile: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // Helper method to execute a parameterized search query returning a User
    private User queryUser(String sql, String parameter) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, parameter);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRowToUser(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error executing user query: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    // Helper to map a database row to a User object
    private User mapRowToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setUsername(rs.getString("username"));
        user.setEmail(rs.getString("email"));
        user.setPasswordHash(rs.getString("password_hash"));
        
        Timestamp created = rs.getTimestamp("created_at");
        if (created != null) {
            user.setCreatedAt(created.toLocalDateTime());
        }
        Timestamp updated = rs.getTimestamp("updated_at");
        if (updated != null) {
            user.setUpdatedAt(updated.toLocalDateTime());
        }
        
        user.setBackground(rs.getString("background"));
        user.setGoal(rs.getString("goal"));
        user.setTargetTimeline(rs.getString("target_timeline"));
        
        return user;
    }
}
