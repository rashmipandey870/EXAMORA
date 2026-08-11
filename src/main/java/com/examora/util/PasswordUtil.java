package com.examora.util;

import org.mindrot.jbcrypt.BCrypt;

/**
 * PasswordUtil provides secure password hashing and verification.
 * 
 * WHAT: Helper class that handles security actions for passwords.
 * WHY: Storing plaintext passwords in a database is a major security vulnerability. 
 *      If the database is leaked, user accounts are compromised. We hash passwords so they are unreadable.
 * HOW: Uses the BCrypt hashing algorithm, which automatically handles salting and is designed to resist brute-force attacks.
 * WHERE: It belongs in the com.examora.util package.
 */
public class PasswordUtil {

    // Define the workload factor (higher is more secure, but slower)
    private static final int WORKLOAD = 12;

    /**
     * Hashes a plaintext password using BCrypt.
     * @param plaintextPassword the clear text password
     * @return a hashed password string
     */
    public static String hashPassword(String plaintextPassword) {
        if (plaintextPassword == null || plaintextPassword.isEmpty()) {
            throw new IllegalArgumentException("Password cannot be empty");
        }
        String salt = BCrypt.gensalt(WORKLOAD);
        return BCrypt.hashpw(plaintextPassword, salt);
    }

    /**
     * Verifies a plaintext password against a stored BCrypt hash.
     * @param plaintextPassword the password to test
     * @param hashedPassword the stored BCrypt hash
     * @return true if the passwords match, false otherwise
     */
    public static boolean verifyPassword(String plaintextPassword, String hashedPassword) {
        if (plaintextPassword == null || hashedPassword == null) {
            return false;
        }
        try {
            return BCrypt.checkpw(plaintextPassword, hashedPassword);
        } catch (IllegalArgumentException e) {
            // Catches cases where hashedPassword is not a valid BCrypt hash
            return false;
        }
    }
}
