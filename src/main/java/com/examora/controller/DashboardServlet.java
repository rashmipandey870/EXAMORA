package com.examora.controller;

import com.examora.dao.StudyPlanDAO;
import com.examora.dao.StudyTaskDAO;
import com.examora.model.Exam;
import com.examora.model.StudyPlan;
import com.examora.model.StudyTask;
import com.examora.model.User;
import com.examora.service.ExamInformationService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Map;

/**
 * DashboardServlet routes user to the main workspace.
 * 
 * WHAT: Controller (Servlet) mapping to "/dashboard".
 * WHY: Gathers real-time timeline analytics, weak areas, and schedules.
 * HOW: GET maps data variables to dashboard.jsp; POST toggles task completion state dynamically.
 * WHERE: Placed in the com.examora.controller package.
 */
@WebServlet(name = "DashboardServlet", urlPatterns = {"/dashboard"})
public class DashboardServlet extends HttpServlet {

    private final ExamInformationService examInfoService = new ExamInformationService();
    private final StudyPlanDAO studyPlanDAO = new StudyPlanDAO();
    private final StudyTaskDAO studyTaskDAO = new StudyTaskDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Session check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        User user = (User) session.getAttribute("user");

        // 2. Profile completion and exam target checks
        if (user.getBackground() == null || user.getBackground().trim().isEmpty()) {
            response.sendRedirect("onboarding");
            return;
        }

        Exam activeExam = examInfoService.getActiveExamForUser(user.getId());
        if (activeExam == null) {
            response.sendRedirect("exams?selectFirst=true");
            return;
        }

        // 3. Fetch study plan
        StudyPlan activePlan = studyPlanDAO.getActiveStudyPlan(user.getId());

        if (activePlan != null) {
            request.setAttribute("hasActivePlan", true);
            request.setAttribute("activePlan", activePlan);

            // Fetch schedule details for today
            List<StudyTask> todayTasks = studyTaskDAO.getTasksForDate(activePlan.getId(), LocalDate.now());
            request.setAttribute("todayTasks", todayTasks);

            // Fetch progress metrics mapping
            Map<String, Object> metrics = studyTaskDAO.getTaskCompletionMetrics(activePlan.getId());
            request.setAttribute("metrics", metrics);

            // Fetch new dashboard indicators
            double weightedSyllabusCompletion = studyTaskDAO.getWeightedSyllabusCompletionPercentage(activePlan.getId());
            double pyqAttemptsRatio = studyTaskDAO.getPYQYearAttemptsRatio(user.getId(), activeExam.getId());
            int revisionDueCount = studyTaskDAO.getRevisionDueCount(activePlan.getId());

            request.setAttribute("weightedSyllabusCompletion", weightedSyllabusCompletion);
            request.setAttribute("pyqAttemptsRatio", pyqAttemptsRatio);
            request.setAttribute("revisionDueCount", revisionDueCount);

            // Fetch highest importance pending topics
            List<StudyTask> weakTopics = studyTaskDAO.getHighestPriorityPendingTopics(activePlan.getId(), activeExam.getId(), 3);
            request.setAttribute("weakTopics", weakTopics);

            // Fetch actual weak topics based on student answer attempts accuracy
            List<java.util.Map<String, Object>> weakestTopics = new com.examora.dao.PYQAttemptDAO().getWeakestTopicsForUser(user.getId(), 3);
            request.setAttribute("weakestTopics", weakestTopics);

            // Calculate streaks and bind
            Map<String, Integer> streaks = studyTaskDAO.calculateStreaks(user.getId());
            request.setAttribute("streaks", streaks);

            // Fetch weekly performance metrics for Chart.js
            List<Map<String, Object>> weeklyMetrics = studyTaskDAO.getWeeklyPerformanceMetrics(activePlan.getId());
            request.setAttribute("weeklyMetrics", weeklyMetrics);

            // Calculate countdown days remaining
            long daysRemaining = ChronoUnit.DAYS.between(LocalDate.now(), activePlan.getEndDate());
            request.setAttribute("daysRemaining", Math.max(0, daysRemaining));
        } else {
            request.setAttribute("hasActivePlan", false);
            // Even if no plan exists, calculate general exam countdown
            long daysRemaining = ChronoUnit.DAYS.between(LocalDate.now(), activeExam.getExamDate());
            request.setAttribute("daysRemaining", Math.max(0, daysRemaining));
        }

        // Fetch exam deadlines timeline & bind
        List<com.examora.model.DeadlineEvent> deadlineEvents = new com.examora.dao.DeadlineEventDAO().getDeadlineEventsForExam(activeExam.getId());
        request.setAttribute("deadlineEvents", deadlineEvents);

        request.setAttribute("activeExam", activeExam);
        request.setAttribute("username", user.getUsername());

        // Forward to the JSP view
        request.getRequestDispatcher("dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        // 1. Authenticate session
        HttpSession session = request.getSession(false);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"status\":\"ERROR\",\"message\":\"Session expired. Please log in.\"}");
            return;
        }

        // 2. Extract toggling parameters
        String taskIdStr = request.getParameter("taskId");
        String action = request.getParameter("action"); // "complete" or "pending"

        if (taskIdStr == null || action == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"status\":\"ERROR\",\"message\":\"Missing task toggling parameter actions.\"}");
            return;
        }

        try {
            int taskId = Integer.parseInt(taskIdStr);
            String dbStatus = "complete".equalsIgnoreCase(action) ? "COMPLETED" : "PENDING";

            // Update status dynamically in the database
            boolean success = studyTaskDAO.updateTaskStatus(taskId, dbStatus);

            if (success) {
                out.print("{\"status\":\"SUCCESS\",\"message\":\"Task status logged successfully.\"}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"status\":\"ERROR\",\"message\":\"Failed to update study task in the database.\"}");
            }

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"status\":\"ERROR\",\"message\":\"Malformed task identifier.\"}");
        }
    }
}
