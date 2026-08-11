package com.examora.controller;

import com.examora.model.User;
import com.examora.service.AuthService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;

/**
 * LoginServlet manages user login validation and session initiation.
 * 
 * WHAT: Controller (Servlet) mapping to "/login".
 * WHY: Checks credentials against the database and creates an authenticated session.
 * HOW: GET renders login.html. POST validates login via AuthService and creates HttpSession.
 * WHERE: It belongs in the com.examora.controller package.
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // If already logged in, redirect to dashboard
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            response.sendRedirect("dashboard");
            return;
        }
        
        request.getRequestDispatcher("login.html").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String usernameOrEmail = request.getParameter("usernameOrEmail");
        String password = request.getParameter("password");

        // 1. Simple empty fields check
        if (usernameOrEmail == null || usernameOrEmail.trim().isEmpty() || password == null || password.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"status\":\"ERROR\",\"message\":\"Please enter both credentials.\"}");
            return;
        }

        // 2. Authenticate against database
        User authenticatedUser = authService.authenticateUser(usernameOrEmail, password);

        if (authenticatedUser != null) {
            // 3. Create Session, configure parameters, bind user
            HttpSession session = request.getSession(true);
            session.setAttribute("user", authenticatedUser);
            
            out.print("{\"status\":\"SUCCESS\",\"message\":\"Login successful! Redirecting to dashboard...\"}");
        } else {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"status\":\"ERROR\",\"message\":\"Invalid username/email or password.\"}");
        }
    }
}
