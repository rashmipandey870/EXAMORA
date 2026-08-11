package com.examora.controller;

import com.examora.model.Exam;
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
import java.util.List;

/**
 * ExamServlet manages examination listings and user selections.
 * 
 * WHAT: Controller (Servlet) mapping to "/exams".
 * WHY: Provides routing to show available exams and set target Focus.
 * HOW: GET checks session, fetches exam lists, and forwards to exams.jsp.
 *      POST updates user focus targets using ExamInformationService.
 * WHERE: Placed in the com.examora.controller package.
 */
@WebServlet(name = "ExamServlet", urlPatterns = {"/exams"})
public class ExamServlet extends HttpServlet {

    private final ExamInformationService examInfoService = new ExamInformationService();

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

        // 2. Fetch available exams and current active target
        List<Exam> availableExams = examInfoService.getAvailableExams();
        Exam activeExam = examInfoService.getActiveExamForUser(user.getId());

        // 3. Set attributes for JSP view rendering
        request.setAttribute("username", user.getUsername());
        request.setAttribute("examsList", availableExams);
        request.setAttribute("activeExam", activeExam);

        request.getRequestDispatcher("exams.jsp").forward(request, response);
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
        String examIdStr = request.getParameter("examId");

        if (examIdStr == null || examIdStr.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"status\":\"ERROR\",\"message\":\"No examination selected.\"}");
            return;
        }

        try {
            int examId = Integer.parseInt(examIdStr);
            
            // 2. Perform selection transaction
            boolean success = examInfoService.selectExamForUser(user.getId(), examId);

            if (success) {
                out.print("{\"status\":\"SUCCESS\",\"message\":\"Target exam configured successfully! Loading syllabus...\"}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"status\":\"ERROR\",\"message\":\"Failed to save target selection. Please try again.\"}");
            }
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"status\":\"ERROR\",\"message\":\"Invalid exam reference.\"}");
        }
    }
}
