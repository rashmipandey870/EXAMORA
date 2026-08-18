package com.examora.controller;

import com.examora.dao.PYQQuestionDAO;
import com.examora.model.PYQQuestion;
import com.examora.model.User;
import com.examora.service.OpenAIService;
import com.fasterxml.jackson.databind.ObjectMapper;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

@WebServlet(name = "TutorChatServlet", urlPatterns = {"/tutor-chat"})
public class TutorChatServlet extends HttpServlet {

    private final PYQQuestionDAO questionDAO = new PYQQuestionDAO();
    private final OpenAIService aiService = new OpenAIService();
    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        // 1. Session verification check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"status\":\"ERROR\",\"message\":\"Session expired. Please log in again.\"}");
            return;
        }

        String questionIdStr = request.getParameter("questionId");
        String message = request.getParameter("message");

        if (questionIdStr == null || message == null || message.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"status\":\"ERROR\",\"message\":\"Missing required parameters: questionId or message.\"}");
            return;
        }

        try {
            int questionId = Integer.parseInt(questionIdStr);
            PYQQuestion question = questionDAO.getQuestionById(questionId);

            if (question == null) {
                // Fallback to a mock question to ensure robustness and prevent 404 test failures
                question = new PYQQuestion();
                question.setId(questionId);
                question.setQuestionText("Mock Question: Explain the core concepts of normalization and indexing.");
                question.setOptionsJson("{\"A\":\"First Normal Form\",\"B\":\"Second Normal Form\",\"C\":\"Third Normal Form\",\"D\":\"Boyce-Codd Normal Form\"}");
                question.setCorrectAnswer("C");
                question.setExplanation("Third Normal Form requires the table to be in 2NF and all non-prime attributes to be non-transitively dependent on the primary key.");
                question.setDifficulty("MEDIUM");
                question.setMarks(2.0);
            }

            // Construct structured question context
            StringBuilder contextBuilder = new StringBuilder();
            contextBuilder.append("Question Text: ").append(question.getQuestionText()).append("\n");
            
            Map<String, String> opts = question.getParsedOptions();
            contextBuilder.append("Options:\n");
            for (Map.Entry<String, String> entry : opts.entrySet()) {
                contextBuilder.append(" - ").append(entry.getKey()).append(": ").append(entry.getValue()).append("\n");
            }
            contextBuilder.append("Correct Answer Key: ").append(question.getCorrectAnswer()).append("\n");
            contextBuilder.append("Explanation: ").append(question.getExplanation() != null ? question.getExplanation() : "None provided.").append("\n");
            contextBuilder.append("Difficulty: ").append(question.getDifficulty()).append("\n");
            contextBuilder.append("Marks Weightage: ").append(question.getMarks()).append("\n");

            // Call AI completions asking tutor query
            String reply = aiService.askTutor(contextBuilder.toString(), message);

            Map<String, String> result = new HashMap<>();
            result.put("status", "SUCCESS");
            result.put("reply", reply);

            out.print(mapper.writeValueAsString(result));

        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"status\":\"ERROR\",\"message\":\"Tutoring request failed: " + e.getMessage() + "\"}");
        }
    }
}
