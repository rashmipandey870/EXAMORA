package com.examora.controller;

import com.examora.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * TestDatabaseServlet verifies JDBC connectivity to the MySQL database.
 * 
 * WHAT: It is a Controller (Servlet) that handles HTTP GET requests to "/test-db".
 * WHY: We need it to verify that our web server can communicate with the database and retrieve data.
 * HOW: It requests a connection from DBConnection, runs a query on the "exams" table,
 *      formats the retrieved data as JSON, and sends it back to the client.
 * WHERE: It belongs in the com.examora.controller package and is mapped to "/test-db".
 */
@WebServlet(name = "TestDatabaseServlet", urlPatterns = {"/test-db"})
public class TestDatabaseServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        
        // Use try-with-resources to ensure connection and statement are closed automatically
        String sql = "SELECT name, exam_year, exam_date FROM exams";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            List<String> examsList = new ArrayList<>();
            while (rs.next()) {
                String examName = rs.getString("name");
                int year = rs.getInt("exam_year");
                String date = rs.getString("exam_date");
                examsList.add(String.format("{\"name\":\"%s\",\"year\":%d,\"date\":\"%s\"}", examName, year, date));
            }
            
            // Build simple JSON response
            out.print("{");
            out.print("\"status\":\"SUCCESS\",");
            out.print("\"message\":\"Java -> JDBC -> MySQL -> Tomcat connection is working successfully!\",");
            out.print("\"database\":\"examora\",");
            out.print("\"seededExams\":" + examsList.toString());
            out.print("}");
            
        } catch (SQLException e) {
            // Set error code 500 (Internal Server Error)
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            
            // Output a friendly JSON error instead of dumping the stack trace directly to the client
            out.print("{");
            out.print("\"status\":\"ERROR\",");
            out.print("\"message\":\"Failed to connect to the database. Please verify your credentials and make sure MySQL is running.\",");
            out.print("\"errorDetails\":\"" + e.getMessage().replace("\"", "\\\"") + "\"");
            out.print("}");
            
            // Still log the stack trace in the server console for debugging
            e.printStackTrace();
        }
    }
}
