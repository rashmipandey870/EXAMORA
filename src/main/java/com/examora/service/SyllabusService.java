package com.examora.service;

import com.examora.dao.SubjectDAO;
import com.examora.dao.TopicDAO;
import com.examora.dao.UnitDAO;
import com.examora.model.Subject;
import com.examora.model.Topic;

import java.util.List;

/**
 * SyllabusService compiles and manages hierarchical syllabus components.
 * 
 * WHAT: Service Layer that aggregates subjects and topics under a focused exam.
 * WHY: Decouples progress tracking from raw structural database loads.
 * HOW: Calls SubjectDAO to fetch subjects, then populates child topics for each subject.
 * WHERE: Placed in the com.examora.service package.
 */
public class SyllabusService {

    private final SubjectDAO subjectDAO = new SubjectDAO();
    private final TopicDAO topicDAO = new TopicDAO();
    private final UnitDAO unitDAO = new UnitDAO();

    /**
     * Compiles the complete subject-unit-topic-subtopic syllabus tree for a targeted exam.
     * @param examId the selected exam ID
     * @return List of Subjects containing populated child units, topics, and subtopics
     */
    public List<Subject> getSyllabusForExam(int examId) {
        if (examId <= 0) {
            return List.of();
        }
        
        // 1. Fetch subjects associated with this exam
        List<Subject> subjects = subjectDAO.getSubjectsByExamId(examId);

        // 2. Fetch units, topics, subtopics, and prerequisites for each subject
        for (Subject subject : subjects) {
            List<com.examora.model.Unit> units = unitDAO.getUnitsBySubjectId(subject.getId());
            
            // Fetch all topics in this subject (both unit-mapped and unmapped)
            List<Topic> allSubjectTopics = topicDAO.getTopicsBySubjectId(subject.getId(), examId);
            subject.setTopics(allSubjectTopics);
            
            if (units.isEmpty()) {
                // If subject has no units, create a single virtual unit to hold all topics
                if (!allSubjectTopics.isEmpty()) {
                    com.examora.model.Unit virtualUnit = new com.examora.model.Unit(-subject.getId(), subject.getId(), "Core Modules", "Standard syllabus topics for " + subject.getName());
                    for (Topic topic : allSubjectTopics) {
                        topic.setSubTopics(topicDAO.getSubTopicsByTopicId(topic.getId()));
                        topic.setPrerequisites(topicDAO.getPrerequisiteNamesForTopic(topic.getId()));
                        double weight = topic.getWeightage() != null ? topic.getWeightage() : 0.0;
                        double hours = topic.getEstimatedHours() > 0 ? topic.getEstimatedHours() : 1.0;
                        topic.setComputedYieldScore(weight / hours);
                        virtualUnit.addTopic(topic);
                    }
                    units.add(virtualUnit);
                }
            } else {
                // Subject has units. Populate each unit with its topics
                for (com.examora.model.Unit unit : units) {
                    List<Topic> unitTopics = new java.util.ArrayList<>();
                    for (Topic topic : allSubjectTopics) {
                        if (topic.getUnitId() == unit.getId()) {
                            topic.setSubTopics(topicDAO.getSubTopicsByTopicId(topic.getId()));
                            topic.setPrerequisites(topicDAO.getPrerequisiteNamesForTopic(topic.getId()));
                            double weight = topic.getWeightage() != null ? topic.getWeightage() : 0.0;
                            double hours = topic.getEstimatedHours() > 0 ? topic.getEstimatedHours() : 1.0;
                            topic.setComputedYieldScore(weight / hours);
                            unitTopics.add(topic);
                        }
                    }
                    unit.setTopics(unitTopics);
                }
                
                // Check if there are any unmapped topics (unit_id is null or 0)
                List<Topic> unmappedTopics = new java.util.ArrayList<>();
                for (Topic topic : allSubjectTopics) {
                    if (topic.getUnitId() == 0) {
                        topic.setSubTopics(topicDAO.getSubTopicsByTopicId(topic.getId()));
                        topic.setPrerequisites(topicDAO.getPrerequisiteNamesForTopic(topic.getId()));
                        double weight = topic.getWeightage() != null ? topic.getWeightage() : 0.0;
                        double hours = topic.getEstimatedHours() > 0 ? topic.getEstimatedHours() : 1.0;
                        topic.setComputedYieldScore(weight / hours);
                        unmappedTopics.add(topic);
                    }
                }
                if (!unmappedTopics.isEmpty()) {
                    com.examora.model.Unit virtualUnit = new com.examora.model.Unit(-subject.getId(), subject.getId(), "Core Modules", "Additional modules for " + subject.getName());
                    virtualUnit.setTopics(unmappedTopics);
                    units.add(virtualUnit);
                }
            }
            subject.setUnits(units);
        }

        return subjects;
    }

    /**
     * Returns a flattened list of all topics in an exam, sorted by computed yield score descending.
     * @param examId target exam ID
     * @return sorted List of Topics
     */
    public List<Topic> getHighYieldTopicsForExam(int examId) {
        List<Topic> allTopics = new java.util.ArrayList<>();
        List<Subject> syllabus = getSyllabusForExam(examId);
        
        for (Subject subject : syllabus) {
            for (com.examora.model.Unit unit : subject.getUnits()) {
                allTopics.addAll(unit.getTopics());
            }
        }
        
        // Sort descending by computed yield score
        allTopics.sort((t1, t2) -> Double.compare(t2.getComputedYieldScore(), t1.getComputedYieldScore()));
        return allTopics;
    }
}
