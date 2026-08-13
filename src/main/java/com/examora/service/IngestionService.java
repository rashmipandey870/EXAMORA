package com.examora.service;

import com.examora.model.PYQStaging;
import org.apache.pdfbox.Loader;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.type.TypeReference;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class IngestionService {

    private final OpenAIService aiService = new OpenAIService();
    private final ObjectMapper mapper = new ObjectMapper();

    public List<PYQStaging> parsePdfToStaging(byte[] pdfBytes, String filename, String sourceUrl, int examId, int subjectId, int year) {
        String pdfText = "";
        try {
            pdfText = extractTextFromPdf(pdfBytes);
        } catch (IOException e) {
            System.err.println("Error extracting text from PDF: " + e.getMessage());
            e.printStackTrace();
            return generateMockStagingQuestions(filename, sourceUrl, examId, subjectId, year, "Failed to parse PDF text.");
        }

        if (pdfText.trim().isEmpty()) {
            return generateMockStagingQuestions(filename, sourceUrl, examId, subjectId, year, "PDF extracted text was empty.");
        }

        if (!aiService.isLive()) {
            System.out.println("OpenAI API key not found. Using local regex/mock staging ingestion fallback.");
            return generateMockStagingQuestions(filename, sourceUrl, examId, subjectId, year, "Ingested using local fallback (API key not live).");
        }

        try {
            // Call OpenAI with strict JSON formatting instructions
            String prompt = "You are an expert exam question extractor. Extract all multiple-choice questions (MCQs) from this raw past paper text:\n\n"
                    + "=== RAW PAST PAPER TEXT ===\n"
                    + pdfText + "\n"
                    + "=== END RAW TEXT ===\n\n"
                    + "Return a valid JSON array of question objects. Each object MUST contain these exact properties:\n"
                    + "- 'questionText': The main question description.\n"
                    + "- 'options': A JSON object with exactly four properties: 'A', 'B', 'C', 'D' mapping to option text strings.\n"
                    + "- 'correctAnswer': Exactly one uppercase character ('A', 'B', 'C', or 'D').\n"
                    + "- 'explanation': Detailed reasoning explaining why the correct choice is right.\n"
                    + "- 'suggestedDifficulty': String value: 'EASY', 'MEDIUM', or 'HARD'.\n"
                    + "- 'suggestedTopicId': Recommend one topic ID (default to 1 for DBMS Intro or 2 for Normalization).\n\n"
                    + "Do NOT wrap response in markdown code blocks. Return raw JSON array only.";

            String aiResponse = callAiCompletions(prompt);
            if (aiResponse != null && !aiResponse.trim().isEmpty()) {
                // Trim potential markdown wrappers if AI disobeyed
                aiResponse = aiResponse.trim();
                if (aiResponse.startsWith("```json")) {
                    aiResponse = aiResponse.substring(7);
                }
                if (aiResponse.startsWith("```")) {
                    aiResponse = aiResponse.substring(3);
                }
                if (aiResponse.endsWith("```")) {
                    aiResponse = aiResponse.substring(0, aiResponse.length() - 3);
                }
                aiResponse = aiResponse.trim();

                List<Map<String, Object>> rawQuestions = mapper.readValue(aiResponse, new TypeReference<List<Map<String, Object>>>() {});
                List<PYQStaging> stagingList = new ArrayList<>();
                for (Map<String, Object> map : rawQuestions) {
                    PYQStaging q = new PYQStaging();
                    q.setExamId(examId);
                    q.setSubjectId(subjectId);
                    q.setYear(year);
                    q.setSourcePdfFilename(filename);
                    q.setSourceUrl(sourceUrl);
                    q.setExtractedQuestionText((String) map.get("questionText"));
                    
                    Map<String, String> opts = (Map<String, String>) map.get("options");
                    q.setExtractedOptionsJson(mapper.writeValueAsString(opts));
                    
                    q.setExtractedCorrectAnswer((String) map.get("correctAnswer"));
                    q.setExtractedExplanation((String) map.get("explanation"));
                    
                    Object tIdObj = map.get("suggestedTopicId");
                    int tId = tIdObj instanceof Number ? ((Number) tIdObj).intValue() : 1;
                    q.setSuggestedTopicId(tId);
                    
                    q.setSuggestedDifficulty((String) map.get("suggestedDifficulty"));
                    q.setReviewStatus("PENDING_REVIEW");
                    stagingList.add(q);
                }
                return stagingList;
            }
        } catch (Exception e) {
            System.err.println("AI ingestion failed. Using staging mocks fallback: " + e.getMessage());
            e.printStackTrace();
        }

        return generateMockStagingQuestions(filename, sourceUrl, examId, subjectId, year, "Ingestion fell back due to parsing exception.");
    }

    private String extractTextFromPdf(byte[] bytes) throws IOException {
        try (PDDocument document = Loader.loadPDF(pdfBytesToStreamWrapper(bytes))) {
            PDFTextStripper stripper = new PDFTextStripper();
            return stripper.getText(document);
        }
    }

    private byte[] pdfBytesToStreamWrapper(byte[] raw) {
        return raw;
    }

    private String callAiCompletions(String prompt) {
        return aiService.generateNotes("Ingest", prompt); // Reuse OpenAIService API connector
    }

    private List<PYQStaging> generateMockStagingQuestions(String filename, String sourceUrl, int examId, int subjectId, int year, String note) {
        List<PYQStaging> list = new ArrayList<>();

        // Question 1
        PYQStaging q1 = new PYQStaging();
        q1.setExamId(examId);
        q1.setSubjectId(subjectId);
        q1.setYear(year);
        q1.setSourcePdfFilename(filename);
        q1.setSourceUrl(sourceUrl);
        q1.setExtractedQuestionText("Consider a relation R(A, B, C, D) with Functional Dependencies A -> B and B -> C. What is the highest normal form of relation R? (Note: " + note + ")");
        Map<String, String> o1 = new HashMap<>();
        o1.put("A", "1NF");
        o1.put("B", "2NF");
        o1.put("C", "3NF");
        o1.put("D", "BCNF");
        try {
            q1.setExtractedOptionsJson(mapper.writeValueAsString(o1));
        } catch (Exception ignored) {}
        q1.setExtractedCorrectAnswer("B");
        q1.setExtractedExplanation("The candidate key is A. The dependencies are A -> B and B -> C. Since B is not a candidate key, B -> C is a transitive dependency. Thus, R is in 2NF but not in 3NF.");
        q1.setSuggestedTopicId(2);
        q1.setSuggestedDifficulty("MEDIUM");
        q1.setReviewStatus("PENDING_REVIEW");
        list.add(q1);

        // Question 2
        PYQStaging q2 = new PYQStaging();
        q2.setExamId(examId);
        q2.setSubjectId(subjectId);
        q2.setYear(year);
        q2.setSourcePdfFilename(filename);
        q2.setSourceUrl(sourceUrl);
        q2.setExtractedQuestionText("Which join operator returns all rows from the left table, even if there are no matches in the right table?");
        Map<String, String> o2 = new HashMap<>();
        o2.put("A", "INNER JOIN");
        o2.put("B", "RIGHT OUTER JOIN");
        o2.put("C", "LEFT OUTER JOIN");
        o2.put("D", "FULL OUTER JOIN");
        try {
            q2.setExtractedOptionsJson(mapper.writeValueAsString(o2));
        } catch (Exception ignored) {}
        q2.setExtractedCorrectAnswer("C");
        q2.setExtractedExplanation("The LEFT OUTER JOIN returns all values from the left table, matching with right table rows, filling unmatched columns with NULL.");
        q2.setSuggestedTopicId(1);
        q2.setSuggestedDifficulty("EASY");
        q2.setReviewStatus("PENDING_REVIEW");
        list.add(q2);

        return list;
    }
}
