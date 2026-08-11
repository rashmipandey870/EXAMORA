package com.examora.controller;

import com.examora.dao.UserDAO;
import com.examora.model.Exam;
import com.examora.model.User;
import com.examora.service.ExamRecommendationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "OnboardingServlet", urlPatterns = {"/onboarding"})
public class OnboardingServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final ExamRecommendationService recommendationService = new ExamRecommendationService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        User user = (User) session.getAttribute("user");
        request.setAttribute("username", user.getUsername());
        request.setAttribute("user", user);

        request.getRequestDispatcher("onboarding.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login");
            return;
        }

        User user = (User) session.getAttribute("user");

        String background = request.getParameter("background");
        String goal = request.getParameter("goal");
        String targetTimeline = request.getParameter("targetTimeline");

        // Validate options against fixed vocabulary
        if (background == null || background.trim().isEmpty() ||
            goal == null || goal.trim().isEmpty() ||
            targetTimeline == null || targetTimeline.trim().isEmpty()) {
            
            request.setAttribute("error", "Please fill in all onboarding questions.");
            request.getRequestDispatcher("onboarding.jsp").forward(request, response);
            return;
        }

        // Update database profile
        boolean success = userDAO.updateUserProfile(user.getId(), background, goal, targetTimeline);

        if (success) {
            // Update session object
            user.setBackground(background);
            user.setGoal(goal);
            user.setTargetTimeline(targetTimeline);
            session.setAttribute("user", user);

            // Fetch recommendations
            List<Exam> recommendations = recommendationService.getRecommendedExams(background, goal, targetTimeline);

            request.setAttribute("recommendations", recommendations);
            request.setAttribute("username", user.getUsername());
            request.setAttribute("background", background);
            request.setAttribute("goal", goal);
            request.setAttribute("targetTimeline", targetTimeline);

            request.getRequestDispatcher("onboarding_results.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Failed to update your profile. Please try again.");
            request.getRequestDispatcher("onboarding.jsp").forward(request, response);
        }
    }
}
