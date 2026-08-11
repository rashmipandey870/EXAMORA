package com.examora.service;

import com.examora.dao.StudyPlanDAO;
import com.examora.dao.StudyTaskDAO;
import com.examora.dao.TopicDAO;
import com.examora.model.StudyPlan;
import com.examora.model.StudyTask;
import com.examora.model.Topic;

import java.time.LocalDate;
import java.time.format.TextStyle;
import java.time.temporal.ChronoUnit;
import java.util.*;

/**
 * PlannerService handles the generation and scheduling logic of study plans.
 * 
 * WHAT: Service Layer for Study Planning.
 * WHY: Contains the scheduling algorithm that segments dates, allocates topics, and schedules revision.
 * HOW: Implements date checks, priority sorting, greedy hour allocation, and transaction writes.
 * WHERE: Placed in the com.examora.service package.
 */
public class PlannerService {

    private final StudyPlanDAO studyPlanDAO = new StudyPlanDAO();
    private final StudyTaskDAO studyTaskDAO = new StudyTaskDAO();
    private final TopicDAO topicDAO = new TopicDAO();
    private final TopicPriorityService priorityService = new TopicPriorityService();

    /**
     * Generates a complete study schedule and saves it to the database.
     * 
     * @param userId student ID
     * @param examId active exam ID
     * @param startDate plan start date
     * @param endDate target exam date
     * @param dailyHours daily available hours
     * @param preferredDays Mon,Tue... string
     * @param selectedTopicIds list of checked topic IDs
     * @return true if plan generation and save succeeds
     */
    public boolean generateAndSavePlan(int userId, int examId, LocalDate startDate, LocalDate endDate, 
                                       double dailyHours, String preferredDays, List<Integer> selectedTopicIds) {
        long totalStudyDays = ChronoUnit.DAYS.between(startDate, endDate) + 1;
        LocalDate targetSyllabus = startDate.plusDays(totalStudyDays / 2);
        LocalDate targetPyq = endDate.minusDays(14);
        if (!targetSyllabus.isBefore(targetPyq)) {
            targetSyllabus = startDate.plusDays(totalStudyDays / 3);
        }
        return generateAndSavePlan(userId, examId, startDate, endDate, dailyHours, preferredDays, selectedTopicIds, 
                                   targetSyllabus, targetPyq, 14, 50, 30, 20);
    }

    public boolean generateAndSavePlan(int userId, int examId, LocalDate startDate, LocalDate endDate, 
                                       double dailyHours, String preferredDays, List<Integer> selectedTopicIds,
                                       int learnPct, int practicePct, int revisionPct) {
        long totalStudyDays = ChronoUnit.DAYS.between(startDate, endDate) + 1;
        LocalDate targetSyllabus = startDate.plusDays(totalStudyDays / 2);
        LocalDate targetPyq = endDate.minusDays(14);
        if (!targetSyllabus.isBefore(targetPyq)) {
            targetSyllabus = startDate.plusDays(totalStudyDays / 3);
        }
        return generateAndSavePlan(userId, examId, startDate, endDate, dailyHours, preferredDays, selectedTopicIds, 
                                   targetSyllabus, targetPyq, 14, learnPct, practicePct, revisionPct);
    }

    public boolean generateAndSavePlan(int userId, int examId, LocalDate startDate, LocalDate endDate, 
                                       double dailyHours, String preferredDays, List<Integer> selectedTopicIds,
                                       LocalDate targetSyllabusDate, LocalDate targetPyqDate, int revisionBufferDays,
                                       int learnPct, int practicePct, int revisionPct) {
        
        // 1. Validation and early return checks
        if (startDate == null || endDate == null || startDate.isAfter(endDate)) {
            return false;
        }
        if (dailyHours <= 0) {
            return false;
        }

        // Save selection checkboxes to user_topics database table first
        boolean selectionSaved = topicDAO.saveUserTopicSelections(userId, selectedTopicIds);
        if (!selectionSaved) {
            return false;
        }

        // Load complete topic descriptions & trends for selected scope
        List<Topic> selectedTopics = topicDAO.getSelectedTopicsForUser(userId, examId);
        if (selectedTopics.isEmpty()) {
            return false;
        }

        // 2. Archive previous active plans for this student
        studyPlanDAO.deactivateActivePlans(userId);

        // 3. Save new active StudyPlan config
        StudyPlan plan = new StudyPlan();
        plan.setUserId(userId);
        plan.setExamId(examId);
        plan.setStartDate(startDate);
        plan.setEndDate(endDate);
        plan.setDailyStudyHours(dailyHours);
        plan.setPreferredDays(preferredDays);
        plan.setStatus("ACTIVE");
        
        plan.setTargetSyllabusCompletionDate(targetSyllabusDate);
        plan.setTargetPyqCompletionDate(targetPyqDate);
        plan.setRevisionBufferDays(revisionBufferDays);
        plan.setLearnPct(learnPct);
        plan.setPracticePct(practicePct);
        plan.setRevisionPct(revisionPct);

        boolean planSaved = studyPlanDAO.saveStudyPlan(plan);
        if (!planSaved) {
            return false;
        }

        // 4. Resolve study calendar dates based on user preferred days
        List<LocalDate> validStudyDates = new ArrayList<>();
        Set<String> prefDaysSet = new HashSet<>(Arrays.asList(preferredDays.split(",")));

        long totalDays = ChronoUnit.DAYS.between(startDate, endDate) + 1;
        for (int i = 0; i < totalDays; i++) {
            LocalDate date = startDate.plusDays(i);
            String dayName = date.getDayOfWeek().getDisplayName(TextStyle.SHORT, Locale.ENGLISH);
            if (prefDaysSet.contains(dayName)) {
                validStudyDates.add(date);
            }
        }

        if (validStudyDates.isEmpty()) {
            return false; // No preferred study days available in the range
        }

        // 5. Calculate total available hours and targets for splits
        double totalAvailableHours = validStudyDates.size() * dailyHours;
        double targetLearnHours = totalAvailableHours * (learnPct / 100.0);
        double targetPracticeHours = totalAvailableHours * (practicePct / 100.0);
        double targetRevisionHours = totalAvailableHours - targetLearnHours - targetPracticeHours;
        if (targetRevisionHours < 0.0) targetRevisionHours = 0.0;

        // 6. Calculate priority score for each selected topic and sort descending
        int totalDaysRemaining = (int) ChronoUnit.DAYS.between(startDate, endDate);
        if (totalDaysRemaining <= 0) totalDaysRemaining = 1;

        final int daysRemaining = totalDaysRemaining;
        double sumPriorityScores = 0.0;
        Map<Integer, Double> priorityScores = new HashMap<>();
        for (Topic topic : selectedTopics) {
            double score = priorityService.calculatePriorityScore(topic, 3, daysRemaining, userId);
            if (score <= 0.0) score = 1.0;
            priorityScores.put(topic.getId(), score);
            sumPriorityScores += score;
        }
        if (sumPriorityScores == 0.0) sumPriorityScores = 1.0;

        selectedTopics.sort((t1, t2) -> {
            double p1 = priorityScores.get(t1.getId());
            double p2 = priorityScores.get(t2.getId());
            return Double.compare(p2, p1); // Descending order
        });

        // Distribute target split hours to topics proportionally by priority score
        Map<Integer, Double> learnHoursMap = new HashMap<>();
        Map<Integer, Double> practiceHoursMap = new HashMap<>();
        Map<Integer, Double> revisionHoursMap = new HashMap<>();
        Map<Integer, LocalDate> topicCompletionDates = new HashMap<>();

        for (Topic topic : selectedTopics) {
            double score = priorityScores.get(topic.getId());
            double ratio = score / sumPriorityScores;
            double lHrs = targetLearnHours * ratio;
            double pHrs = targetPracticeHours * ratio;
            double rHrs = targetRevisionHours * ratio;
            
            learnHoursMap.put(topic.getId(), lHrs);
            practiceHoursMap.put(topic.getId(), pHrs);
            revisionHoursMap.put(topic.getId(), rHrs);

            // Populate trace explanations
            String exp = priorityService.getAllocationExplanation(topic, userId, daysRemaining, lHrs, pHrs, rHrs);
            topic.setPriorityScore(score);
            topic.setAllocationExplanation(exp);
        }

        // 7. Chronological simulation loop to interleave study tasks
        List<StudyTask> generatedTasks = new ArrayList<>();

        for (LocalDate date : validStudyDates) {
            double capacity = dailyHours;

            // Step A: Spaced Repetition Revision (schedule if topic completed at least 3 days ago)
            for (Topic topic : selectedTopics) {
                int topicId = topic.getId();
                LocalDate completionDate = topicCompletionDates.get(topicId);
                if (completionDate != null && date.isAfter(completionDate.plusDays(2))) {
                    double remainingRev = revisionHoursMap.getOrDefault(topicId, 0.0);
                    if (remainingRev > 0.05 && capacity > 0.05) {
                        double time = Math.min(Math.min(1.0, capacity), remainingRev);
                        StudyTask task = new StudyTask();
                        task.setStudyPlanId(plan.getId());
                        task.setTopicId(topicId);
                        task.setScheduledDate(date);
                        task.setScheduledHours(time);
                        task.setStatus("PENDING");
                        task.setRevision(true);
                        task.setMockTest(false);
                        task.setTaskMode("REVISION");
                        generatedTasks.add(task);

                        revisionHoursMap.put(topicId, remainingRev - time);
                        capacity -= time;
                    }
                }
            }

            // Step B: Interleaved Practice (schedule if topic learning is completed)
            for (Topic topic : selectedTopics) {
                int topicId = topic.getId();
                LocalDate completionDate = topicCompletionDates.get(topicId);
                if (completionDate != null && date.isAfter(completionDate)) {
                    double remainingPrac = practiceHoursMap.getOrDefault(topicId, 0.0);
                    if (remainingPrac > 0.05 && capacity > 0.05) {
                        double time = Math.min(Math.min(2.0, capacity), remainingPrac);
                        StudyTask task = new StudyTask();
                        task.setStudyPlanId(plan.getId());
                        task.setTopicId(topicId);
                        task.setScheduledDate(date);
                        task.setScheduledHours(time);
                        task.setStatus("PENDING");
                        task.setRevision(false);
                        task.setMockTest(true);
                        task.setTaskMode("PRACTICE");
                        generatedTasks.add(task);

                        practiceHoursMap.put(topicId, remainingPrac - time);
                        capacity -= time;
                    }
                }
            }

            // Step C: Learning (greedy chronological bin packing)
            for (Topic topic : selectedTopics) {
                int topicId = topic.getId();
                double remainingLearn = learnHoursMap.getOrDefault(topicId, 0.0);
                if (remainingLearn > 0.05 && capacity > 0.05) {
                    double time = Math.min(capacity, remainingLearn);
                    StudyTask task = new StudyTask();
                    task.setStudyPlanId(plan.getId());
                    task.setTopicId(topicId);
                    task.setScheduledDate(date);
                    task.setScheduledHours(time);
                    task.setStatus("PENDING");
                    task.setRevision(false);
                    task.setMockTest(false);
                    task.setTaskMode("LEARN");
                    generatedTasks.add(task);

                    learnHoursMap.put(topicId, remainingLearn - time);
                    capacity -= time;

                    if (learnHoursMap.get(topicId) <= 0.05) {
                        topicCompletionDates.put(topicId, date);
                    }
                }
            }

            // Step D: Spillover for remaining practice/revision to ensure 100% day coverage
            if (capacity > 0.05) {
                for (Topic topic : selectedTopics) {
                    int topicId = topic.getId();
                    double remainingPrac = practiceHoursMap.getOrDefault(topicId, 0.0);
                    if (remainingPrac > 0.05 && capacity > 0.05) {
                        double time = Math.min(capacity, remainingPrac);
                        StudyTask task = new StudyTask();
                        task.setStudyPlanId(plan.getId());
                        task.setTopicId(topicId);
                        task.setScheduledDate(date);
                        task.setScheduledHours(time);
                        task.setStatus("PENDING");
                        task.setRevision(false);
                        task.setMockTest(true);
                        task.setTaskMode("PRACTICE");
                        generatedTasks.add(task);

                        practiceHoursMap.put(topicId, remainingPrac - time);
                        capacity -= time;
                    }
                    double remainingRev = revisionHoursMap.getOrDefault(topicId, 0.0);
                    if (remainingRev > 0.05 && capacity > 0.05) {
                        double time = Math.min(capacity, remainingRev);
                        StudyTask task = new StudyTask();
                        task.setStudyPlanId(plan.getId());
                        task.setTopicId(topicId);
                        task.setScheduledDate(date);
                        task.setScheduledHours(time);
                        task.setStatus("PENDING");
                        task.setRevision(true);
                        task.setMockTest(false);
                        task.setTaskMode("REVISION");
                        generatedTasks.add(task);

                        revisionHoursMap.put(topicId, remainingRev - time);
                        capacity -= time;
                    }
                }
            }
        }

        // 10. Save all study tasks to database in a transaction
        return studyTaskDAO.saveStudyTasks(generatedTasks);
    }

    /**
     * Resolves the next closest valid study day that matches preferred days.
     */
    private LocalDate getNextPreferredStudyDate(LocalDate date, Set<String> prefDays, LocalDate limitDate) {
        LocalDate current = date;
        while (current.isBefore(limitDate) || current.isEqual(limitDate)) {
            String dayName = current.getDayOfWeek().getDisplayName(TextStyle.SHORT, Locale.ENGLISH);
            if (prefDays.contains(dayName)) {
                return current;
            }
            current = current.plusDays(1);
        }
        return null; // Exceeds deadline limit
    }
}
