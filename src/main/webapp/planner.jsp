<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.examora.model.Exam" %>
<%@ page import="com.examora.model.StudyPlan" %>
<%@ page import="com.examora.model.StudyTask" %>
<%@ page import="com.examora.model.Subject" %>
<%@ page import="com.examora.model.Topic" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.LinkedHashMap" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.temporal.ChronoUnit" %>
<%
    Exam activeExam = (Exam) request.getAttribute("activeExam");
    StudyPlan activePlan = (StudyPlan) request.getAttribute("activePlan");
    List<StudyTask> tasksList = (List<StudyTask>) request.getAttribute("tasksList");
    List<Subject> syllabus = (List<Subject>) request.getAttribute("syllabus");
    String username = (String) request.getAttribute("username");

    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("EEE, dd MMM yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Smart Study Planner — EXAMORA</title>
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
            --warning-color: #f59e0b;
            --error-color: #ef4444;
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
                radial-gradient(circle at 10% 20%, rgba(99, 102, 241, 0.08) 0%, transparent 45%),
                radial-gradient(circle at 90% 80%, rgba(168, 85, 247, 0.08) 0%, transparent 45%);
            color: var(--text-primary);
            font-family: var(--font-family);
            min-height: 100vh;
            display: flex;
            overflow-x: hidden;
        }

        /* Sidebar navigation */
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

        .logo-svg {
            width: 32px;
            height: 32px;
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
            gap: 12px;
            padding: 12px 16px;
            color: var(--text-secondary);
            text-decoration: none;
            border-radius: 12px;
            font-weight: 500;
            font-size: 0.95rem;
            transition: all 0.3s;
        }

        .nav-item.active a, .nav-item a:hover {
            color: var(--text-primary);
            background: rgba(99, 102, 241, 0.1);
        }

        .nav-item.active a {
            border-left: 3px solid var(--accent-primary);
            border-radius: 0 12px 12px 0;
            padding-left: 13px;
        }

        .nav-logout {
            margin-top: auto;
        }

        .nav-logout a {
            color: #f87171;
        }

        .nav-logout a:hover {
            background: rgba(239, 68, 68, 0.1);
        }

        /* Main content layout */
        .main-content {
            margin-left: 260px;
            padding: 40px;
            width: calc(100% - 260px);
            min-height: 100vh;
        }

        .header-section {
            margin-bottom: 30px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        h1 {
            font-size: 2.2rem;
            font-weight: 800;
            margin-bottom: 8px;
            letter-spacing: -0.5px;
        }

        .header-desc {
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

        /* Customizer Form Controls */
        .form-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 24px;
            margin-bottom: 24px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        label {
            font-size: 0.85rem;
            font-weight: 600;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.3px;
        }

        input[type="date"], input[type="number"] {
            background: rgba(0, 0, 0, 0.3);
            border: 1px solid var(--card-border);
            border-radius: 10px;
            padding: 12px 16px;
            color: #fff;
            font-size: 0.95rem;
            font-family: inherit;
            outline: none;
            transition: all 0.3s;
        }

        input[type="date"]:focus, input[type="number"]:focus {
            border-color: var(--accent-primary);
            box-shadow: 0 0 10px rgba(99, 102, 241, 0.2);
        }

        .checkbox-group {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-top: 4px;
        }

        .checkbox-tile {
            position: relative;
            display: flex;
            align-items: center;
            justify-content: center;
            border: 1px solid var(--card-border);
            border-radius: 8px;
            padding: 10px 16px;
            cursor: pointer;
            user-select: none;
            transition: all 0.2s;
            font-size: 0.85rem;
            font-weight: 500;
            background: rgba(255, 255, 255, 0.02);
        }

        .checkbox-tile input[type="checkbox"] {
            position: absolute;
            opacity: 0;
            cursor: pointer;
            height: 0;
            width: 0;
        }

        .checkbox-tile:hover {
            border-color: rgba(99, 102, 241, 0.3);
            background: rgba(99, 102, 241, 0.05);
        }

        .checkbox-tile.checked {
            border-color: var(--accent-primary);
            background: rgba(99, 102, 241, 0.15);
            color: #fff;
        }

        /* Syllabus Selector checkboxes */
        .syllabus-selector {
            border: 1px solid var(--card-border);
            border-radius: 16px;
            overflow: hidden;
            background: rgba(0, 0, 0, 0.2);
            margin-top: 10px;
        }

        .subject-selection-header {
            background: rgba(255, 255, 255, 0.02);
            padding: 16px 20px;
            border-bottom: 1px solid var(--card-border);
            font-weight: 700;
            font-size: 0.95rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .topic-selection-list {
            padding: 16px 20px;
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .topic-selection-row {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 10px 14px;
            background: rgba(255, 255, 255, 0.01);
            border: 1px solid rgba(255, 255, 255, 0.02);
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.2s;
        }

        .topic-selection-row:hover {
            background: rgba(255, 255, 255, 0.03);
            border-color: rgba(99, 102, 241, 0.15);
        }

        .topic-selection-row input[type="checkbox"] {
            width: 18px;
            height: 18px;
            accent-color: var(--accent-primary);
            cursor: pointer;
        }

        .topic-sel-label {
            font-size: 0.9rem;
            font-weight: 500;
            display: flex;
            flex-direction: column;
            gap: 2px;
        }

        .topic-sel-desc {
            font-size: 0.75rem;
            color: var(--text-secondary);
        }

        .btn-action {
            background: linear-gradient(135deg, var(--accent-primary) 0%, var(--accent-secondary) 100%);
            border: none;
            color: #fff;
            padding: 14px 28px;
            border-radius: 12px;
            font-size: 1rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
            box-shadow: 0 4px 15px rgba(99, 102, 241, 0.3);
            margin-top: 20px;
            align-self: flex-start;
        }

        .btn-action:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(99, 102, 241, 0.4);
        }

        /* ---------------------------------
           Plan Timeline Dashboard Layout
           --------------------------------- */
        .plan-dashboard-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 24px;
        }

        .plan-meta-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .plan-meta-box {
            background: rgba(255, 255, 255, 0.02);
            border: 1px solid var(--card-border);
            border-radius: 14px;
            padding: 16px 20px;
        }

        .plan-meta-label {
            font-size: 0.75rem;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.3px;
            margin-bottom: 4px;
        }

        .plan-meta-val {
            font-size: 1.15rem;
            font-weight: 700;
            color: #fff;
        }

        /* Weekly Timeline Accordion layout */
        .timeline-container {
            display: flex;
            flex-direction: column;
            gap: 24px;
        }

        .week-block {
            border: 1px solid var(--card-border);
            border-radius: 16px;
            background: rgba(13, 18, 36, 0.3);
            overflow: hidden;
        }

        .week-header {
            background: rgba(255, 255, 255, 0.02);
            padding: 18px 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-weight: 700;
            font-size: 1.1rem;
            cursor: pointer;
            user-select: none;
        }

        .week-header:hover {
            background: rgba(255, 255, 255, 0.04);
        }

        .week-meta {
            font-size: 0.85rem;
            color: var(--text-secondary);
            font-weight: 500;
        }

        .week-body {
            padding: 20px 24px;
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        /* Task Cards */
        .task-card {
            background: rgba(0, 0, 0, 0.2);
            border: 1px solid var(--card-border);
            border-radius: 12px;
            padding: 16px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            transition: all 0.2s;
        }

        .task-card:hover {
            border-color: rgba(255, 255, 255, 0.15);
            background: rgba(255, 255, 255, 0.02);
        }

        /* Color accentuation per task type */
        .task-card.mock-test {
            border-left: 4px solid var(--accent-secondary);
            background: rgba(168, 85, 247, 0.03);
        }

        .task-card.revision {
            border-left: 4px solid var(--info-color);
            background: rgba(59, 130, 246, 0.03);
        }

        .task-card.learning {
            border-left: 4px solid var(--accent-primary);
        }

        .task-details {
            display: flex;
            flex-direction: column;
            gap: 4px;
            max-width: 60%;
        }

        .task-date {
            font-size: 0.8rem;
            color: var(--accent-primary);
            font-weight: 600;
        }

        .task-title {
            font-size: 0.95rem;
            font-weight: 600;
            color: #fff;
        }

        .task-desc {
            font-size: 0.8rem;
            color: var(--text-secondary);
        }

        .task-stats {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .badge {
            font-size: 0.7rem;
            font-weight: 700;
            text-transform: uppercase;
            padding: 4px 8px;
            border-radius: 6px;
            letter-spacing: 0.3px;
        }

        .badge.todo { background: rgba(245, 158, 11, 0.1); color: #f59e0b; }
        .badge.comp { background: rgba(16, 185, 129, 0.1); color: #10b981; }
        
        .badge.type-learn { background: rgba(99, 102, 241, 0.1); color: #818cf8; }
        .badge.type-rev { background: rgba(59, 130, 246, 0.1); color: #60a5fa; }
        .badge.type-mock { background: rgba(168, 85, 247, 0.1); color: #c084fc; }

        .btn-reset-plan {
            background: transparent;
            border: 1px solid rgba(239, 68, 68, 0.3);
            color: #f87171;
            padding: 8px 16px;
            border-radius: 8px;
            font-size: 0.85rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
        }

        .btn-reset-plan:hover {
            background: rgba(239, 68, 68, 0.1);
            border-color: #f87171;
        }

        /* Toast system */
        .toast-container {
            position: fixed;
            bottom: 24px;
            right: 24px;
            z-index: 1000;
        }

        .toast {
            background: rgba(13, 18, 36, 0.95);
            border: 1px solid var(--card-border);
            padding: 16px 24px;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
            backdrop-filter: blur(8px);
            margin-top: 10px;
            display: flex;
            align-items: center;
            gap: 12px;
            transform: translateY(100px);
            opacity: 0;
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            font-size: 0.9rem;
        }

        .toast.show {
            transform: translateY(0);
            opacity: 1;
        }

        .toast.success { border-left: 4px solid var(--success-color); }
        .toast.error { border-left: 4px solid var(--error-color); }
    </style>
</head>
<body>

    <!-- Sidebar navigation -->
    <div class="sidebar">
        <div class="logo-container">
            <svg class="logo-svg" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
                <polygon points="50,5 92,25 92,75 50,95 8,75 8,25" fill="url(#grad)" stroke="rgba(255,255,255,0.15)" stroke-width="2"/>
                <path d="M50 25 L70 45 L60 45 L60 65 L40 65 L40 45 L30 45 Z" fill="white"/>
                <defs>
                    <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">
                        <stop offset="0%" stop-color="#6366f1" />
                        <stop offset="100%" stop-color="#a855f7" />
                    </linearGradient>
                </defs>
            </svg>
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
                <a href="planner">
                    <span>Smart Study Planner</span>
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
        
        <% if (activePlan == null) { %>
            <!-- 1. SETUP WIZARD VIEW -->
            <div class="header-section">
                <div>
                    <h1>Study Strategy Wizard</h1>
                    <p class="header-desc">
                        Target Focus: <strong><%= activeExam.getName() %> (<%= activeExam.getExamYear() %>)</strong>
                    </p>
                </div>
            </div>

            <div class="glass-card">
                <form id="wizard-form" onsubmit="generateStrategy(event)">
                    <input type="hidden" name="examId" value="<%= activeExam.getId() %>">
                    <input type="hidden" name="endDate" value="<%= activeExam.getExamDate() %>">

                    <div class="form-row">
                        <div class="form-group">
                            <label>Plan Start Date</label>
                            <input type="date" name="startDate" id="startDate" required>
                        </div>
                        <div class="form-group">
                            <label>Exam Date (Deadline)</label>
                            <input type="date" value="<%= activeExam.getExamDate() %>" disabled>
                        </div>
                        <div class="form-group">
                            <label>Daily Study Time (Hours)</label>
                            <input type="number" name="dailyHours" min="1" max="24" value="3" required>
                        </div>
                    </div>

                    <div class="form-group" style="margin-bottom: 30px;">
                        <label>Preferred Study Days</label>
                        <div class="checkbox-group">
                            <% 
                                String[] days = {"Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"};
                                for (String d : days) {
                            %>
                                    <label class="checkbox-tile checked" id="label-<%= d %>">
                                        <input type="checkbox" name="preferredDays" value="<%= d %>" checked onchange="toggleTile('<%= d %>')">
                                        <%= d %>
                                    </label>
                            <% } %>
                        </div>
                    </div>

                    <!-- Study Phase Allocation Configuration -->
                    <div class="form-group" style="margin-bottom: 30px;">
                        <label>Study Phase Allocation (Must sum to 100%)</label>
                        <div class="form-row" style="display: flex; gap: 20px;">
                            <div class="form-group" style="flex: 1; margin-bottom: 0;">
                                <label style="font-size: 0.85rem; color: var(--text-secondary); margin-bottom: 6px;">Learn Phase %</label>
                                <input type="number" id="learnPct" name="learnPct" min="0" max="100" value="50" oninput="validateSplits()" required>
                            </div>
                            <div class="form-group" style="flex: 1; margin-bottom: 0;">
                                <label style="font-size: 0.85rem; color: var(--text-secondary); margin-bottom: 6px;">Practice Phase %</label>
                                <input type="number" id="practicePct" name="practicePct" min="0" max="100" value="30" oninput="validateSplits()" required>
                            </div>
                            <div class="form-group" style="flex: 1; margin-bottom: 0;">
                                <label style="font-size: 0.85rem; color: var(--text-secondary); margin-bottom: 6px;">Revision Phase %</label>
                                <input type="number" id="revisionPct" name="revisionPct" min="0" max="100" value="20" oninput="validateSplits()" required>
                            </div>
                        </div>
                        <div id="splits-error" style="color: #ef4444; font-size: 0.85rem; margin-top: 8px; display: none; font-weight: 600;">
                            Percentages must sum to exactly 100% (currently: <span id="splits-sum-lbl">100</span>%).
                        </div>
                    </div>

                    <!-- Milestones Configuration -->
                    <div class="form-group" style="margin-bottom: 30px;">
                        <label>Milestones Configuration & Deadlines (Optional)</label>
                        <p style="font-size: 0.8rem; color: var(--text-secondary); margin-bottom: 12px;">
                            Specify intermediate milestone targets. Leave empty for dynamic auto-calculations.
                        </p>
                        <div class="form-row" style="display: flex; gap: 20px;">
                            <div class="form-group" style="flex: 1; margin-bottom: 0;">
                                <label style="font-size: 0.85rem; color: var(--text-secondary); margin-bottom: 6px;">Syllabus Finish Target</label>
                                <input type="date" id="targetSyllabusDate" name="targetSyllabusDate" style="width: 100%; padding: 12px 16px; border-radius: 8px; background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); color: #fff;">
                            </div>
                            <div class="form-group" style="flex: 1; margin-bottom: 0;">
                                <label style="font-size: 0.85rem; color: var(--text-secondary); margin-bottom: 6px;">PYQ Finish Target</label>
                                <input type="date" id="targetPyqDate" name="targetPyqDate" style="width: 100%; padding: 12px 16px; border-radius: 8px; background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.1); color: #fff;">
                            </div>
                            <div class="form-group" style="flex: 1; margin-bottom: 0;">
                                <label style="font-size: 0.85rem; color: var(--text-secondary); margin-bottom: 6px;">Revision Buffer (Days)</label>
                                <input type="number" id="revisionBufferDays" name="revisionBufferDays" min="1" max="60" value="14">
                            </div>
                        </div>
                    </div>

                    <!-- Syllabus Scope Selection Checkboxes -->
                    <div class="form-group">
                        <label>Syllabus Target Scope</label>
                        <p style="font-size: 0.8rem; color: var(--text-secondary); margin-bottom: 12px;">
                            Uncheck subjects or modules you want to exclude from this specific schedule generation.
                        </p>

                        <% 
                            if (syllabus != null) {
                                for (Subject subject : syllabus) {
                        %>
                                    <div class="syllabus-selector" style="margin-bottom: 20px;">
                                        <div class="subject-selection-header">
                                            <span><%= subject.getName() %></span>
                                            <span style="font-size: 0.8rem; color: var(--text-secondary); font-weight: normal;">
                                                <a href="#" onclick="toggleSubjectChecks(<%= subject.getId() %>, true); return false;" style="color: var(--accent-primary); text-decoration: none; margin-right: 12px;">Check All</a>
                                                <a href="#" onclick="toggleSubjectChecks(<%= subject.getId() %>, false); return false;" style="color: #f87171; text-decoration: none;">Clear All</a>
                                            </span>
                                        </div>
                                        <div class="topic-selection-list">
                                            <% 
                                                for (Topic topic : subject.getTopics()) {
                                            %>
                                                    <label class="topic-selection-row">
                                                        <input type="checkbox" class="subj-check-<%= subject.getId() %>" name="selectedTopics" value="<%= topic.getId() %>" checked>
                                                        <div class="topic-sel-label">
                                                            <span><%= topic.getName() %></span>
                                                            <span class="topic-sel-desc"><%= topic.getDescription() %></span>
                                                        </div>
                                                    </label>
                                            <% } %>
                                        </div>
                                    </div>
                        <% 
                                }
                            } 
                        %>
                    </div>

                    <button type="submit" class="btn-action">Generate Study Strategy</button>
                </form>
            </div>

        <% } else { %>
            <!-- 2. ACTIVE PLAN TIMELINE VIEW -->
            <div class="header-section">
                <div>
                    <h1>My Study Strategy</h1>
                    <p class="header-desc">
                        Adaptive plan configured for <strong><%= activeExam.getName() %></strong>.
                    </p>
                </div>
                <button class="btn-reset-plan" onclick="resetActivePlan()">Re-configure Strategy</button>
            </div>

            <!-- Meta statistics row -->
            <%
                long totalStudyDays = ChronoUnit.DAYS.between(activePlan.getStartDate(), activePlan.getEndDate()) + 1;
            %>
            <div class="plan-meta-grid">
                <div class="plan-meta-box">
                    <div class="plan-meta-label">Plan Start Date</div>
                    <div class="plan-meta-val"><%= activePlan.getStartDate() %></div>
                </div>
                <div class="plan-meta-box">
                    <div class="plan-meta-label">Target Exam Date</div>
                    <div class="plan-meta-val"><%= activePlan.getEndDate() %></div>
                </div>
                <div class="plan-meta-box">
                    <div class="plan-meta-label">Duration Timeframe</div>
                    <div class="plan-meta-val"><%= totalStudyDays %> Days</div>
                </div>
                <div class="plan-meta-box">
                    <div class="plan-meta-label">Daily study load</div>
                    <div class="plan-meta-val"><%= activePlan.getDailyStudyHours() %> Hours/Day</div>
                </div>
            </div>

            <!-- Chronological tasks list grouped by week -->
            <div class="timeline-container">
                <% 
                    if (tasksList != null && !tasksList.isEmpty()) {
                        // Map tasks by week (7 days blocks relative to plan start date)
                        LocalDate planStart = activePlan.getStartDate();
                        Map<Integer, List<StudyTask>> weeklyTasks = new LinkedHashMap<>();

                        for (StudyTask task : tasksList) {
                            long daysOffset = ChronoUnit.DAYS.between(planStart, task.getScheduledDate());
                            int weekNumber = (int) (daysOffset / 7) + 1;
                            
                            weeklyTasks.computeIfAbsent(weekNumber, k -> new ArrayList<>()).add(task);
                        }

                        for (Map.Entry<Integer, List<StudyTask>> entry : weeklyTasks.entrySet()) {
                            int week = entry.getKey();
                            List<StudyTask> weekTasks = entry.getValue();
                            LocalDate wStart = planStart.plusDays((week - 1) * 7);
                            LocalDate wEnd = wStart.plusDays(6);
                            if (wEnd.isAfter(activePlan.getEndDate())) {
                                wEnd = activePlan.getEndDate();
                            }
                %>
                            <div class="week-block" id="week-<%= week %>">
                                <div class="week-header" onclick="toggleWeek(<%= week %>)">
                                    <span>Week <%= week %></span>
                                    <span class="week-meta">
                                        <%= wStart.format(dateFormatter) %> — <%= wEnd.format(dateFormatter) %> 
                                        (<%= weekTasks.size() %> Tasks)
                                    </span>
                                </div>
                                <div class="week-body" id="week-body-<%= week %>">
                                    <% 
                                        for (StudyTask task : weekTasks) {
                                            String cardClass = "learning";
                                            String typeLabel = "Learning Block";
                                            String typeBadge = "type-learn";
                                            
                                            String mode = task.getTaskMode();
                                            if ("PRACTICE".equalsIgnoreCase(mode) || task.isMockTest()) {
                                                cardClass = "mock-test";
                                                typeLabel = "Practice & PYQs";
                                                typeBadge = "type-mock";
                                            } else if ("REVISION".equalsIgnoreCase(mode) || task.isRevision()) {
                                                cardClass = "revision";
                                                typeLabel = "Revision Cycle";
                                                typeBadge = "type-rev";
                                            }
                                    %>
                                            <div class="task-card <%= cardClass %>">
                                                <div class="task-details">
                                                    <span class="task-date">
                                                        <%= task.getScheduledDate().format(dateFormatter) %>
                                                    </span>
                                                    <span class="task-title">
                                                        <%= task.getTopicName() %>
                                                    </span>
                                                    <span class="task-desc">
                                                        Subject: <strong><%= task.getSubjectName() %></strong> &bull; 
                                                        Type: <%= typeLabel %>
                                                        <% if (task.getAllocationExplanation() != null) { %>
                                                            <div style="font-size: 0.75rem; color: var(--text-secondary); margin-top: 6px; padding-top: 6px; border-top: 1px solid rgba(255,255,255,0.05); font-style: italic; line-height: 1.3;">
                                                                ℹ️ <%= task.getAllocationExplanation() %>
                                                            </div>
                                                        <% } %>
                                                    </span>
                                                </div>
                                                <div class="task-stats">
                                                    <span class="badge <%= typeBadge %>"><%= typeLabel %></span>
                                                    <span class="badge todo"><%= task.getScheduledHours() %>h Allocation</span>
                                                    <span class="badge status-todo"><%= task.getStatus() %></span>
                                                </div>
                                            </div>
                                    <% 
                                        } 
                                    %>
                                </div>
                            </div>
                <% 
                        }
                    } else {
                %>
                        <div class="glass-card" style="text-align: center; color: var(--text-secondary);">
                            No tasks scheduled in the timeline database.
                        </div>
                <% 
                    } 
                %>
            </div>
        <% } %>
        
    </div>

    <!-- Toasts Box -->
    <div class="toast-container" id="toast-box"></div>

    <script>
        // Set default start date to today
        window.addEventListener('DOMContentLoaded', () => {
            const dateInput = document.getElementById('startDate');
            if (dateInput) {
                const today = new Date().toISOString().split('T')[0];
                dateInput.value = today;
                dateInput.min = today; // Restrict starting plans in the past
            }
        });

        function toggleTile(dayId) {
            const tile = document.getElementById(`label-${dayId}`);
            tile.classList.toggle('checked');
        }

        function toggleSubjectChecks(subjectId, checkedState) {
            const checkboxes = document.querySelectorAll(`.subj-check-${subjectId}`);
            checkboxes.forEach(cb => cb.checked = checkedState);
        }

        function toggleWeek(weekId) {
            const body = document.getElementById(`week-body-${weekId}`);
            if (body.style.display === 'none') {
                body.style.display = 'flex';
            } else {
                body.style.display = 'none';
            }
        }

        function showToast(message, type = 'success') {
            const container = document.getElementById('toast-box');
            const toast = document.createElement('div');
            toast.className = `toast ${type}`;
            toast.innerText = message;
            container.appendChild(toast);
            
            setTimeout(() => toast.classList.add('show'), 50);
            
            setTimeout(() => {
                toast.classList.remove('show');
                setTimeout(() => toast.remove(), 400);
            }, 3000);
        }

        function generateStrategy(event) {
            event.preventDefault();
            const form = document.getElementById('wizard-form');
            const formData = new FormData(form);

            const params = new URLSearchParams();
            for (const pair of formData.entries()) {
                params.append(pair[0], pair[1]);
            }

            // Grab multi-select checkboxes specifically (since FormData may not capture them correctly in URLSearchParams)
            const preferredDays = [];
            document.querySelectorAll('input[name="preferredDays"]:checked').forEach(cb => {
                preferredDays.push(cb.value);
            });
            params.delete('preferredDays');
            preferredDays.forEach(day => params.append('preferredDays', day));

            const selectedTopics = [];
            document.querySelectorAll('input[name="selectedTopics"]:checked').forEach(cb => {
                selectedTopics.push(cb.value);
            });
            params.delete('selectedTopics');
            selectedTopics.forEach(topicId => params.append('selectedTopics', topicId));

            fetch('planner', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'Accept': 'application/json'
                },
                body: params.toString()
            })
            .then(async response => {
                const data = await response.json();
                if (response.ok && data.status === 'SUCCESS') {
                    showToast(data.message, 'success');
                    setTimeout(() => {
                        window.location.reload();
                    }, 1200);
                } else {
                    throw new Error(data.message || 'Generation failed.');
                }
            })
            .catch(error => {
                showToast(error.message, 'error');
            });
        }

        function resetActivePlan() {
            if (confirm("Are you sure you want to deactivate and re-configure your study planner? This will archive your current timeline.")) {
                // Post to reset the active plan status by submitting an empty selectTopics (triggering reset) or creating a custom action.
                // For simplicity, we can create a POST request parameter action=RESET
                const params = new URLSearchParams();
                params.append('examId', '<%= (activePlan != null) ? activePlan.getExamId() : 0 %>');
                params.append('startDate', '<%= LocalDate.now() %>');
                params.append('endDate', '<%= (activePlan != null) ? activePlan.getEndDate() : LocalDate.now() %>');
                params.append('dailyHours', '3');
                
                // Submit empty topics selection list to trigger a clean deactivation/reset
                fetch('planner', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                        'Accept': 'application/json'
                    },
                    body: "examId=0&startDate=2000-01-01&endDate=2000-01-01&dailyHours=3&selectedTopics=" // Will fail validation but we can customize handling in doPost
                });
                
                // For direct DB deactivation, we can force redirect to a reset flow or just clean the user_exams active flag.
                // Let's redirect to a simple query param trigger to delete the plan in Servlet.
                // Wait! A cleaner way is to handle "action=RESET" in doPost!
                // Let's implement that: POST with action=RESET will archive the plan.
                fetch('planner', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: 'action=RESET' // Handled in Servlet
                })
                .then(() => {
                    window.location.reload();
                });
            }
        }

        function validateSplits() {
            const l = parseInt(document.getElementById('learnPct').value) || 0;
            const p = parseInt(document.getElementById('practicePct').value) || 0;
            const r = parseInt(document.getElementById('revisionPct').value) || 0;
            const sum = l + p + r;
            
            const errorDiv = document.getElementById('splits-error');
            const sumLbl = document.getElementById('splits-sum-lbl');
            const submitBtn = document.querySelector('button[type=\"submit\"]') || document.querySelector('.btn-submit') || document.querySelector('#wizard-form button');
            
            sumLbl.innerText = sum;
            if (sum !== 100) {
                errorDiv.style.display = 'block';
                if (submitBtn) submitBtn.disabled = true;
            } else {
                errorDiv.style.display = 'none';
                if (submitBtn) submitBtn.disabled = false;
            }
        }
    </script>
</body>
</html>
