package com.examora.service;

import com.examora.dao.UserDAO;
import com.examora.model.User;
import com.examora.util.PasswordUtil;

import java.util.regex.Pattern;

/**
 * AuthService handles authentication-related business logic.
 * 
 * WHAT: It is a Service layer that validates and registers users, and validates login credentials.
 * WHY: Servlets should not handle complex validation, check duplicate constraints directly, or manage password checks.
 * HOW: Validates input strings (regex checks for email, character rules for username) and interacts with UserDAO.
 * WHERE: It belongs in the com.examora.service package.
 */
public class AuthService {

    private final UserDAO userDAO = new UserDAO();

    // Simple email validation regex pattern
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$");

    /**
     * Registers a new student in the system.
     * @param username requested username
     * @param email requested email address
     * @param password plain text password
     * @return User object of the created user if successful, throws an Exception otherwise.
     */
    public User registerUser(String username, String email, String password) throws Exception {
        // 1. Inputs validation
        if (username == null || username.trim().isEmpty()) {
            throw new IllegalArgumentException("Username cannot be empty.");
        }
        if (email == null || email.trim().isEmpty()) {
            throw new IllegalArgumentException("Email cannot be empty.");
        }
        if (password == null || password.length() < 6) {
            throw new IllegalArgumentException("Password must be at least 6 characters long.");
        }

        username = username.trim();
        email = email.trim().toLowerCase();

        // Validate email format
        if (!EMAIL_PATTERN.matcher(email).matches()) {
            throw new IllegalArgumentException("Invalid email format.");
        }

        // Validate username format (alphanumeric and underscores, 3-20 chars)
        if (!username.matches("^[a-zA-Z0-9_]{3,20}$")) {
            throw new IllegalArgumentException("Username must be 3-20 characters long and contain only letters, numbers, or underscores.");
        }

        // 2. Check duplicates
        if (userDAO.getUserByUsername(username) != null) {
            throw new Exception("Username is already taken.");
        }
        if (userDAO.getUserByEmail(email) != null) {
            throw new Exception("Email is already registered.");
        }

        // 3. Hash password and save
        String passwordHash = PasswordUtil.hashPassword(password);
        User user = new User(username, email, passwordHash);

        if (userDAO.createUser(user)) {
            return user;
        } else {
            throw new Exception("Registration failed due to a system error. Please try again.");
        }
    }

    /**
     * Authenticates a user trying to log in.
     * @param usernameOrEmail entered username or email address
     * @param password entered plaintext password
     * @return User object if credentials are correct, null otherwise.
     */
    public User authenticateUser(String usernameOrEmail, String password) {
        if (usernameOrEmail == null || usernameOrEmail.trim().isEmpty() || password == null || password.isEmpty()) {
            return null;
        }

        usernameOrEmail = usernameOrEmail.trim();

        // 1. Look up user by username first, and then by email if not found
        User user = userDAO.getUserByUsername(usernameOrEmail);
        if (user == null) {
            user = userDAO.getUserByEmail(usernameOrEmail.toLowerCase());
        }

        // 2. If user exists, verify the password
        if (user != null && PasswordUtil.verifyPassword(password, user.getPasswordHash())) {
            return user;
        }

        return null;
    }
}
