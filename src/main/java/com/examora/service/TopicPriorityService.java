package com.examora.service;

import com.examora.model.Topic;

/**
 * TopicPriorityService calculates numerical priority scores for topics.
 * 
 * WHAT: Service Layer for Priority Score computations.
 * WHY: Decouples scheduling priority logic from database objects and general planner code.
 * HOW: Implements the weighted Priority Score Formula using importance, historical/recent frequency, difficulty, weakness, and urgency.
 * WHERE: Placed in the com.examora.service package.
 */
public class TopicPriorityService {

    // Weights configuration per formula specifications
    private static final double WEIGHT_IMPORTANCE = 3.0;
    private static final double WEIGHT_HIST_FREQUENCY = 1.5;
    private static final double WEIGHT_RECENT_FREQUENCY = 2.0;
    private static final double WEIGHT_DIFFICULTY = 1.0;
    private static final double WEIGHT_WEAKNESS = 2.5;
    private static final double WEIGHT_URGENCY = 2.0;

    /**
     * Calculates the Priority Score of a topic based on weights.
     * 
     * @param topic Topic object holding static properties and trend metadata
     * @param confidenceLevel Student confidence (1-5), defaults to 3 if no record
     * @param daysRemaining Days remaining until the target exam deadline
     * @return double calculated Priority Score
     */
    public double calculatePriorityScore(Topic topic, int confidenceLevel, int daysRemaining) {
        // 1. Importance (Priority) conversion (1 to 4)
        double importanceVal = 2.0; // default MEDIUM
        String prio = topic.getPriority();
        if (prio != null) {
            switch (prio.toUpperCase()) {
                case "VERY HIGH": importanceVal = 4.0; break;
                case "HIGH": importanceVal = 3.0; break;
                case "MEDIUM": importanceVal = 2.0; break;
                case "LOW": importanceVal = 1.0; break;
            }
        }

        // 2. Historical Frequency conversion (1 to 3)
        double histFreqVal = 2.0; // default MEDIUM
        String histFreq = topic.getHistoricalFrequency();
        if (histFreq != null) {
            switch (histFreq.toUpperCase()) {
                case "HIGH": histFreqVal = 3.0; break;
                case "MEDIUM": histFreqVal = 2.0; break;
                case "LOW": histFreqVal = 1.0; break;
            }
        }

        // 3. Recent Frequency conversion (1 to 3)
        double recentFreqVal = 2.0; // default MEDIUM
        String recentFreq = topic.getRecentFrequency();
        if (recentFreq != null) {
            switch (recentFreq.toUpperCase()) {
                case "HIGH": recentFreqVal = 3.0; break;
                case "MEDIUM": recentFreqVal = 2.0; break;
                case "LOW": recentFreqVal = 1.0; break;
            }
        }

        // 4. Invariant Difficulty conversion (1 to 3)
        double difficultyVal = 2.0; // default MEDIUM
        String diff = topic.getDifficulty();
        if (diff != null) {
            switch (diff.toUpperCase()) {
                case "HARD": difficultyVal = 3.0; break;
                case "MEDIUM": difficultyVal = 2.0; break;
                case "EASY": difficultyVal = 1.0; break;
            }
        }

        // 5. Weakness score inversion (Weakness increases as confidence decreases)
        // Confidence ranges 1 to 5. Weakness Score = 6 - confidenceLevel.
        if (confidenceLevel < 1 || confidenceLevel > 5) {
            confidenceLevel = 3; // Fallback to default neutral confidence
        }
        double weaknessVal = 6.0 - confidenceLevel;

        // 6. Urgency calculation
        int safeDays = daysRemaining > 0 ? daysRemaining : 1;
        double urgencyVal = (double) topic.getEstimatedHours() / safeDays;

        // Calculate the base weighted sum
        double baseScore = (importanceVal * WEIGHT_IMPORTANCE)
             + (histFreqVal * WEIGHT_HIST_FREQUENCY)
             + (recentFreqVal * WEIGHT_RECENT_FREQUENCY)
             + (difficultyVal * WEIGHT_DIFFICULTY)
             + (weaknessVal * WEIGHT_WEAKNESS)
             + (urgencyVal * WEIGHT_URGENCY);

        return baseScore;
    }

    public double calculatePriorityScore(Topic topic, int confidenceLevel, int daysRemaining, int userId) {
        double baseScore = calculatePriorityScore(topic, confidenceLevel, daysRemaining);
        if (userId > 0) {
            double accuracy = new com.examora.dao.PYQAttemptDAO().getTopicAccuracy(userId, topic.getId());
            double boost = 1.0 + (1.0 - accuracy) * 0.5;
            if (boost > 1.5) boost = 1.5;
            if (boost < 1.0) boost = 1.0;
            return baseScore * boost;
        }
        return baseScore;
    }

    public String getAllocationExplanation(Topic topic, int userId, int daysRemaining, double learnHrs, double practiceHrs, double revHrs) {
        double baseScore = calculatePriorityScore(topic, 3, daysRemaining);
        double accuracy = new com.examora.dao.PYQAttemptDAO().getTopicAccuracy(userId, topic.getId());
        double boost = 1.0 + (1.0 - accuracy) * 0.5;
        if (boost > 1.5) boost = 1.5;
        if (boost < 1.0) boost = 1.0;
        double finalScore = baseScore * boost;
        return String.format("Base priority score: %.2f (frequency: %s, difficulty: %s). Adaptive Boost: %.2fx (practice accuracy: %.0f%%). Total Priority Score: %.2f. Time allocated: Learn: %.1fh, Practice: %.1fh, Revision: %.1fh.",
            baseScore, topic.getHistoricalFrequency() != null ? topic.getHistoricalFrequency() : "MEDIUM", 
            topic.getDifficulty() != null ? topic.getDifficulty() : "MEDIUM", boost, accuracy * 100, finalScore, learnHrs, practiceHrs, revHrs);
    }
}
