package com.examora.controller;

import com.examora.dao.StudyPlanDAO;
import com.examora.dao.StudyTaskDAO;
import com.examora.model.Exam;
import com.examora.model.StudyPlan;
import com.examora.model.StudyTask;
import com.examora.model.Subject;
import com.examora.model.User;
import com.examora.service.ExamInformationService;
import com.examora.service.PlannerService;
import com.examora.service.SyllabusService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

/**
 * PlannerServlet manages study plan configurations and task schedules.
 * 
 * WHAT: Controller (Servlet) mapping to "/planner".
 * WHY: Provides setup wizard routing and displays chronological study timelines.
 * HOW: GET checks session focus, queries plans, and forwards to planner.jsp.
 *      POST validates availability targets and generates plans via PlannerService.
 * WHERE: Placed in the com.examora.controller package.
 */
@WebServlet(name = "PlannerServlet", urlPatterns = {"/planner"})
public class PlannerServlet extends HttpServlet {

    private final ExamInformationService examInfoService = new ExamInformationService();
    private final SyllabusService syllabusService = new SyllabusService();
    private final StudyPlanDAO studyPlanDAO = new StudyPlanDAO();
    private final StudyTaskDAO studyTaskDAO = new StudyTaskDAO();
    private final PlannerService plannerService = new PlannerService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        // 1. Session and Authentication check
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        User user = (User) session.getAttribute("user");

        // 2. Fetch the student's active focus exam target
        Exam activeExam = examInfoService.getActiveExamForUser(user.getId());
        if (activeExam == null) {
            response.sendRedirect("exams?selectFirst=true");
            return;
        }

        // 3. Check if the user has an active StudyPlan
        String regen = request.getParameter("regenerate");
        StudyPlan activePlan = null;
        if (!"true".equalsIgnoreCase(regen)) {
            activePlan = studyPlanDAO.getActiveStudyPlan(user.getId());
        }

        if (activePlan != null) {
            // User has an active plan; load chronological scheduled tasks for display
            List<StudyTask> tasks = studyTaskDAO.getTasksForPlan(activePlan.getId());
            request.setAttribute("activePlan", activePlan);
            request.setAttribute("tasksList", tasks);
        } else {
            // No active plan; load complete syllabus to configure scope checkboxes
            List<Subject> syllabus = syllabusService.getSyllabusForExam(activeExam.getId());
            request.setAttribute("syllabus", syllabus);
        }

        request.setAttribute("activeExam", activeExam);
        request.setAttribute("username", user.getUsername());
        
        request.getRequestDispatcher("planner.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        // 1. Session and Authentication check
        HttpSession session = request.getSession(false);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"status\":\"ERROR\",\"message\":\"Session expired. Please log in again.\"}");
            return;
        }

        User user = (User) session.getAttribute("user");

        // Check for Reset action parameter
        String action = request.getParameter("action");
        if ("RESET".equalsIgnoreCase(action)) {
            studyPlanDAO.deactivateActivePlans(user.getId());
            out.print("{\"status\":\"SUCCESS\",\"message\":\"Plan archived successfully.\"}");
            return;
        }

        // 2. Extract parameters from POST request
        String examIdStr = request.getParameter("examId");
        String startDateStr = request.getParameter("startDate");
        String endDateStr = request.getParameter("endDate");
        String dailyHoursStr = request.getParameter("dailyHours");
        String[] preferredDaysArray = request.getParameterValues("preferredDays");
        String[] selectedTopicsArray = request.getParameterValues("selectedTopics");

        // 3. Input Validation
        if (startDateStr == null || endDateStr == null || dailyHoursStr == null || examIdStr == null) {
            out.print("{\"status\":\"ERROR\",\"message\":\"Missing mandatory planning parameters.\"}");
            return;
        }

        if (selectedTopicsArray == null || selectedTopicsArray.length == 0) {
            out.print("{\"status\":\"ERROR\",\"message\":\"Please select at least one syllabus topic to plan your study.\"}");
            return;
        }

        try {
            int examId = Integer.parseInt(examIdStr);
            double dailyHours = Double.parseDouble(dailyHoursStr);
            LocalDate startDate = LocalDate.parse(startDateStr);
            LocalDate endDate = LocalDate.parse(endDateStr);

            if (dailyHours <= 0 || dailyHours > 24) {
                out.print("{\"status\":\"ERROR\",\"message\":\"Daily study availability must be between 1 and 24 hours.\"}");
                return;
            }

            if (startDate.isAfter(endDate)) {
                out.print("{\"status\":\"ERROR\",\"message\":\"Start date cannot be after target exam date.\"}");
                return;
            }

            // Standardize preferred days parameter
            String preferredDaysStr = "Mon,Tue,Wed,Thu,Fri,Sat,Sun"; // default fallback
            if (preferredDaysArray != null && preferredDaysArray.length > 0) {
                preferredDaysStr = String.join(",", preferredDaysArray);
            }

            // Convert selected topics array to integer list
            List<Integer> selectedTopicIds = new ArrayList<>();
            for (String topicIdStr : selectedTopicsArray) {
                selectedTopicIds.add(Integer.parseInt(topicIdStr));
            }

            // Extract and validate study splits ratios
            String learnPctStr = request.getParameter("learnPct");
            String practicePctStr = request.getParameter("practicePct");
            String revisionPctStr = request.getParameter("revisionPct");

            int learnPct = 50;
            int practicePct = 30;
            int revisionPct = 20;

            try {
                if (learnPctStr != null && practicePctStr != null && revisionPctStr != null) {
                    int l = Integer.parseInt(learnPctStr);
                    int p = Integer.parseInt(practicePctStr);
                    int r = Integer.parseInt(revisionPctStr);
                    if (l + p + r == 100) {
                        learnPct = l;
                        practicePct = p;
                        revisionPct = r;
                    }
                }
            } catch (NumberFormatException ignored) {}

            // Extract and validate student milestones set targets
            String targetSyllabusDateStr = request.getParameter("targetSyllabusDate");
            String targetPyqDateStr = request.getParameter("targetPyqDate");
            String revisionBufferDaysStr = request.getParameter("revisionBufferDays");

            int revisionBufferDays = 14;
            if (revisionBufferDaysStr != null && !revisionBufferDaysStr.trim().isEmpty()) {
                try {
                    revisionBufferDays = Integer.parseInt(revisionBufferDaysStr);
                } catch (NumberFormatException ignored) {}
            }

            LocalDate targetSyllabusDate = null;
            LocalDate targetPyqDate = null;
            long totalStudyDays = ChronoUnit.DAYS.between(startDate, endDate) + 1;

            if (targetPyqDateStr == null || targetPyqDateStr.trim().isEmpty()) {
                targetPyqDate = endDate.minusDays(revisionBufferDays);
            } else {
                targetPyqDate = LocalDate.parse(targetPyqDateStr);
            }

            if (targetSyllabusDateStr == null || targetSyllabusDateStr.trim().isEmpty()) {
                targetSyllabusDate = startDate.plusDays(totalStudyDays / 2);
                if (!targetSyllabusDate.isBefore(targetPyqDate)) {
                    targetSyllabusDate = startDate.plusDays(totalStudyDays / 3);
                }
            } else {
                targetSyllabusDate = LocalDate.parse(targetSyllabusDateStr);
            }

            // Chronological timeline order constraint check
            if (!startDate.isBefore(targetSyllabusDate) || !targetSyllabusDate.isBefore(targetPyqDate) || targetPyqDate.isAfter(endDate.minusDays(revisionBufferDays))) {
                out.print("{\"status\":\"ERROR\",\"message\":\"Chronological Validation Failed: Milestones must satisfy: Start Date (" + startDate + ") < Syllabus Completion Target (" + targetSyllabusDate + ") < PYQ Completion Target (" + targetPyqDate + ") <= Exam Target date minus Revision Buffer (" + endDate.minusDays(revisionBufferDays) + "). Please adjust dates accordingly.\"}");
                out.flush();
                return;
            }



            // 4. Invoke Planner Service to execute greedy distribution
            boolean success = plannerService.generateAndSavePlan(
                    user.getId(), examId, startDate, endDate, dailyHours, preferredDaysStr, selectedTopicIds,
                    targetSyllabusDate, targetPyqDate, revisionBufferDays, learnPct, practicePct, revisionPct
            );

            if (success) {
                out.print("{\"status\":\"SUCCESS\",\"message\":\"Strategy generated! Dynamic Study Calendar is ready.\"}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"status\":\"ERROR\",\"message\":\"Failed to generate study plan. Please ensure target timeframe has enough study days.\"}");
            }

        } catch (NumberFormatException | DateTimeParseException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"status\":\"ERROR\",\"message\":\"Malformed date or hour numeric values.\"}");
        }
    }

    private int calculateAvailableStudyHours(LocalDate start, LocalDate end, double dailyHours, String preferredDays) {
        int days = 0;
        java.util.List<String> prefList = java.util.Arrays.asList(preferredDays.split(","));
        
        LocalDate curr = start;
        while (!curr.isAfter(end)) {
            String dayAbbrev = curr.getDayOfWeek().getDisplayName(java.time.format.TextStyle.SHORT, java.util.Locale.US);
            if (prefList.contains(dayAbbrev)) {
                days++;
            }
            curr = curr.plusDays(1);
        }
        return (int) (days * dailyHours);
    }
}
