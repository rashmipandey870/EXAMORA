<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.examora.model.Exam" %>
<%@ page import="java.util.List" %>
<%
    List<Exam> recommendations = (List<Exam>) request.getAttribute("recommendations");
    String background = (String) request.getAttribute("background");
    String goal = (String) request.getAttribute("goal");
    String targetTimeline = (String) request.getAttribute("targetTimeline");
    String username = (String) request.getAttribute("username");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Syllabus Match Results — EXAMORA</title>
    <style>
        :root {
            --bg-color: #060816;
            --card-bg: rgba(13, 18, 36, 0.7);
            --card-border: rgba(255, 255, 255, 0.08);
            --text-primary: #f3f4f6;
            --text-secondary: #9ca3af;
            --accent-primary: #6366f1;
            --accent-secondary: #a855f7;
            --success-color: #10b981;
            --warning-color: #f59e0b;
            --info-color: #3b82f6;
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
                radial-gradient(circle at 10% 20%, rgba(99, 102, 241, 0.1) 0%, transparent 45%),
                radial-gradient(circle at 90% 80%, rgba(168, 85, 247, 0.1) 0%, transparent 45%);
            color: var(--text-primary);
            font-family: var(--font-family);
            min-height: 100vh;
            padding: 40px 20px;
        }

        .container {
            width: 100%;
            max-width: 900px;
            margin: 0 auto;
        }

        .welcome-header {
            text-align: center;
            margin-bottom: 40px;
        }

        .welcome-header h2 {
            font-size: 2rem;
            font-weight: 800;
            background: linear-gradient(135deg, #fff 0%, #a5b4fc 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 8px;
        }

        .welcome-header p {
            color: var(--text-secondary);
            font-size: 1rem;
        }

        .glass-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4);
            backdrop-filter: blur(12px);
            margin-bottom: 30px;
        }

        .rec-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 20px;
            margin-bottom: 30px;
        }

        .rec-card {
            background: rgba(0, 0, 0, 0.2);
            border: 1px solid rgba(255, 255, 255, 0.05);
            border-radius: 16px;
            padding: 24px;
            transition: all 0.3s;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            position: relative;
        }

        .rec-card:hover {
            border-color: rgba(99, 102, 241, 0.3);
            box-shadow: 0 5px 15px rgba(99, 102, 241, 0.1);
        }

        .rec-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 15px;
            gap: 16px;
        }

        .exam-title-grp h3 {
            font-size: 1.3rem;
            font-weight: 800;
            color: #fff;
            margin-bottom: 4px;
        }

        .conducting-lbl {
            font-size: 0.85rem;
            color: var(--text-secondary);
        }

        .badge-type {
            font-size: 0.75rem;
            font-weight: 700;
            padding: 4px 10px;
            border-radius: 6px;
            background: rgba(99, 102, 241, 0.15);
            color: #818cf8;
            border: 1px solid rgba(99, 102, 241, 0.2);
        }

        .badge-type.rolling {
            background: rgba(16, 185, 129, 0.15);
            color: #34d399;
            border: 1px solid rgba(16, 185, 129, 0.2);
        }

        .rec-body {
            font-size: 0.92rem;
            line-height: 1.6;
            margin-bottom: 20px;
        }

        .rec-reason {
            background: rgba(255, 255, 255, 0.02);
            border-left: 3px solid var(--accent-primary);
            padding: 10px 14px;
            border-radius: 0 8px 8px 0;
            margin-bottom: 16px;
            font-size: 0.88rem;
            color: #a5b4fc;
        }

        .detail-row {
            display: flex;
            flex-wrap: wrap;
            gap: 20px;
            margin-bottom: 14px;
            font-size: 0.85rem;
        }

        .detail-item strong {
            color: var(--text-secondary);
        }

        .rec-actions {
            display: flex;
            justify-content: flex-end;
            gap: 12px;
            align-items: center;
            border-top: 1px solid var(--card-border);
            padding-top: 18px;
        }

        .btn {
            padding: 10px 20px;
            border-radius: 8px;
            font-size: 0.88rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
            border: none;
        }

        .btn-compare-toggle {
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid var(--card-border);
            color: var(--text-secondary);
        }

        .btn-compare-toggle.checked {
            background: rgba(168, 85, 247, 0.1);
            border-color: var(--accent-secondary);
            color: #d8b4fe;
        }

        .btn-select {
            background: linear-gradient(135deg, var(--accent-primary) 0%, var(--accent-secondary) 100%);
            color: white;
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.2);
        }

        .btn-select:hover {
            transform: translateY(-1px);
            box-shadow: 0 6px 15px rgba(99, 102, 241, 0.3);
        }

        /* Comparison Board Section */
        .comparison-section {
            display: none;
            margin-top: 40px;
            animation: fadeIn 0.4s ease forwards;
        }

        .comparison-table-wrapper {
            overflow-x: auto;
            border: 1px solid var(--card-border);
            border-radius: 16px;
            background: rgba(0, 0, 0, 0.2);
        }

        .comparison-table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
            font-size: 0.9rem;
        }

        .comparison-table th, .comparison-table td {
            padding: 16px 20px;
            border-bottom: 1px solid var(--card-border);
            vertical-align: top;
        }

        .comparison-table th {
            background: rgba(255, 255, 255, 0.02);
            font-weight: 700;
            color: #fff;
        }

        .comparison-table td strong {
            display: block;
            margin-bottom: 4px;
            color: var(--accent-primary);
        }

        .empty-state {
            text-align: center;
            padding: 40px;
            color: var(--text-secondary);
        }

        .comparison-header-cell {
            min-width: 200px;
        }

        .toast {
            position: fixed;
            bottom: 24px;
            right: 24px;
            background: rgba(13, 18, 36, 0.95);
            border: 1px solid var(--card-border);
            border-left: 4px solid var(--success-color);
            padding: 16px 24px;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
            display: none;
            z-index: 1000;
        }
    </style>
</head>
<body>

    <div class="container">
        <div class="welcome-header">
            <h2>Recommended Focus Match Strategy</h2>
            <p>Based on your profile, here are the targeted examinations that match your background & prep goals.</p>
        </div>

        <div class="glass-card">
            <div class="rec-grid">
                <% 
                    if (recommendations != null && !recommendations.isEmpty()) {
                        for (Exam exam : recommendations) {
                            // Deduce matching reasons
                            StringBuilder reason = new StringBuilder();
                            reason.append("Direct match for your ").append(background.replace("_", " ")).append(" background");
                            if (exam.getGoalTags() != null && exam.getGoalTags().contains(goal)) {
                                reason.append(" and ").append(goal.replace("_", " ")).append(" objective");
                            }
                            reason.append(".");
                %>
                            <div class="rec-card" id="exam-card-<%= exam.getId() %>">
                                <div>
                                    <div class="rec-header">
                                        <div class="exam-title-grp">
                                            <h3 id="name-<%= exam.getId() %>"><%= exam.getName() %></h3>
                                            <div class="conducting-lbl" id="conducting-<%= exam.getId() %>"><%= exam.getConductingBody() != null ? exam.getConductingBody() : "Standard Catalog" %></div>
                                        </div>
                                        <div>
                                            <span class="badge-type <%= exam.isRollingExam() ? "rolling" : "" %>">
                                                <%= exam.isRollingExam() ? "Rolling / On-Demand" : "Scheduled Year " + exam.getExamYear() %>
                                            </span>
                                        </div>
                                    </div>

                                    <div class="rec-reason">
                                        💡 <%= reason.toString() %>
                                    </div>

                                    <div class="rec-body">
                                        <div class="detail-row">
                                            <div class="detail-item"><strong>Eligibility:</strong> <span id="eligibility-<%= exam.getId() %>"><%= exam.getEligibilityCriteria() != null ? exam.getEligibilityCriteria() : "Graduation in relevant discipline" %></span></div>
                                        </div>
                                        <div class="detail-row">
                                            <div class="detail-item"><strong>Pattern Summary:</strong> <span id="pattern-<%= exam.getId() %>"><%= exam.getExamPatternSummary() != null ? exam.getExamPatternSummary() : "Objective tests" %></span></div>
                                        </div>
                                        <div class="detail-row">
                                            <div class="detail-item"><strong>Application Window:</strong> <span id="window-<%= exam.getId() %>"><%= exam.getTypicalApplicationWindow() != null ? exam.getTypicalApplicationWindow() : "To be announced" %></span></div>
                                            <div class="detail-item"><strong>Exam Date:</strong> <span id="date-<%= exam.getId() %>"><%= exam.isRollingExam() ? "Any date" : exam.getExamDate() %></span></div>
                                        </div>
                                        
                                        <!-- Hidden parameters for comparison cache -->
                                        <input type="hidden" id="website-<%= exam.getId() %>" value="<%= exam.getOfficialWebsiteUrl() %>">
                                        <input type="hidden" id="syllabus-status-<%= exam.getId() %>" value="<%= exam.getSyllabusAvailabilityStatus() %>">
                                    </div>
                                </div>

                                <div class="rec-actions">
                                    <button class="btn btn-compare-toggle" id="comp-btn-<%= exam.getId() %>" onclick="toggleCompare(<%= exam.getId() %>)">
                                        Compare Side-by-Side
                                    </button>
                                    <button class="btn btn-select" onclick="selectExam(<%= exam.getId() %>)">
                                        Choose Focus &rarr;
                                    </button>
                                </div>
                            </div>
                <% 
                        }
                    } else {
                %>
                        <div class="empty-state">
                            <h3>No exact matches found</h3>
                            <p style="margin-top: 10px;">Consider choosing a different background/goal, or explore custom syllabus planners.</p>
                            <a href="onboarding" class="btn btn-select" style="display: inline-block; margin-top: 15px; text-decoration: none;">Restart Onboarding</a>
                        </div>
                <% 
                    }
                %>
            </div>
        </div>

        <!-- Comparison Section -->
        <div class="glass-card comparison-section" id="comparison-section">
            <h3 style="font-size: 1.3rem; font-weight: 800; margin-bottom: 20px;">Exam Comparison Matrix</h3>
            <div class="comparison-table-wrapper">
                <table class="comparison-table">
                    <thead>
                        <tr id="comp-header-row">
                            <th>Criteria</th>
                            <!-- Dynamic columns go here -->
                        </tr>
                    </thead>
                    <tbody id="comp-body">
                        <!-- Dynamic rows go here -->
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Notification Toast -->
    <div class="toast" id="toast">
        Target focus saved! Loading Syllabus Explorer...
    </div>

    <script>
        const selectedExamsToCompare = [];

        function toggleCompare(examId) {
            const index = selectedExamsToCompare.indexOf(examId);
            const btn = document.getElementById('comp-btn-' + examId);
            
            if (index > -1) {
                // Remove
                selectedExamsToCompare.splice(index, 1);
                btn.classList.remove('checked');
                btn.innerText = "Compare Side-by-Side";
            } else {
                // Add (limit to 3 max)
                if (selectedExamsToCompare.length >= 3) {
                    alert("You can compare a maximum of 3 exams side-by-side.");
                    return;
                }
                selectedExamsToCompare.push(examId);
                btn.classList.add('checked');
                btn.innerText = "Compare (Selected)";
            }

            renderComparisonMatrix();
        }

        function renderComparisonMatrix() {
            const compSection = document.getElementById('comparison-section');
            if (selectedExamsToCompare.length === 0) {
                compSection.style.display = 'none';
                return;
            }

            compSection.style.display = 'block';

            // 1. Reset header row
            const headerRow = document.getElementById('comp-header-row');
            headerRow.innerHTML = '<th class="comparison-header-cell">Criteria</th>';

            selectedExamsToCompare.forEach(id => {
                const name = document.getElementById('name-' + id).innerText;
                headerRow.innerHTML += '<th>' + name + '</th>';
            });

            // 2. Set comparison rows
            const rows = [
                { label: "Conducting Body", idSuffix: "conducting" },
                { label: "Eligibility Criteria", idSuffix: "eligibility" },
                { label: "Exam Pattern", idSuffix: "pattern" },
                { label: "Application Window", idSuffix: "window" },
                { label: "Target Exam Date", idSuffix: "date" },
                { label: "Official URL", idSuffix: "website", isLink: true },
                { label: "Syllabus Status", idSuffix: "syllabus-status" }
            ];

            const tbody = document.getElementById('comp-body');
            tbody.innerHTML = '';

            rows.forEach(row => {
                let html = '<tr><td><strong>' + row.label + '</strong></td>';
                selectedExamsToCompare.forEach(id => {
                    let value = '';
                    if (row.idSuffix === 'syllabus-status') {
                        value = document.getElementById(row.idSuffix + '-' + id).value;
                    } else if (row.idSuffix === 'website') {
                        value = document.getElementById(row.idSuffix + '-' + id).value;
                    } else {
                        value = document.getElementById(row.idSuffix + '-' + id).innerText;
                    }

                    if (row.isLink && value) {
                        html += '<td><a href="' + value + '" target="_blank" style="color: var(--accent-primary);">' + value + '</a></td>';
                    } else {
                        html += '<td>' + (value || 'N/A') + '</td>';
                    }
                });
                html += '</tr>';
                tbody.innerHTML += html;
            });
        }

        function selectExam(examId) {
            // Send AJAX POST selection mapping to /exams
            const xhr = new XMLHttpRequest();
            xhr.open("POST", "exams", true);
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        // Success toast
                        const toast = document.getElementById("toast");
                        toast.style.display = "block";
                        setTimeout(() => {
                            window.location.href = "syllabus";
                        }, 1500);
                    } else {
                        alert("Failed to save target selection. Please try again.");
                    }
                }
            };
            xhr.send("examId=" + examId);
        }
    </script>
</body>
</html>
