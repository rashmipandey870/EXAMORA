package com.examora.controller;

import com.examora.dao.NotesDAO;
import com.examora.model.User;
import com.examora.service.OpenAIService;
import com.examora.util.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet(name = "NotesServlet", urlPatterns = {"/notes"})
public class NotesServlet extends HttpServlet {

    private final NotesDAO notesDAO = new NotesDAO();
    private final OpenAIService openAIService = new OpenAIService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        User user = (User) session.getAttribute("user");

        String topicIdStr = request.getParameter("topicId");
        if (topicIdStr == null || topicIdStr.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing topic identifier.");
            return;
        }

        int topicId;
        try {
            topicId = Integer.parseInt(topicIdStr);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Malformed topic identifier.");
            return;
        }

        // 1. Fetch topic meta details
        String topicName = "";
        String subjectName = "";
        String metaSql = "SELECT t.name, s.name AS subject_name FROM topics t JOIN subjects s ON t.subject_id = s.id WHERE t.id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(metaSql)) {
            stmt.setInt(1, topicId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    topicName = rs.getString("name");
                    subjectName = rs.getString("subject_name");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        if (topicName.isEmpty()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Syllabus topic not found.");
            return;
        }

        // 2. Query cache for notes
        String notesContent = notesDAO.getCachedNotes(topicId);
        String noteSource = "CACHED";
        boolean rateLimited = false;

        if (notesContent == null) {
            // 3. Rate limit precheck: check user request count in last 24h
            int dailyRequests = notesDAO.getAIRequestsCountInLast24Hours(user.getId());
            
            if (dailyRequests >= 15) {
                // Rate limited: Fallback to mock notes
                rateLimited = true;
                noteSource = "LOCAL_MOCK";
                notesContent = generateMockNotesForTopic(topicName, subjectName);
            } else {
                // Perform Live/Fallback notes generation
                notesContent = openAIService.generateNotes(topicName, subjectName);
                
                if (openAIService.isLive()) {
                    noteSource = "LIVE_AI";
                    // Log details to ai_requests table
                    String prompt = "Topic: " + topicName + ", Subject: " + subjectName;
                    notesDAO.logAIRequest(user.getId(), prompt, notesContent);
                } else {
                    noteSource = "LOCAL_MOCK";
                }
                
                // Cache notes in DB for future requests
                notesDAO.cacheNotes(topicId, notesContent);
            }
        }

        request.setAttribute("topicName", topicName);
        request.setAttribute("subjectName", subjectName);
        request.setAttribute("notesContent", notesContent);
        request.setAttribute("noteSource", noteSource);
        request.setAttribute("rateLimited", rateLimited);

        request.getRequestDispatcher("notes.jsp").forward(request, response);
    }

    private String generateMockNotesForTopic(String topicName, String subjectName) {
        StringBuilder sb = new StringBuilder();
        sb.append("# ").append(topicName).append(" — Key Revision Notes\n\n");
        sb.append("## Category: ").append(subjectName).append("\n\n");
        sb.append("### 1. Concept Overview\n");
        sb.append("This unit covers critical aspects of **").append(topicName).append("**. Understanding the core properties is vital for solving exam problems efficiently.\n\n");
        sb.append("### 2. Standard Mathematical Models / Rules\n");
        sb.append("- **Rule 1:** Ensure all operations satisfy the structural integrity constraints.\n");
        sb.append("- **Rule 2:** Always evaluate the dependencies sequentially.\n");
        sb.append("$$\\text{Efficiency} = \\frac{\\text{Weightage}}{\\text{Preparation Hours}} \\times 100\\%$$\n\n");
        sb.append("### 3. Core Formulas & Shortcuts\n");
        sb.append("1. **Time Complexity:** $O(\\log N)$ for optimized traversal operations.\n");
        sb.append("2. **Verification Equation:**\n");
        sb.append("$$\\sum_{i=1}^{n} X_i = \\text{Normalized Sum}$$\n\n");
        sb.append("### 4. High-Yield Summary\n");
        sb.append("> **Note:** Historical exams consistently focus on edge cases. Review previous years' questions carefully.");
        return sb.toString();
    }
}
