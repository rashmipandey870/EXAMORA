package com.examora.controller;

import com.examora.model.User;
import com.examora.service.AuthService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

/**
 * RegisterServlet handles student registration requests.
 * 
 * WHAT: Controller (Servlet) mapping to "/register".
 * WHY: Processes user registrations, validates credentials through AuthService, and updates DB.
 * HOW: GET forwards to register.html page. POST validates form inputs, returns a JSON success/error message.
 * WHERE: It belongs in the com.examora.controller package.
 */
@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // If the user is already logged in, redirect to dashboard
        if (request.getSession(false) != null && request.getSession().getAttribute("user") != null) {
            response.sendRedirect("dashboard");
            return;
        }
        // Forward to the static registration HTML page
        request.getRequestDispatcher("register.html").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // 1. Basic matching check
        if (password != null && !password.equals(confirmPassword)) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"status\":\"ERROR\",\"message\":\"Passwords do not match.\"}");
            return;
        }

        try {
            // 2. Validate and create user
            User user = authService.registerUser(username, email, password);
            
            // 3. Auto-login on successful registration
            request.getSession(true).setAttribute("user", user);

            out.print("{\"status\":\"SUCCESS\",\"message\":\"Registration successful! Redirecting...\"}");
        } catch (IllegalArgumentException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"status\":\"ERROR\",\"message\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_CONFLICT);
            out.print("{\"status\":\"ERROR\",\"message\":\"" + e.getMessage().replace("\"", "\\\"") + "\"}");
        }
    }
}
