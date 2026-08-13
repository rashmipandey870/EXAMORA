package com.examora.controller;

import com.examora.dao.PYQQuestionDAO;
import com.examora.model.Exam;
import com.examora.model.PYQQuestion;
import com.examora.model.User;
import com.examora.service.ExamInformationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "PracticeServlet", urlPatterns = {"/practice"})
public class PracticeServlet extends HttpServlet {

    private final ExamInformationService examInfoService = new ExamInformationService();
    private final PYQQuestionDAO pyqDAO = new PYQQuestionDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        User user = (User) session.getAttribute("user");
        Exam activeExam = examInfoService.getActiveExamForUser(user.getId());

        if (activeExam == null) {
            response.sendRedirect("exams?selectFirst=true");
            return;
        }

        List<PYQQuestion> questions = pyqDAO.getQuestionsForExam(activeExam.getId());
        List<com.examora.model.PYQCoverage> coverageList = new com.examora.dao.PYQCoverageDAO().getCoverageForSubject(activeExam.getId(), 1);
        Map<String, Integer> coverageStats = new com.examora.dao.PYQCoverageDAO().getSummaryStats(activeExam.getId());
        List<com.examora.model.PYQAttempt> userAttempts = new com.examora.dao.PYQAttemptDAO().getAttemptsForUser(user.getId());
        List<Integer> bookmarkedIds = new com.examora.dao.PYQAttemptDAO().getBookmarkedQuestionIds(user.getId());

        request.setAttribute("username", user.getUsername());
        request.setAttribute("activeExam", activeExam);
        request.setAttribute("questions", questions);
        request.setAttribute("coverageList", coverageList);
        request.setAttribute("coverageStats", coverageStats);
        request.setAttribute("userAttempts", userAttempts);
        request.setAttribute("bookmarkedIds", bookmarkedIds);

        request.getRequestDispatcher("practice.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        java.io.PrintWriter out = response.getWriter();

        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"status\":\"ERROR\",\"message\":\"Session expired. Please log in again.\"}");
            return;
        }

        User user = (User) session.getAttribute("user");
        String action = request.getParameter("action");
        String questionIdStr = request.getParameter("questionId");
        String selectedOption = request.getParameter("selectedOption");

        if (questionIdStr == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"status\":\"ERROR\",\"message\":\"Missing questionId.\"}");
            return;
        }

        try {
            int questionId = Integer.parseInt(questionIdStr);

            if ("bookmark".equalsIgnoreCase(action)) {
                boolean success = new com.examora.dao.PYQAttemptDAO().toggleBookmark(user.getId(), questionId);
                if (success) {
                    out.print("{\"status\":\"SUCCESS\",\"message\":\"Bookmark toggled successfully.\"}");
                } else {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.print("{\"status\":\"ERROR\",\"message\":\"Failed to toggle bookmark.\"}");
                }
                return;
            }

            if (selectedOption == null) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"status\":\"ERROR\",\"message\":\"Missing selectedOption.\"}");
                return;
            }
            PYQQuestion question = pyqDAO.getQuestionById(questionId);

            if (question == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                out.print("{\"status\":\"ERROR\",\"message\":\"Question not found.\"}");
                return;
            }

            boolean isCorrect = selectedOption.trim().equalsIgnoreCase(question.getCorrectAnswer().trim());

            com.examora.model.PYQAttempt attempt = new com.examora.model.PYQAttempt();
            attempt.setUserId(user.getId());
            attempt.setQuestionId(questionId);
            attempt.setSelectedOption(selectedOption);
            attempt.setCorrect(isCorrect);

            boolean saved = new com.examora.dao.PYQAttemptDAO().saveAttempt(attempt);

            if (saved) {
                out.print("{\"status\":\"SUCCESS\",\"isCorrect\":" + isCorrect + 
                          ",\"correctAnswer\":\"" + question.getCorrectAnswer() + "\"" +
                          ",\"explanation\":\"" + (question.getExplanation() != null ? question.getExplanation().replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "") : "") + "\"}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"status\":\"ERROR\",\"message\":\"Failed to save answer attempt.\"}");
            }

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"status\":\"ERROR\",\"message\":\"Invalid question identifier format.\"}");
        }
    }
}
