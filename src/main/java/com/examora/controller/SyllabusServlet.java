package com.examora.controller;

import com.examora.model.Exam;
import com.examora.model.Subject;
import com.examora.model.User;
import com.examora.service.ExamInformationService;
import com.examora.service.SyllabusService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * SyllabusServlet manages rendering the structured syllabus tree.
 * 
 * WHAT: Controller (Servlet) mapping to "/syllabus".
 * WHY: Feeds the syllabus explorer view with active subjects, topics, and trend provenance.
 * HOW: GET checks session, verifies user has chosen an active exam, fetches syllabus tree,
 *      and forwards to syllabus.jsp.
 * WHERE: Placed in the com.examora.controller package.
 */
@WebServlet(name = "SyllabusServlet", urlPatterns = {"/syllabus"})
public class SyllabusServlet extends HttpServlet {

    private final ExamInformationService examInfoService = new ExamInformationService();
    private final SyllabusService syllabusService = new SyllabusService();

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

        // 2. Fetch the student's active exam target
        Exam activeExam = examInfoService.getActiveExamForUser(user.getId());

        // UX Safeguard: If the student hasn't selected an exam yet, force selection first
        if (activeExam == null) {
            response.sendRedirect("exams?selectFirst=true");
            return;
        }

        // 3. Compile the subject-topic syllabus hierarchy for this exam
        List<Subject> syllabus = syllabusService.getSyllabusForExam(activeExam.getId());
        List<com.examora.model.Topic> highYieldTopics = syllabusService.getHighYieldTopicsForExam(activeExam.getId());

        // 4. Set parameters and forward to the JSP UI
        request.setAttribute("username", user.getUsername());
        request.setAttribute("activeExam", activeExam);
        request.setAttribute("syllabus", syllabus);
        request.setAttribute("highYieldTopics", highYieldTopics);

        request.getRequestDispatcher("syllabus.jsp").forward(request, response);
    }
}
