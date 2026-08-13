<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.examora.model.PYQStaging" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    List<PYQStaging> pendingList = (List<PYQStaging>) request.getAttribute("pendingList");
    List<com.examora.model.Topic> topicsList = (List<com.examora.model.Topic>) request.getAttribute("topicsList");
    String username = (String) request.getAttribute("username");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Ingestion — EXAMORA</title>
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
            background: rgba(99, 102, 241, 0.15);
            border: 1px solid rgba(99, 102, 241, 0.2);
        }

        /* Main Content Layout */
        .main-content {
            margin-left: 260px;
            flex-grow: 1;
            padding: 40px;
            max-width: 1200px;
        }

        .header-section {
            margin-bottom: 30px;
        }

        .header-section h1 {
            font-size: 2.2rem;
            font-weight: 850;
            letter-spacing: -0.5px;
            background: linear-gradient(135deg, #fff 0%, #a5b4fc 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 8px;
        }

        .header-desc {
            color: var(--text-secondary);
            font-size: 1rem;
        }

        /* Form & Cards Glassmorphism styling */
        .glass-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            backdrop-filter: blur(12px);
            border-radius: 16px;
            padding: 30px;
            margin-bottom: 30px;
        }

        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 24px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .form-group label {
            font-size: 0.85rem;
            font-weight: 650;
            color: #c7d2fe;
        }

        .form-input, .form-select, .form-textarea {
            background: rgba(0, 0, 0, 0.35);
            border: 1px solid var(--card-border);
            color: #fff;
            padding: 12px 16px;
            border-radius: 10px;
            font-size: 0.95rem;
            outline: none;
            transition: border-color 0.2s ease;
        }

        .form-input:focus, .form-select:focus, .form-textarea:focus {
            border-color: var(--accent-primary);
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
            align-self: flex-end;
            height: 48px;
        }

        .btn-submit:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 16px rgba(99, 102, 241, 0.4);
        }

        .notification {
            padding: 14px 20px;
            border-radius: 10px;
            margin-bottom: 24px;
            font-size: 0.95rem;
            font-weight: 600;
        }

        .notification.success {
            background: rgba(16, 185, 129, 0.15);
            color: #34d399;
            border: 1px solid rgba(16, 185, 129, 0.25);
        }

        .notification.error {
            background: rgba(239, 68, 68, 0.15);
            color: #f87171;
            border: 1px solid rgba(239, 68, 68, 0.25);
        }

        /* Review Staging Queue Cards */
        .staging-card {
            border: 1px solid var(--card-border);
            border-radius: 16px;
            background: rgba(13, 18, 36, 0.6);
            padding: 24px;
            margin-bottom: 24px;
            transition: all 0.3s ease;
        }

        .staging-card:hover {
            border-color: rgba(99, 102, 241, 0.2);
            background: rgba(13, 18, 36, 0.85);
        }

        .staging-meta {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 0.8rem;
            color: var(--text-secondary);
            margin-bottom: 16px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            padding-bottom: 12px;
        }

        .staging-body-grid {
            display: grid;
            grid-template-columns: 3fr 2fr;
            gap: 24px;
        }

        .left-panel {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .right-panel {
            display: flex;
            flex-direction: column;
            gap: 16px;
            background: rgba(255, 255, 255, 0.01);
            border-left: 1px solid rgba(255, 255, 255, 0.05);
            padding-left: 24px;
        }

        .btn-group {
            display: flex;
            gap: 12px;
            margin-top: 16px;
        }

        .btn-action {
            padding: 10px 18px;
            border-radius: 8px;
            font-size: 0.85rem;
            font-weight: 700;
            cursor: pointer;
            border: none;
            transition: all 0.2s;
        }

        .btn-approve {
            background: var(--success-color);
            color: #fff;
        }

        .btn-approve:hover {
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
            transform: translateY(-1px);
        }

        .btn-edit {
            background: var(--accent-primary);
            color: #fff;
        }

        .btn-edit:hover {
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
            transform: translateY(-1px);
        }

        .btn-reject {
            background: rgba(239, 68, 68, 0.15);
            color: #f87171;
            border: 1px solid rgba(239, 68, 68, 0.25);
        }

        .btn-reject:hover {
            background: var(--error-color);
            color: #fff;
        }

        .options-form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 12px;
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
                <a href="<%= request.getContextPath() %>/dashboard">
                    <span>Dashboard</span>
                </a>
            </li>
            <li class="nav-item">
                <a href="<%= request.getContextPath() %>/exams">
                    <span>My Exam Focus</span>
                </a>
            </li>
            <li class="nav-item">
                <a href="<%= request.getContextPath() %>/syllabus">
                    <span>Syllabus Explorer</span>
                </a>
            </li>
            <li class="nav-item">
                <a href="<%= request.getContextPath() %>/practice">
                    <span>Practice solver</span>
                </a>
            </li>
            <li class="nav-item active">
                <a href="<%= request.getContextPath() %>/admin/pyq-ingest">
                    <span>Ingest PYQs</span>
                </a>
            </li>
            <li class="nav-item nav-logout">
                <a href="<%= request.getContextPath() %>/logout">
                    <span>Sign Out</span>
                </a>
            </li>
        </ul>
    </div>

    <!-- Main Content -->
    <div class="main-content">
        <div class="header-section">
            <h1>Admin Ingestion Portal</h1>
            <p class="header-desc">
                Upload past exam papers (PDF format) and review the AI-extracted question candidates.
            </p>
        </div>

        <!-- Ingestion Status Notifications -->
        <% 
            String successMsg = request.getParameter("success");
            String errorMsg = request.getParameter("error");
            if (successMsg != null) {
        %>
            <div class="notification success"><%= successMsg %></div>
        <% } else if (errorMsg != null) { %>
            <div class="notification error"><%= errorMsg %></div>
        <% } %>

        <!-- Uploader Form Panel -->
        <div class="glass-card">
            <h3 style="font-size: 1.15rem; font-weight: 700; color: #fff; margin-bottom: 20px;">Upload Official PDF Document</h3>
            <form action="pyq-ingest" method="post" enctype="multipart/form-data">
                <input type="hidden" name="action" value="upload">
                
                <div class="form-grid">
                    <div class="form-group">
                        <label for="examId">Exam Reference</label>
                        <select name="examId" id="examId" class="form-select">
                            <option value="1">GATE CSE</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="subjectId">Subject Domain</label>
                        <select name="subjectId" id="subjectId" class="form-select">
                            <option value="1">Database Management Systems (DBMS)</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="year">Paper Year</label>
                        <select name="year" id="year" class="form-select">
                            <% for (int y = 2027; y >= 2008; y--) { %>
                                <option value="<%= y %>"><%= y %></option>
                            <% } %>
                        </select>
                    </div>
                </div>

                <div class="form-grid" style="grid-template-columns: 3fr 1fr;">
                    <div class="form-group">
                        <label for="sourceUrl">Conducting Institute Source URL</label>
                        <input type="url" name="sourceUrl" id="sourceUrl" placeholder="e.g. https://gate2024.iisc.ac.in" class="form-input" required>
                    </div>
                    <div class="form-group">
                        <label for="pdfFile">Past Paper PDF</label>
                        <input type="file" name="pdfFile" id="pdfFile" accept="application/pdf" class="form-input" required style="padding: 8px 12px;">
                    </div>
                </div>

                <div style="display: flex; justify-content: flex-end; margin-top: 10px;">
                    <button type="submit" class="btn-submit">Start Extraction</button>
                </div>
            </form>
        </div>

        <!-- Staging Review Area -->
        <h2 style="font-size: 1.4rem; font-weight: 800; color: #fff; margin-bottom: 20px;">Staging & Verification Queue</h2>
        
        <% if (pendingList == null || pendingList.isEmpty()) { %>
            <div class="glass-card" style="text-align: center; color: var(--text-secondary); padding: 50px 20px;">
                <h3>Queue is empty</h3>
                <p style="margin-top: 10px;">Upload a past paper PDF above to populate new candidates for verification.</p>
            </div>
        <% } else { %>
            <div id="staging-queue">
                <% 
                    for (PYQStaging q : pendingList) {
                        Map<String, String> opts = q.getParsedOptions();
                %>
                    <div class="staging-card" id="staging-card-<%= q.getId() %>">
                        <form id="staging-form-<%= q.getId() %>">
                            <input type="hidden" name="stagingId" value="<%= q.getId() %>">
                            
                            <div class="staging-meta">
                                <span>PDF Reference: <strong><%= q.getSourcePdfFilename() %></strong></span>
                                <span>Subject Focus: <strong>DBMS</strong> &bull; Year: 
                                    <select name="year" style="background: none; border: none; color: #a5b4fc; font-weight: 700; font-size: 0.8rem; cursor: pointer;">
                                        <% for (int y = 2027; y >= 2008; y--) { %>
                                            <option value="<%= y %>" <%= y == q.getYear() ? "selected" : "" %>><%= y %></option>
                                        <% } %>
                                    </select>
                                </span>
                            </div>

                            <div class="staging-body-grid">
                                <!-- Left side: Question Text and choices editing -->
                                <div class="left-panel">
                                    <div class="form-group">
                                        <label>Question Body</label>
                                        <textarea name="questionText" class="form-textarea" rows="4" required><%= q.getExtractedQuestionText() %></textarea>
                                    </div>
                                    
                                    <label style="font-size: 0.85rem; font-weight: 650; color: #c7d2fe;">Option Choices</label>
                                    <div class="options-form-grid">
                                        <div class="form-group">
                                            <input type="text" name="optionA" value="<%= opts.getOrDefault("A", "") %>" placeholder="Option A" class="form-input" required>
                                        </div>
                                        <div class="form-group">
                                            <input type="text" name="optionB" value="<%= opts.getOrDefault("B", "") %>" placeholder="Option B" class="form-input" required>
                                        </div>
                                        <div class="form-group">
                                            <input type="text" name="optionC" value="<%= opts.getOrDefault("C", "") %>" placeholder="Option C" class="form-input" required>
                                        </div>
                                        <div class="form-group">
                                            <input type="text" name="optionD" value="<%= opts.getOrDefault("D", "") %>" placeholder="Option D" class="form-input" required>
                                        </div>
                                    </div>
                                </div>

                                <!-- Right side: Solution details meta editing -->
                                <div class="right-panel">
                                    <div class="form-grid" style="grid-template-columns: 1fr 1fr; margin-bottom: 0;">
                                        <div class="form-group">
                                            <label>Correct Choice</label>
                                            <select name="correctAnswer" class="form-select">
                                                <option value="A" <%= "A".equals(q.getExtractedCorrectAnswer()) ? "selected" : "" %>>A</option>
                                                <option value="B" <%= "B".equals(q.getExtractedCorrectAnswer()) ? "selected" : "" %>>B</option>
                                                <option value="C" <%= "C".equals(q.getExtractedCorrectAnswer()) ? "selected" : "" %>>C</option>
                                                <option value="D" <%= "D".equals(q.getExtractedCorrectAnswer()) ? "selected" : "" %>>D</option>
                                            </select>
                                        </div>
                                        <div class="form-group">
                                            <label>Difficulty</label>
                                            <select name="difficulty" class="form-select">
                                                <option value="EASY" <%= "EASY".equalsIgnoreCase(q.getSuggestedDifficulty()) ? "selected" : "" %>>EASY</option>
                                                <option value="MEDIUM" <%= "MEDIUM".equalsIgnoreCase(q.getSuggestedDifficulty()) ? "selected" : "" %>>MEDIUM</option>
                                                <option value="HARD" <%= "HARD".equalsIgnoreCase(q.getSuggestedDifficulty()) ? "selected" : "" %>>HARD</option>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="form-group">
                                        <label>Syllabus Topic Alignment</label>
                                        <select name="topicId" class="form-select">
                                            <% if (topicsList != null) { 
                                                for (com.examora.model.Topic t : topicsList) {
                                            %>
                                                <option value="<%= t.getId() %>" <%= t.getId() == q.getSuggestedTopicId() ? "selected" : "" %>><%= t.getName() %></option>
                                            <% } } %>
                                        </select>
                                    </div>

                                    <div class="form-group">
                                        <label>Detailed Explanation</label>
                                        <textarea name="explanation" class="form-textarea" rows="3" required><%= q.getExtractedExplanation() %></textarea>
                                    </div>

                                    <div class="btn-group">
                                        <button type="button" class="btn-action btn-approve" onclick="reviewAction(<%= q.getId() %>, 'approve')">Approve As-Is</button>
                                        <button type="button" class="btn-action btn-edit" onclick="reviewAction(<%= q.getId() %>, 'edit')">Update & Approve</button>
                                        <button type="button" class="btn-action btn-reject" onclick="reviewAction(<%= q.getId() %>, 'reject')">Reject</button>
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>
                <% } %>
            </div>
        <% } %>
    </div>

    <script>
        function reviewAction(stagingId, action) {
            const form = document.getElementById(`staging-form-${stagingId}`);
            const card = document.getElementById(`staging-card-${stagingId}`);
            
            const params = new URLSearchParams();
            params.append('action', action);
            params.append('stagingId', stagingId);

            if (action === 'edit') {
                const fd = new FormData(form);
                for (let [key, val] of fd.entries()) {
                    params.append(key, val);
                }
            }

            fetch('pyq-ingest', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: params.toString()
            })
            .then(async response => {
                const data = await response.json();
                if (response.ok && data.status === 'SUCCESS') {
                    // Animate out card smoothly
                    card.style.opacity = '0';
                    card.style.transform = 'scale(0.95)';
                    setTimeout(() => {
                        card.remove();
                        // If queue is empty, reload to show empty state
                        const queue = document.getElementById('staging-queue');
                        if (queue && queue.children.length === 0) {
                            location.reload();
                        }
                    }, 300);
                } else {
                    alert("Action failed: " + (data.message || "Unknown error"));
                }
            })
            .catch(error => {
                alert("Network error: " + error.message);
            });
        }
    </script>
</body>
</html>
