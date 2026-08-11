package com.examora.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * LogoutServlet handles session invalidation.
 * 
 * WHAT: Controller (Servlet) mapping to "/logout".
 * WHY: Discards user session data to sign out the user securely.
 * HOW: Invalidates the HttpSession if active, then redirects back to the login page.
 * WHERE: It belongs in the com.examora.controller package.
 */
@WebServlet(name = "LogoutServlet", urlPatterns = {"/logout"})
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        performLogout(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        performLogout(request, response);
    }

    private void performLogout(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            // Discard all attributes and terminate the session
            session.invalidate();
        }
        // Redirect client to login page
        response.sendRedirect("login");
    }
}
