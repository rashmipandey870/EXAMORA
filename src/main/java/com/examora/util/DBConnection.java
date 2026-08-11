package com.examora.util;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * DBConnection is a utility class that manages JDBC database connections to MySQL.
 * 
 * WHAT: It loads database configurations and provides SQL Connection objects.
 * WHY: We need it to centralize database connection logic, avoiding duplication of DB credentials.
 * HOW: It first checks system environment variables (DB_URL, DB_USERNAME, DB_PASSWORD). 
 *      If not found, it falls back to configuration values defined in 'application.properties'.
 * WHERE: It belongs in the com.examora.util package.
 */
public class DBConnection {

    private static String dbUrl;
    private static String dbUsername;
    private static String dbPassword;

    static {
        // 1. Try to load configurations from environment variables first
        dbUrl = System.getenv("DB_URL");
        dbUsername = System.getenv("DB_USERNAME");
        dbPassword = System.getenv("DB_PASSWORD");

        // 2. If environment variables are not set, fall back to application.properties
        if (dbUrl == null || dbUsername == null) {
            Properties properties = new Properties();
            try (InputStream input = DBConnection.class.getClassLoader().getResourceAsStream("application.properties")) {
                if (input != null) {
                    properties.load(input);
                    dbUrl = properties.getProperty("db.url");
                    dbUsername = properties.getProperty("db.username");
                    dbPassword = properties.getProperty("db.password");
                }
            } catch (IOException e) {
                System.err.println("Could not load application.properties: " + e.getMessage());
            }
        }

        // 3. Register the MySQL JDBC driver class explicitly
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.err.println("MySQL JDBC Driver not found in classpath! Make sure mysql-connector-j is in dependencies.");
            e.printStackTrace();
        }
    }

    /**
     * Obtains a Connection to the MySQL database.
     * @return Connection object
     * @throws SQLException if a database access error occurs
     */
    public static Connection getConnection() throws SQLException {
        if (dbUrl == null || dbUsername == null) {
            throw new SQLException("Database URL or credentials not configured. Check environment variables or application.properties.");
        }
        return DriverManager.getConnection(dbUrl, dbUsername, dbPassword);
    }
}
