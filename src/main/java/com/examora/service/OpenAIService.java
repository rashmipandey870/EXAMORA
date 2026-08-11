package com.examora.service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

public class OpenAIService implements AIService {

    private final String apiKey;

    public OpenAIService() {
        // Read OpenAI API Key from environment variable
        String key = System.getenv("OPENAI_API_KEY");
        if (key == null || key.trim().isEmpty()) {
            key = "";
        }
        this.apiKey = key.trim();
    }

    public boolean isLive() {
        return !apiKey.isEmpty();
    }

    @Override
    public String generateNotes(String topicName, String subjectName) {
        if (!isLive()) {
            // Fallback to local template if API key is not present
            return generateLocalMockNotes(topicName, subjectName);
        }

        try {
            URL url = new URL("https://api.openai.com/v1/chat/completions");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setRequestProperty("Authorization", "Bearer " + apiKey);
            conn.setDoOutput(true);
            conn.setConnectTimeout(8000);
            conn.setReadTimeout(15000);

            // Construct simple prompt instructions
            String promptText = "Generate comprehensive, structured exam study revision notes in markdown format for topic: '" 
                              + topicName + "' under subject: '" + subjectName + "'. Include concepts, rules, formulas, and key summaries.";
            
            // Clean prompt text for escaping backslashes and double quotes
            String escapedPrompt = promptText.replace("\\", "\\\\").replace("\"", "\\\"");

            // Build manual JSON payload
            String jsonPayload = "{"
                    + "\"model\": \"gpt-4o-mini\","
                    + "\"messages\": [{"
                    +   "\"role\": \"user\","
                    +   "\"content\": \"" + escapedPrompt + "\""
                    + "}]"
                    + "}";

            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = jsonPayload.getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }

            int status = conn.getResponseCode();
            if (status == 200) {
                try (BufferedReader br = new BufferedReader(
                        new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
                    StringBuilder response = new StringBuilder();
                    String responseLine;
                    while ((responseLine = br.readLine()) != null) {
                        response.append(responseLine.trim());
                    }
                    
                    // Simple regex/substring parser to pull completion content from OpenAI JSON
                    String respStr = response.toString();
                    int contentIndex = respStr.indexOf("\"content\":");
                    if (contentIndex != -1) {
                        int startQuote = respStr.indexOf("\"", contentIndex + 10);
                        if (startQuote != -1) {
                            // Find matching end quote of content block (handling escaped quotes)
                            StringBuilder sb = new StringBuilder();
                            boolean escaped = false;
                            for (int i = startQuote + 1; i < respStr.length(); i++) {
                                char c = respStr.charAt(i);
                                if (escaped) {
                                    if (c == 'n') sb.append("\n");
                                    else if (c == 't') sb.append("\t");
                                    else sb.append(c);
                                    escaped = false;
                                } else if (c == '\\') {
                                    escaped = true;
                                } else if (c == '\"') {
                                    break; // closing quote
                                } else {
                                    sb.append(c);
                                }
                            }
                            return sb.toString();
                        }
                    }
                }
            } else {
                System.err.println("OpenAI API call failed with HTTP status: " + status);
            }
        } catch (Exception e) {
            System.err.println("Error calling OpenAI completions API: " + e.getMessage());
            e.printStackTrace();
        }

        // Return fallback mock notes on API exception/failure
        return generateLocalMockNotes(topicName, subjectName);
    }

    private String generateLocalMockNotes(String topicName, String subjectName) {
        StringBuilder sb = new StringBuilder();
        sb.append("# ").append(topicName).append(" — Key Revision Notes\n\n");
        sb.append("## Category: ").append(subjectName).append("\n\n");
        sb.append("### 1. Concept Overview\n");
        sb.append("This unit covers critical aspects of **").append(topicName).append("**. Understanding the core properties is vital for solving exam problems efficiently.\n\n");
        sb.append("### 2. Standard Mathematical Models / Rules\n");
        sb.append("- **Rule 1:** Ensure all operations satisfy the structural integrity constraints.\n");
        sb.append("- **Rule 2:** Always evaluate the dependencies sequentially.\n");
        sb.append("$$\\text{Efficiency} = \\frac{\\text{Weightage}}{\\text{Preparation Hours}} \\times 100\\%$$\n\n");
        sb.append("### 3. Core Formulas & Shortcuts\n");
        sb.append("1. **Time Complexity:** $O(\\log N)$ for optimized traversal operations.\n");
        sb.append("2. **Verification Equation:**\n");
        sb.append("$$\\sum_{i=1}^{n} X_i = \\text{Normalized Sum}$$\n\n");
        sb.append("### 4. High-Yield Summary\n");
        sb.append("> **Note:** Historical exams consistently focus on edge cases. Review previous years' questions carefully.");
        return sb.toString();
    }
}
