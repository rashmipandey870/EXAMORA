package com.examora.controller;

import com.examora.dao.PYQStagingDAO;
import com.examora.dao.TopicDAO;
import com.examora.model.PYQStaging;
import com.examora.model.User;
import com.examora.service.IngestionService;
import com.fasterxml.jackson.databind.ObjectMapper;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "AdminIngestServlet", urlPatterns = {"/admin/pyq-ingest"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class AdminIngestServlet extends HttpServlet {

    private final PYQStagingDAO stagingDAO = new PYQStagingDAO();
    private final IngestionService IngestService = new IngestionService();
    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Access Control Gate: Admins only
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect(request.getContextPath() + "/login?message=Please+log+in+first");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (!"admin".equals(user.getUsername()) && !"rashmi_test".equals(user.getUsername())) {
            response.sendRedirect(request.getContextPath() + "/login?message=Access+Denied:+Please+log+in+as+an+administrator.");
            return;
        }

        List<PYQStaging> pendingList = stagingDAO.getPendingStagingQuestions();
        List<com.examora.model.Topic> topicsList = new TopicDAO().getTopicsBySubjectId(1, 1); // Default to DBMS for Exam 1

        request.setAttribute("username", user.getUsername());
        request.setAttribute("pendingList", pendingList);
        request.setAttribute("topicsList", topicsList);

        request.getRequestDispatcher("/admin/pyq_ingest.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        User user = (User) session.getAttribute("user");
        if (!"admin".equals(user.getUsername()) && !"rashmi_test".equals(user.getUsername())) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = request.getParameter("action");
        if ("upload".equalsIgnoreCase(action)) {
            handleUpload(request, response);
        } else {
            handleReviewAction(request, response);
        }
    }

    private void handleUpload(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        try {
            int examId = Integer.parseInt(request.getParameter("examId"));
            int subjectId = Integer.parseInt(request.getParameter("subjectId"));
            int year = Integer.parseInt(request.getParameter("year"));
            String sourceUrl = request.getParameter("sourceUrl");
            Part filePart = request.getPart("pdfFile");

            if (filePart == null || filePart.getSize() == 0) {
                response.sendRedirect(request.getContextPath() + "/admin/pyq-ingest?error=No file chosen.");
                return;
            }

            String filename = filePart.getSubmittedFileName();
            byte[] fileBytes;
            try (InputStream is = filePart.getInputStream();
                 ByteArrayOutputStream os = new ByteArrayOutputStream()) {
                byte[] buffer = new byte[4096];
                int len;
                while ((len = is.read(buffer)) != -1) {
                    os.write(buffer, 0, len);
                }
                fileBytes = os.toByteArray();
            }

            List<PYQStaging> stagingQuestions = IngestService.parsePdfToStaging(fileBytes, filename, sourceUrl, examId, subjectId, year);
            int successCount = 0;
            for (PYQStaging q : stagingQuestions) {
                if (stagingDAO.saveStagingQuestion(q)) {
                    successCount++;
                }
            }

            response.sendRedirect(request.getContextPath() + "/admin/pyq-ingest?success=Successfully parsed PDF. Ingested " + successCount + " items for review.");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/pyq-ingest?error=Failed to ingest: " + e.getMessage());
        }
    }

    private void handleReviewAction(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String action = request.getParameter("action");
        String stagingIdStr = request.getParameter("stagingId");

        if (stagingIdStr == null || stagingIdStr.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"status\":\"ERROR\",\"message\":\"Missing stagingId.\"}");
            return;
        }

        try {
            int stagingId = Integer.parseInt(stagingIdStr);

            if ("approve".equalsIgnoreCase(action)) {
                boolean promoted = stagingDAO.promoteToLive(stagingId);
                if (promoted) {
                    out.print("{\"status\":\"SUCCESS\",\"message\":\"Question successfully promoted to live database!\"}");
                } else {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.print("{\"status\":\"ERROR\",\"message\":\"Promotion failed.\"}");
                }
            } else if ("reject".equalsIgnoreCase(action)) {
                boolean updated = stagingDAO.updateStagingStatus(stagingId, "REJECTED");
                if (updated) {
                    out.print("{\"status\":\"SUCCESS\",\"message\":\"Question rejected and discarded from review.\"}{}");
                } else {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.print("{\"status\":\"ERROR\",\"message\":\"Rejection action failed.\"}");
                }
            } else if ("edit".equalsIgnoreCase(action)) {
                PYQStaging q = stagingDAO.getStagingQuestionById(stagingId);
                if (q == null) {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    out.print("{\"status\":\"ERROR\",\"message\":\"Question not found.\"}");
                    return;
                }

                q.setYear(Integer.parseInt(request.getParameter("year")));
                q.setExtractedQuestionText(request.getParameter("questionText"));
                q.setExtractedCorrectAnswer(request.getParameter("correctAnswer"));
                q.setExtractedExplanation(request.getParameter("explanation"));
                q.setSuggestedTopicId(Integer.parseInt(request.getParameter("topicId")));
                q.setSuggestedDifficulty(request.getParameter("difficulty"));

                // Build options JSON
                Map<String, String> opts = new HashMap<>();
                opts.put("A", request.getParameter("optionA"));
                opts.put("B", request.getParameter("optionB"));
                opts.put("C", request.getParameter("optionC"));
                opts.put("D", request.getParameter("optionD"));
                q.setExtractedOptionsJson(mapper.writeValueAsString(opts));

                boolean updated = stagingDAO.updateStagingQuestion(q);
                boolean promoted = stagingDAO.promoteToLive(stagingId);

                if (updated && promoted) {
                    out.print("{\"status\":\"SUCCESS\",\"message\":\"Edited and successfully promoted to live!\"}");
                } else {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.print("{\"status\":\"ERROR\",\"message\":\"Edit and promotion failed.\"}");
                }
            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"status\":\"ERROR\",\"message\":\"Unknown review action.\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"status\":\"ERROR\",\"message\":\"Review action failed: " + e.getMessage() + "\"}");
        }
    }
}
