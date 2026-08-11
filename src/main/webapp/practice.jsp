<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.examora.model.Exam" %>
<%@ page import="com.examora.model.PYQQuestion" %>
<%@ page import="java.util.List" %>
<%
    Exam activeExam = (Exam) request.getAttribute("activeExam");
    List<PYQQuestion> questions = (List<PYQQuestion>) request.getAttribute("questions");
    String username = (String) request.getAttribute("username");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Practice solver — EXAMORA</title>
    <style>
        :root {
            --bg-color: #060816;
            --sidebar-bg: #0b0d1b;
            --card-bg: rgba(13, 18, 36, 0.7);
            --card-border: rgba(255, 255, 255, 0.08);
            --text-primary: #f3f4f6;
            --text-secondary: #9ca3af;
            --accent-primary: #6366f1;
            --accent-secondary: #a855f7;
            --success-color: #10b981;
            --error-color: #ef4444;
            --font-family: 'Inter', system-ui, -apple-system, sans-serif;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            background-color: var(--bg-color);
            background-image: 
                radial-gradient(circle at 10% 20%, rgba(99, 102, 241, 0.08) 0%, transparent 45%),
                radial-gradient(circle at 90% 80%, rgba(168, 85, 247, 0.08) 0%, transparent 45%);
            color: var(--text-primary);
            font-family: var(--font-family);
            min-height: 100vh;
            display: flex;
        }

        /* Sidebar Navigation Layout */
        .sidebar {
            width: 260px;
            background: var(--sidebar-bg);
            border-right: 1px solid var(--card-border);
            display: flex;
            flex-direction: column;
            padding: 30px 20px;
            position: fixed;
            height: 100vh;
            z-index: 100;
        }

        .logo-container {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 40px;
        }

        .logo-text {
            font-size: 1.25rem;
            font-weight: 800;
            background: linear-gradient(135deg, #fff 0%, #a5b4fc 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            letter-spacing: 0.5px;
        }

        .nav-links {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .nav-item a {
            display: flex;
            align-items: center;
            padding: 14px 18px;
            color: var(--text-secondary);
            text-decoration: none;
            border-radius: 12px;
            font-size: 0.95rem;
            font-weight: 600;
            transition: all 0.3s;
        }

        .nav-item a:hover {
            color: #fff;
            background: rgba(255, 255, 255, 0.03);
        }

        .nav-item.active a {
            color: #fff;
            background: rgba(99, 102, 241, 0.12);
            border: 1px solid rgba(99, 102, 241, 0.2);
        }

        .nav-logout a:hover {
            background: rgba(239, 68, 68, 0.08);
            color: #f87171;
        }

        /* Main Content Area */
        .main-content {
            flex-grow: 1;
            margin-left: 260px;
            padding: 40px;
            max-width: 1000px;
        }

        .header-section {
            margin-bottom: 35px;
            border-bottom: 1px solid var(--card-border);
            padding-bottom: 20px;
        }

        h1 {
            font-size: 2rem;
            font-weight: 800;
            background: linear-gradient(135deg, #fff 30%, #a5b4fc 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 6px;
        }

        .header-desc {
            color: var(--text-secondary);
            font-size: 0.95rem;
        }

        .q-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            padding: 30px;
            margin-bottom: 25px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.4);
            backdrop-filter: blur(12px);
        }

        .q-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 18px;
        }

        .badge {
            font-size: 0.72rem;
            font-weight: 700;
            padding: 4px 10px;
            border-radius: 6px;
        }

        .badge-verified {
            background: rgba(16, 185, 129, 0.15);
            color: #34d399;
            border: 1px solid rgba(16, 185, 129, 0.2);
        }

        .badge-practice {
            background: rgba(168, 85, 247, 0.15);
            color: #c084fc;
            border: 1px solid rgba(168, 85, 247, 0.2);
        }

        .q-marks {
            font-size: 0.82rem;
            color: var(--text-secondary);
        }

        .q-text {
            font-size: 1.05rem;
            font-weight: 600;
            line-height: 1.6;
            color: #fff;
            margin-bottom: 24px;
        }

        .options-list {
            display: flex;
            flex-direction: column;
            gap: 12px;
            margin-bottom: 24px;
        }

        .option-lbl {
            background: rgba(0, 0, 0, 0.25);
            border: 1px solid rgba(255, 255, 255, 0.05);
            border-radius: 12px;
            padding: 14px 18px;
            display: flex;
            align-items: center;
            gap: 14px;
            cursor: pointer;
            transition: all 0.25s;
            font-size: 0.95rem;
        }

        .option-lbl:hover {
            background: rgba(255, 255, 255, 0.03);
            border-color: rgba(99, 102, 241, 0.3);
        }

        .option-lbl input {
            accent-color: var(--accent-primary);
            width: 18px;
            height: 18px;
        }

        .btn-submit {
            background: linear-gradient(135deg, var(--accent-primary) 0%, var(--accent-secondary) 100%);
            color: #fff;
            border: none;
            padding: 12px 24px;
            border-radius: 10px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.25);
        }

        .btn-submit:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 16px rgba(99, 102, 241, 0.4);
        }

        .explain-box {
            background: rgba(255, 255, 255, 0.02);
            border: 1px solid var(--card-border);
            border-radius: 12px;
            padding: 18px;
            margin-top: 20px;
            animation: fadeIn 0.4s ease;
        }

        .result-status {
            font-weight: 700;
            font-size: 1rem;
            margin-bottom: 8px;
            display: block;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(8px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .empty-state {
            text-align: center;
            color: var(--text-secondary);
            padding: 50px 20px;
        }
    </style>
</head>
<body>

    <!-- Sidebar navigation -->
    <div class="sidebar">
        <div class="logo-container">
            <span class="logo-text">EXAMORA</span>
        </div>
        
        <ul class="nav-links">
            <li class="nav-item">
                <a href="dashboard">
                    <span>Dashboard</span>
                </a>
            </li>
            <li class="nav-item">
                <a href="exams">
                    <span>My Exam Focus</span>
                </a>
            </li>
            <li class="nav-item">
                <a href="syllabus">
                    <span>Syllabus Explorer</span>
                </a>
            </li>
            <li class="nav-item active">
                <a href="practice">
                    <span>Practice solver</span>
                </a>
            </li>
            <li class="nav-item nav-logout">
                <a href="logout">
                    <span>Sign Out</span>
                </a>
            </li>
        </ul>
    </div>

    <!-- Main Content -->
    <div class="main-content">
        <div class="header-section">
            <h1>Practice Solver & PYQ Bank</h1>
            <p class="header-desc">
                Currently loaded for: <strong><%= activeExam.getName() %></strong>
            </p>
        </div>

        <!-- PYQ Year Coverage Register -->
        <%
            java.util.List<com.examora.model.PYQCoverage> coverageList = (java.util.List<com.examora.model.PYQCoverage>) request.getAttribute("coverageList");
            java.util.Map<String, Integer> coverageStats = (java.util.Map<String, Integer>) request.getAttribute("coverageStats");
            if (coverageList != null && !coverageList.isEmpty()) {
        %>
            <div class="glass-card" style="padding: 24px; border-radius: 16px; margin-bottom: 30px; border-color: rgba(99, 102, 241, 0.15);">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                    <div>
                        <h3 style="font-size: 1.15rem; font-weight: 700; color: #fff; margin: 0 0 4px 0;">Sourced PYQ Year Coverage Register</h3>
                        <p style="font-size: 0.8rem; color: var(--text-secondary); margin: 0;">
                            Honest coverage and verification status tracker for exam past paper archives.
                        </p>
                    </div>
                    <div style="background: rgba(99, 102, 241, 0.15); color: #a5b4fc; padding: 6px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; border: 1px solid rgba(99, 102, 241, 0.3); white-space: nowrap;">
                        <%= coverageStats != null ? coverageStats.get("completeYears") : 0 %> / <%= coverageStats != null ? coverageStats.get("totalYears") : 0 %> Years Sourced
                    </div>
                </div>
                
                <div style="display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 16px;">
                    <% 
                        for (com.examora.model.PYQCoverage cov : coverageList) {
                            String statusBg = "rgba(239, 68, 68, 0.1)";
                            String statusText = "#f87171";
                            String border = "1px solid rgba(239, 68, 68, 0.2)";
                            if ("COMPLETE".equalsIgnoreCase(cov.getIngestionStatus())) {
                                statusBg = "rgba(16, 185, 129, 0.1)";
                                statusText = "#34d399";
                                border = "1px solid rgba(16, 185, 129, 0.2)";
                            } else if ("IN_PROGRESS".equalsIgnoreCase(cov.getIngestionStatus())) {
                                statusBg = "rgba(245, 158, 11, 0.1)";
                                statusText = "#fbbf24";
                                border = "1px solid rgba(245, 158, 11, 0.2)";
                            }
                    %>
                        <div style="background: rgba(255,255,255,0.02); border: 1px solid rgba(255,255,255,0.05); padding: 16px; border-radius: 12px; display: flex; flex-direction: column; justify-content: space-between;">
                            <div>
                                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                                    <span style="font-size: 1.1rem; font-weight: 800; color: #fff;">PYQ <%= cov.getYear() %></span>
                                    <span style="background: <%= statusBg %>; color: <%= statusText %>; border: <%= border %>; font-size: 0.65rem; font-weight: 700; padding: 2px 6px; border-radius: 10px;">
                                        <%= cov.getIngestionStatus() %>
                                    </span>
                                </div>
                                <div style="font-size: 0.75rem; color: var(--text-secondary); margin-bottom: 4px;">
                                    Questions Sourced: <strong><%= cov.getQuestionCount() %></strong>
                                </div>
                                <div style="font-size: 0.75rem; color: var(--text-secondary);">
                                    Verified: <strong><%= cov.getVerifiedCount() %></strong>
                                </div>
                            </div>
                            <div style="margin-top: 12px; font-size: 0.7rem; text-overflow: ellipsis; overflow: hidden; white-space: nowrap;">
                                <a href="<%= cov.getSourceUrl() %>" target="_blank" style="color: #818cf8; text-decoration: none;">
                                    🔗 Source URL
                                </a>
                            </div>
                        </div>
                    <% } %>
                </div>
            </div>
        <% } %>

        <%
            if (questions != null && !questions.isEmpty()) {
                for (PYQQuestion q : questions) {
                    // Simple parse JSON array options
                    String optJson = q.getOptionsJson();
                    optJson = optJson.substring(2, optJson.length() - 2); 
                    String[] options = optJson.split("\",\\s*\"");
        %>
                    <div class="q-card">
                        <div class="q-meta">
                            <div>
                                <% if (q.isVerified()) { %>
                                    <span class="badge badge-verified">
                                        ✓ Official PYQ — <%= q.getSource() %> <%= q.getYear() != null ? "(" + q.getYear() + ")" : "" %>
                                    </span>
                                <% } else { %>
                                    <span class="badge badge-practice">
                                        ⚡ Exam-Style Practice
                                    </span>
                                <% } %>
                            </div>
                            <div class="q-marks">
                                Difficulty: <strong><%= q.getDifficulty() %></strong> &bull; Marks: <strong><%= q.getMarks() %></strong>
                            </div>
                        </div>

                        <div class="q-text">
                            <%= q.getQuestionText() %>
                        </div>

                        <div class="options-list">
                            <% 
                                char optLetter = 'A';
                                for (String option : options) { 
                                    String optionVal = String.valueOf(optLetter);
                            %>
                                    <label class="option-lbl">
                                        <input type="radio" name="opt-<%= q.getId() %>" value="<%= optionVal %>">
                                        <span><strong><%= optLetter++ %>.</strong> <%= option %></span>
                                    </label>
                            <% 
                                } 
                            %>
                        </div>

                        <button class="btn-submit" onclick="checkAnswer(<%= q.getId() %>)">
                            Submit Answer
                        </button>

                        <!-- Hidden Explanation Box -->
                        <div class="explain-box" id="explain-<%= q.getId() %>" style="display: none;">
                            <span class="result-status" id="result-<%= q.getId() %>">Correct!</span>
                            <p style="color: var(--text-secondary); font-size: 0.95rem; line-height: 1.5;">
                                <strong>Explanation:</strong> <%= q.getExplanation() != null ? q.getExplanation() : "No additional notes provided." %>
                            </p>
                        </div>
                    </div>
        <%
                }
            } else {
        %>
                <div class="glass-card empty-state">
                    <h3>No practice questions loaded yet</h3>
                    <p style="margin-top: 10px;">Check back later when syllabus sources are updated.</p>
                </div>
        <%
            }
        %>
    </div>

    <script>
        function checkAnswer(qId) {
            const selected = document.querySelector(`input[name="opt-${qId}"]:checked`);
            if (!selected) {
                alert("Please select an answer choice first.");
                return;
            }

            const selectedOption = selected.value;

            // Submit attempt via AJAX to server-side POST
            const params = new URLSearchParams();
            params.append('questionId', qId);
            params.append('selectedOption', selectedOption);

            fetch('practice', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: params.toString()
            })
            .then(async response => {
                const data = await response.json();
                if (response.ok && data.status === 'SUCCESS') {
                    const explainBox = document.getElementById(`explain-${qId}`);
                    const resultStatus = document.getElementById(`result-${qId}`);
                    const explainText = explainBox.querySelector('p');
                    
                    explainBox.style.display = "block";
                    if (data.isCorrect) {
                        resultStatus.innerText = "✓ Correct Answer!";
                        resultStatus.style.color = "var(--success-color)";
                    } else {
                        resultStatus.innerText = "✗ Incorrect! The correct answer was: " + data.correctAnswer;
                        resultStatus.style.color = "var(--error-color)";
                    }
                    if (data.explanation) {
                        explainText.innerHTML = `<strong>Explanation:</strong> ${data.explanation}`;
                    }
                    
                    // Disable options radios and button once submitted
                    document.querySelectorAll(`input[name="opt-${qId}"]`).forEach(input => input.disabled = true);
                    const btn = document.querySelector(`button[onclick*="checkAnswer(${qId})"]`);
                    if (btn) btn.disabled = true;
                } else {
                    alert("Error submitting attempt: " + (data.message || "Failed."));
                }
            })
            .catch(error => {
                alert("Network error: " + error.message);
            });
        }
    </script>
</body>
</html>
