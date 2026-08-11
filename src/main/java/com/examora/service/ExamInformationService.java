package com.examora.service;

import com.examora.dao.ExamDAO;
import com.examora.model.Exam;

import java.util.List;

/**
 * ExamInformationService handles business logic related to exams.
 * 
 * WHAT: Service Layer for Exam details.
 * WHY: Decouples controller routes from direct database transactions.
 * HOW: Wraps ExamDAO methods.
 * WHERE: Placed in the com.examora.service package.
 */
public class ExamInformationService {

    private final ExamDAO examDAO = new ExamDAO();

    /**
     * Gets all examinations supported by the system.
     * @return List of Exams
     */
    public List<Exam> getAvailableExams() {
        return examDAO.getAllExams();
    }

    /**
     * Selects an exam for a user, deactivating other selections.
     * @param userId the user ID
     * @param examId the selected exam ID
     * @return true if successful
     */
    public boolean selectExamForUser(int userId, int examId) {
        if (userId <= 0 || examId <= 0) {
            return false;
        }
        return examDAO.selectExamForUser(userId, examId);
    }

    /**
     * Gets the active targeted exam for a user.
     * @param userId the user ID
     * @return active Exam object, or null if none
     */
    public Exam getActiveExamForUser(int userId) {
        if (userId <= 0) {
            return null;
        }
        return examDAO.getActiveExamForUser(userId);
    }
}
