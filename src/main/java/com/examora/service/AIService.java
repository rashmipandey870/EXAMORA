package com.examora.service;

public interface AIService {
    /**
     * Generates revision study notes for a topic within a subject.
     * @param topicName name of the topic
     * @param subjectName name of the subject
     * @return Markdown-formatted revision notes
     */
    String generateNotes(String topicName, String subjectName);

    /**
     * Contextual tutoring helper for practice solver questions.
     * @param questionContext details about the question and solution
     * @param message student query text
     * @return Markdown tutor reply
     */
    String askTutor(String questionContext, String message);
}
