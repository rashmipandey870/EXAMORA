<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.examora.model.Exam" %>
<%@ page import="com.examora.model.StudyPlan" %>
<%@ page import="com.examora.model.StudyTask" %>
<%@ page import="com.examora.model.DeadlineEvent" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.temporal.ChronoUnit" %>
<%
    Exam activeExam = (Exam) request.getAttribute("activeExam");
    boolean hasActivePlan = (Boolean) request.getAttribute("hasActivePlan");
    StudyPlan activePlan = (StudyPlan) request.getAttribute("activePlan");
    List<StudyTask> todayTasks = (List<StudyTask>) request.getAttribute("todayTasks");
    Map<String, Object> metrics = (Map<String, Object>) request.getAttribute("metrics");
    List<StudyTask> weakTopics = (List<StudyTask>) request.getAttribute("weakTopics");
    List<DeadlineEvent> deadlineEvents = (List<DeadlineEvent>) request.getAttribute("deadlineEvents");
    Long daysRemaining = (Long) request.getAttribute("daysRemaining");
    String username = (String) request.getAttribute("username");

    double percentComplete = 0.0;
    int totalTasks = 0;
    int completedTasks = 0;
    double totalHours = 0.0;
    double completedHours = 0.0;

    int currentStreak = 0;
    int longestStreak = 0;
    List<Map<String, Object>> weeklyMetrics = null;

    if (hasActivePlan && metrics != null) {
        totalTasks = (Integer) metrics.get("totalTasks");
        completedTasks = (Integer) metrics.get("completedTasks");
        totalHours = (Double) metrics.get("totalHours");
        completedHours = (Double) metrics.get("completedHours");
        if (totalHours > 0) {
            percentComplete = (completedHours / totalHours) * 100;
        }

        Map<String, Integer> streaksMap = (Map<String, Integer>) request.getAttribute("streaks");
        if (streaksMap != null) {
            currentStreak = streaksMap.getOrDefault("currentStreak", 0);
            longestStreak = streaksMap.getOrDefault("longestStreak", 0);
        }
        weeklyMetrics = (List<Map<String, Object>>) request.getAttribute("weeklyMetrics");
    }

    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("EEEE, dd MMMM yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard — EXAMORA</title>
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

        /* Main layout container */
        .main-content {
            margin-left: 260px;
            padding: 40px;
            width: calc(100% - 260px);
            min-height: 100vh;
        }

        .welcome-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 30px;
        }

        .welcome-title h1 {
            font-size: 2rem;
            font-weight: 800;
            letter-spacing: -0.5px;
            margin-bottom: 6px;
        }

        .date-badge {
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid var(--card-border);
            padding: 8px 16px;
            border-radius: 10px;
            font-size: 0.85rem;
            color: var(--text-secondary);
            font-weight: 500;
        }

        .glass-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4);
            backdrop-filter: blur(12px);
            margin-bottom: 30px;
            position: relative;
            overflow: hidden;
        }

        /* Empty state styling */
        .empty-state {
            text-align: center;
            padding: 50px 30px;
        }

        .empty-state h2 {
            font-size: 1.5rem;
            margin-bottom: 12px;
            font-weight: 750;
        }

        .empty-state p {
            color: var(--text-secondary);
            max-width: 500px;
            margin: 0 auto 24px;
            font-size: 0.95rem;
            line-height: 1.5;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--accent-primary) 0%, var(--accent-secondary) 100%);
            border: none;
            color: #fff;
            padding: 12px 24px;
            border-radius: 10px;
            font-size: 0.95rem;
            font-weight: 700;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            box-shadow: 0 4px 15px rgba(99, 102, 241, 0.3);
            transition: all 0.3s;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(99, 102, 241, 0.4);
        }

        /* 3-Column Stats Grid */
        .stats-grid {
            display: grid;
            grid-template-columns: 1.8fr 1.1fr 1.1fr;
            gap: 20px;
            margin-bottom: 30px;
        }

        @media (max-width: 1024px) {
            .stats-grid {
                grid-template-columns: 1fr;
            }
        }

        .stats-card-main {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .stats-info {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .exam-info-header {
            font-size: 0.8rem;
            font-weight: 600;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .exam-info-title {
            font-size: 1.7rem;
            font-weight: 800;
            color: #fff;
        }

        .countdown-large {
            display: flex;
            align-items: baseline;
            gap: 8px;
            margin-top: 10px;
        }

        .countdown-num {
            font-size: 3.5rem;
            font-weight: 900;
            background: linear-gradient(135deg, #818cf8 0%, #c084fc 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .countdown-label {
            font-size: 1rem;
            color: var(--text-secondary);
            font-weight: 600;
        }

        /* Radial Progress Ring */
        .progress-ring-container {
            position: relative;
            width: 140px;
            height: 140px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .progress-ring-circle {
            transition: stroke-dashoffset 0.35s;
            transform: rotate(-90deg);
            transform-origin: 50% 50%;
        }

        .progress-ring-val {
            position: absolute;
            font-size: 1.4rem;
            font-weight: 800;
            color: #fff;
        }

        /* Tasks Layout */
        .dashboard-row-grid {
            display: grid;
            grid-template-columns: 1.2fr 0.8fr;
            gap: 30px;
        }

        .section-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
        }

        .section-title {
            font-size: 1.2rem;
            font-weight: 750;
            color: #fff;
            letter-spacing: -0.3px;
        }

        .section-link {
            font-size: 0.85rem;
            color: var(--accent-primary);
            text-decoration: none;
            font-weight: 600;
            transition: color 0.2s;
        }

        .section-link:hover {
            color: var(--accent-secondary);
        }

        .tasks-list {
            display: flex;
            flex-direction: column;
            gap: 14px;
        }

        .task-row {
            background: rgba(255, 255, 255, 0.02);
            border: 1px solid var(--card-border);
            border-radius: 14px;
            padding: 16px 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            transition: all 0.3s;
        }

        .task-row:hover {
            background: rgba(255, 255, 255, 0.04);
            border-color: rgba(255, 255, 255, 0.12);
        }

        .task-row.task-completed {
            border-color: rgba(16, 185, 129, 0.2);
            background: rgba(16, 185, 129, 0.02);
            opacity: 0.75;
        }

        .task-row-details {
            display: flex;
            flex-direction: column;
            gap: 4px;
            max-width: 70%;
        }

        .task-row-title {
            font-size: 0.95rem;
            font-weight: 600;
            color: #fff;
            transition: all 0.2s;
        }

        .task-completed .task-row-title {
            text-decoration: line-through;
            color: var(--text-secondary);
        }

        .task-row-desc {
            font-size: 0.8rem;
            color: var(--text-secondary);
        }

        /* Checkbox slider styles */
        .check-container {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .toggle-btn {
            background: transparent;
            border: 1px solid var(--card-border);
            color: var(--text-secondary);
            padding: 8px 14px;
            border-radius: 8px;
            font-size: 0.8rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
        }

        .toggle-btn.btn-completed {
            background: rgba(16, 185, 129, 0.1);
            border-color: var(--success-color);
            color: var(--success-color);
        }

        .toggle-btn:hover {
            border-color: var(--accent-primary);
            color: #fff;
        }

        .toggle-btn.btn-completed:hover {
            border-color: #f87171;
            color: #f87171;
            background: rgba(239, 68, 68, 0.1);
        }

        /* Weak topics layout */
        .weak-list {
            display: flex;
            flex-direction: column;
            gap: 14px;
        }

        .weak-card {
            background: rgba(239, 68, 68, 0.02);
            border: 1px solid rgba(239, 68, 68, 0.15);
            border-radius: 14px;
            padding: 16px 20px;
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .weak-card-title {
            font-size: 0.95rem;
            font-weight: 600;
            color: #fff;
        }

        .weak-card-desc {
            font-size: 0.8rem;
            color: var(--text-secondary);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .badge {
            font-size: 0.65rem;
            font-weight: 700;
            text-transform: uppercase;
            padding: 3px 6px;
            border-radius: 4px;
            letter-spacing: 0.3px;
        }

        .badge.weak-prio-high { background: rgba(239, 68, 68, 0.1); color: #f87171; }
        .badge.weak-prio-med { background: rgba(245, 158, 11, 0.1); color: #fbbf24; }

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
    <!-- Chart.js CDN -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
            <li class="nav-item active">
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
            <li class="nav-item">
                <a href="planner">
                    <span>Smart Study Planner</span>
                </a>
            </li>
            <li class="nav-item">
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
        
        <div class="welcome-header">
            <div class="welcome-title">
                <h1>Welcome back, <%= username %>!</h1>
                <p style="color: var(--text-secondary);">Here is your dynamic study target progress briefing.</p>
            </div>
            <div class="date-badge">
                <%= LocalDate.now().format(dateFormatter) %>
            </div>
        </div>

        <%
            // 1. Check for unverified dates warning
            boolean showDateWarning = !activeExam.isVerifiedDates();
            
            // 2. Check for close deadlines (within 14 days)
            DeadlineEvent criticalEvent = null;
            if (deadlineEvents != null) {
                for (DeadlineEvent event : deadlineEvents) {
                    if ("APPLICATION_CLOSE".equalsIgnoreCase(event.getEventType())) {
                        long daysToClose = ChronoUnit.DAYS.between(LocalDate.now(), event.getEventDate());
                        if (daysToClose >= 0 && daysToClose <= 14) {
                            criticalEvent = event;
                            break;
                        }
                    }
                }
            }
        %>
        
        <% if (showDateWarning) { %>
            <div class="glass-card" style="border-left: 4px solid var(--warning-color); padding: 16px 20px; display: flex; align-items: center; gap: 12px; margin-bottom: 25px; background: rgba(245, 158, 11, 0.08); border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.2);">
                <span style="font-size: 1.2rem;">⚠️</span>
                <div>
                    <strong style="color: #fff; font-size: 0.95rem;">Tentative Deadlines Warning</strong>
                    <p style="color: var(--text-secondary); font-size: 0.88rem; margin-top: 2px;">
                        Dates for <strong><%= activeExam.getName() %></strong> are based on previous year's pattern — confirm on the official site (<a href="<%= activeExam.getOfficialWebsiteUrl() %>" target="_blank" style="color: var(--accent-primary);"><%= activeExam.getOfficialWebsiteUrl() %></a>).
                    </p>
                </div>
            </div>
        <% } %>

        <% if (criticalEvent != null) { %>
            <div class="glass-card" style="border-left: 4px solid var(--error-color); padding: 16px 20px; display: flex; align-items: center; gap: 12px; margin-bottom: 25px; background: rgba(239, 68, 68, 0.08); border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.2);">
                <span style="font-size: 1.2rem;">🚨</span>
                <div>
                    <strong style="color: #fff; font-size: 0.95rem;">Urgent Deadline Warning!</strong>
                    <p style="color: var(--text-secondary); font-size: 0.88rem; margin-top: 2px;">
                        <strong><%= activeExam.getName() %> <%= criticalEvent.getEventType().replace("_", " ") %></strong> is in 
                        <strong style="color: #f87171;"><%= ChronoUnit.DAYS.between(LocalDate.now(), criticalEvent.getEventDate()) %> days</strong> 
                        (Date: <%= criticalEvent.getEventDate() %>). Complete your registration immediately!
                    </p>
                </div>
            </div>
        <% } %>

        <% if (!hasActivePlan) { %>
            <!-- 1. EMPTY STATE FOR NO ACTIVE STUDY PLAN -->
            <div class="glass-card empty-state">
                <h2>No Active Study Strategy found</h2>
                <p>
                    Turn your targeted syllabus into a personalized study plan. Configure dates, select study hours, choose specific topics, and generate an adaptive study schedule.
                </p>
                <a href="planner" class="btn-primary">Configure Study Strategy</a>
            </div>

            <!-- Basic Exam Info / Countdown -->
            <div class="glass-card" style="display: flex; justify-content: space-between; align-items: center;">
                <div>
                    <div class="exam-info-header">Current Focus Exam</div>
                    <div class="exam-info-title"><%= activeExam.getName() %> (<%= activeExam.getExamYear() %>)</div>
                    <div style="color: var(--text-secondary); margin-top: 8px;">
                        Exam Date: <strong><%= activeExam.getExamDate() %></strong>
                    </div>
                </div>
                <div class="countdown-large">
                    <span class="countdown-num"><%= daysRemaining %></span>
                    <span class="countdown-label">Days Left</span>
                </div>
            </div>

            <!-- Exam Timeline & Deadlines Widget (No active plan) -->
            <div style="margin-top: 25px;">
                <div class="section-header">
                    <h3 class="section-title">Exam Timeline & Deadlines</h3>
                </div>
                <div class="glass-card" style="padding: 24px; border-radius: 16px; box-shadow: 0 4px 15px rgba(0,0,0,0.3);">
                    <% if (deadlineEvents != null && !deadlineEvents.isEmpty()) { %>
                        <div style="display: flex; flex-direction: column; gap: 20px;">
                            <% for (DeadlineEvent event : deadlineEvents) { 
                                String label = event.getEventType().replace("_", " ");
                                boolean isPast = event.getEventDate().isBefore(LocalDate.now());
                                String textStyle = isPast ? "color: var(--text-secondary); text-decoration: line-through;" : "color: #fff;";
                                String dotBg = isPast ? "background: #4b5563;" : ("APPLICATION_CLOSE".equalsIgnoreCase(event.getEventType()) ? "background: var(--error-color);" : "background: var(--accent-primary);");
                            %>
                                <div style="display: flex; gap: 14px; align-items: flex-start; <%= textStyle %>">
                                    <div style="width: 10px; height: 10px; border-radius: 50%; <%= dotBg %> margin-top: 5px; flex-shrink: 0; box-shadow: 0 0 8px rgba(255,255,255,0.15);"></div>
                                    <div>
                                        <div style="font-size: 0.9rem; font-weight: 700; text-transform: capitalize;"><%= label.toLowerCase() %></div>
                                        <div style="font-size: 0.78rem; color: var(--text-secondary); margin-top: 4px;">
                                            <%= event.getEventDate() %> &bull; <%= event.isEstimated() ? "Estimated (Tentative)" : "Verified Official" %>
                                        </div>
                                    </div>
                                </div>
                            <% } %>
                        </div>
                    <% } else { %>
                        <div style="text-align: center; color: var(--text-secondary); font-size: 0.9rem; padding: 20px 0;">
                            No deadline events registered for this exam.
                        </div>
                    <% } %>
                </div>
            </div>

        <% } else { %>
            <!-- 2. FULL INTERACTIVE DASHBOARD VIEW -->
            <div class="stats-grid">
                <!-- Main Focus Card -->
                <div class="glass-card stats-card-main">
                    <div class="stats-info">
                        <span class="exam-info-header">Focus Examination Focus</span>
                        <h2 class="exam-info-title"><%= activeExam.getName() %> (<%= activeExam.getExamYear() %>)</h2>
                        <div class="countdown-large">
                            <span class="countdown-num"><%= daysRemaining %></span>
                            <span class="countdown-label">Days Until Exam</span>
                        </div>
                    </div>

                    <!-- Circular Progress Ring -->
                    <div class="progress-ring-container">
                        <svg width="120" height="120">
                            <circle stroke="rgba(255, 255, 255, 0.05)" stroke-width="8" fill="transparent" r="50" cx="60" cy="60"/>
                            <circle class="progress-ring-circle" id="radial-progress-ring" 
                                    stroke="url(#glow-gradient)" stroke-width="8" 
                                    stroke-dasharray="314.16" stroke-dashoffset="314.16"
                                    stroke-linecap="round" fill="transparent" r="50" cx="60" cy="60"/>
                            <defs>
                                <linearGradient id="glow-gradient" x1="0%" y1="0%" x2="100%" y2="100%">
                                    <stop offset="0%" stop-color="#6366f1" />
                                    <stop offset="100%" stop-color="#a855f7" />
                                </linearGradient>
                            </defs>
                        </svg>
                        <span class="progress-ring-val" id="progress-val-text">0%</span>
                    </div>
                </div>

                <!-- Secondary Summary Card -->
                <div class="glass-card" style="display: flex; flex-direction: column; justify-content: center; gap: 14px;">
                    <div>
                        <div class="exam-info-header" style="margin-bottom: 4px;">Completed Hours</div>
                        <div style="font-size: 1.5rem; font-weight: 800;" id="stats-hours-val">
                            <%= completedHours %> / <%= totalHours %>h
                        </div>
                    </div>
                    <div style="border-top: 1px solid var(--card-border); padding-top: 14px;">
                        <div class="exam-info-header" style="margin-bottom: 4px;">Tasks Done</div>
                        <div style="font-size: 1.3rem; font-weight: 700;" id="stats-tasks-val">
                            <%= completedTasks %> / <%= totalTasks %> Tasks
                        </div>
                    </div>
                </div>

                <!-- Streak Card -->
                <div class="glass-card" style="display: flex; flex-direction: column; justify-content: space-between; gap: 14px;">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                        <div>
                            <div class="exam-info-header" style="margin-bottom: 4px;">Current Streak</div>
                            <div style="font-size: 2.2rem; font-weight: 900; color: #f97316; display: flex; align-items: center; gap: 6px;">
                                <span>🔥</span>
                                <span id="current-streak-val"><%= currentStreak %></span>
                                <span style="font-size: 1rem; font-weight: 700; color: var(--text-secondary);">days</span>
                            </div>
                        </div>
                        <div style="background: rgba(249, 115, 22, 0.1); padding: 4px 8px; border-radius: 6px; font-size: 0.75rem; font-weight: 700; color: #f97316; border: 1px solid rgba(249, 115, 22, 0.2);">
                            Active
                        </div>
                    </div>
                    <div style="border-top: 1px solid var(--card-border); padding-top: 14px; display: flex; align-items: center; justify-content: space-between;">
                        <div style="display: flex; align-items: center; gap: 8px;">
                            <span style="font-size: 1.2rem;">🏆</span>
                            <div>
                                <div class="exam-info-header" style="font-size: 0.7rem; text-transform: none;">Personal Best</div>
                                <div style="font-size: 0.95rem; font-weight: 800; color: #eab308;"><%= longestStreak %> Day Streak</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Unified Progress Dashboard Gauges -->
            <%
                Double weightedSyllabusCompletion = (Double) request.getAttribute("weightedSyllabusCompletion");
                Double pyqAttemptsRatio = (Double) request.getAttribute("pyqAttemptsRatio");
                Integer revisionDueCount = (Integer) request.getAttribute("revisionDueCount");
                if (weightedSyllabusCompletion == null) weightedSyllabusCompletion = 0.0;
                if (pyqAttemptsRatio == null) pyqAttemptsRatio = 0.0;
                if (revisionDueCount == null) revisionDueCount = 0;
            %>
            <div style="margin-bottom: 30px; display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px;">
                <!-- Syllabus Completion Gauge -->
                <div class="glass-card" style="padding: 20px; display: flex; flex-direction: column; justify-content: space-between; border-color: rgba(99, 102, 241, 0.15); margin-bottom: 0;">
                    <div>
                        <div class="exam-info-header" style="margin-bottom: 6px;">Weighted Syllabus Completion</div>
                        <div style="font-size: 1.8rem; font-weight: 900; color: #818cf8; margin-bottom: 8px;">
                            <%= String.format("%.1f", weightedSyllabusCompletion) %>%
                        </div>
                    </div>
                    <div style="background: rgba(255,255,255,0.05); height: 8px; border-radius: 4px; overflow: hidden; width: 100%;">
                        <div style="background: linear-gradient(90deg, #6366f1, #818cf8); height: 100%; width: <%= weightedSyllabusCompletion %>%;"></div>
                    </div>
                </div>

                <!-- PYQ Attempts Gauge -->
                <div class="glass-card" style="padding: 20px; display: flex; flex-direction: column; justify-content: space-between; border-color: rgba(16, 185, 129, 0.15); margin-bottom: 0;">
                    <div>
                        <div class="exam-info-header" style="margin-bottom: 6px;">PYQ Year Attempts Ratio</div>
                        <div style="font-size: 1.8rem; font-weight: 900; color: #34d399; margin-bottom: 8px;">
                            <%= String.format("%.1f", pyqAttemptsRatio) %>%
                        </div>
                    </div>
                    <div style="background: rgba(255,255,255,0.05); height: 8px; border-radius: 4px; overflow: hidden; width: 100%;">
                        <div style="background: linear-gradient(90deg, #10b981, #34d399); height: 100%; width: <%= pyqAttemptsRatio %>%;"></div>
                    </div>
                </div>

                <!-- Revision Due Gauge -->
                <div class="glass-card" style="padding: 20px; display: flex; flex-direction: column; justify-content: space-between; border-color: rgba(239, 68, 68, 0.15); margin-bottom: 0;">
                    <div>
                        <div class="exam-info-header" style="margin-bottom: 6px;">Revision Tasks Due</div>
                        <div style="font-size: 1.8rem; font-weight: 900; color: #f87171; margin-bottom: 8px;">
                            <%= revisionDueCount %> Overdue
                        </div>
                    </div>
                    <div style="font-size: 0.75rem; color: var(--text-secondary); line-height: 1.3;">
                        <%= revisionDueCount > 0 ? "⚠️ Catch up on your spaced repetition backlog!" : "🎉 Spaced repetition schedule is completely clear!" %>
                    </div>
                </div>
            </div>

            <!-- Weekly Progress Chart -->
            <div class="glass-card" style="margin-bottom: 30px; padding: 24px;">
                <div class="section-header" style="margin-bottom: 20px;">
                    <h3 class="section-title" style="display: flex; align-items: center; gap: 8px;">
                        <span>📈 Weekly Study Performance</span>
                        <span style="font-size: 0.85rem; font-weight: normal; color: var(--text-secondary);">(Last 7 Days)</span>
                    </h3>
                </div>
                <div style="position: relative; height: 260px; width: 100%;">
                    <canvas id="weeklyPerformanceChart"></canvas>
                </div>
            </div>

            <!-- Schedule & Weak Areas details -->
            <div class="dashboard-row-grid">
                
                <!-- Today's Target List -->
                <div>
                    <div class="section-header">
                        <h3 class="section-title">Today's Study Targets</h3>
                        <a href="planner" class="section-link">View Full Timeline &rarr;</a>
                    </div>

                    <div class="tasks-list" id="targets-box">
                        <% 
                            if (todayTasks != null && !todayTasks.isEmpty()) {
                                for (StudyTask task : todayTasks) {
                                    boolean isComp = "COMPLETED".equalsIgnoreCase(task.getStatus());
                                    String completeClass = isComp ? "task-completed" : "";
                                    String btnText = isComp ? "Mark Pending" : "Complete Task";
                                    String btnClass = isComp ? "btn-completed" : "";
                        %>
                                    <div class="task-row <%= completeClass %>" id="task-row-<%= task.getId() %>">
                                        <div class="task-row-details">
                                            <span class="task-row-title" id="task-title-<%= task.getId() %>">
                                                <%= task.getTopicName() %>
                                            </span>
                                            <span class="task-row-desc">
                                                Subject: <strong><%= task.getSubjectName() %></strong> &bull; 
                                                Type: <%= task.isMockTest() ? "Mock Test" : (task.isRevision() ? "Revision" : "Learning Block") %>
                                            </span>
                                        </div>
                                        <div class="check-container">
                                            <span class="badge" style="background: rgba(99, 102, 241, 0.1); color: #818cf8; margin-right: 8px;">
                                                <%= task.getScheduledHours() %>h Load
                                            </span>
                                            <button class="toggle-btn <%= btnClass %>" 
                                                    id="toggle-btn-<%= task.getId() %>"
                                                    onclick="toggleTaskStatus(<%= task.getId() %>, '<%= task.getStatus() %>', <%= task.getScheduledHours() %>)">
                                                <%= btnText %>
                                            </button>
                                        </div>
                                    </div>
                        <% 
                                }
                            } else {
                        %>
                                <div class="glass-card" style="text-align: center; color: var(--text-secondary); padding: 40px;">
                                    No targets scheduled for today. Take rest, or catch up on pending backlog! 🛋️
                                </div>
                        <% 
                            } 
                        %>
                    </div>
                </div>

                <!-- Weak Areas / Backlog Spotlights -->
                <div>
                    <div class="section-header">
                        <h3 class="section-title">Weakness Focus Priority</h3>
                        <a href="syllabus" class="section-link">Explore Trends</a>
                    </div>

                    <div class="weak-list">
                        <% 
                            if (weakTopics != null && !weakTopics.isEmpty()) {
                                for (StudyTask weak : weakTopics) {
                                    String badgeClass = "weak-prio-med";
                                    String priorityLabel = weak.getPriority() != null ? weak.getPriority() : "MEDIUM";
                                    if ("VERY HIGH".equalsIgnoreCase(priorityLabel) || "HIGH".equalsIgnoreCase(priorityLabel)) {
                                        badgeClass = "weak-prio-high";
                                    }
                        %>
                                    <div class="weak-card">
                                        <span class="weak-card-title"><%= weak.getTopicName() %></span>
                                        <div class="weak-card-desc">
                                            <span>Subject: <strong><%= weak.getSubjectName() %></strong></span>
                                            <span class="badge <%= badgeClass %>"><%= priorityLabel %> Priority</span>
                                        </div>
                                    </div>
                        <% 
                                }
                            } else {
                        %>
                                <div class="glass-card" style="text-align: center; color: var(--text-secondary); padding: 40px; border-color: rgba(16, 185, 129, 0.15);">
                                    All topics currently scheduled/studied successfully! 🎉
                                </div>
                        <% 
                            } 
                        %>
                    </div>
                </div>

                <!-- Weak Topics Rollup (Accuracy-based) -->
                <div style="margin-top: 30px;">
                    <div class="section-header">
                        <h3 class="section-title">Weak Topics Rollup (Practice Accuracy)</h3>
                        <a href="practice" class="section-link">Solve PYQs</a>
                    </div>

                    <div class="weak-list">
                        <% 
                            List<java.util.Map<String, Object>> weakestTopicsList = (List<java.util.Map<String, Object>>) request.getAttribute("weakestTopics");
                            if (weakestTopicsList != null && !weakestTopicsList.isEmpty()) {
                                for (java.util.Map<String, Object> weak : weakestTopicsList) {
                                    double accuracy = (Double) weak.get("accuracy");
                                    int totalCount = (Integer) weak.get("totalCount");
                                    int correctCount = (Integer) weak.get("correctCount");
                                    String topicName = (String) weak.get("topicName");
                                    String subjectName = (String) weak.get("subjectName");
                                    
                                    String accuracyBadgeClass = "weak-prio-med";
                                    if (accuracy < 0.5) {
                                        accuracyBadgeClass = "weak-prio-high";
                                    }
                        %>
                                    <div class="weak-card">
                                        <span class="weak-card-title"><%= topicName %></span>
                                        <div class="weak-card-desc">
                                            <span>Subject: <strong><%= subjectName %></strong></span>
                                            <span class="badge <%= accuracyBadgeClass %>" style="background: rgba(239, 68, 68, 0.15); color: #f87171; border: 1px solid rgba(239, 68, 68, 0.2);">
                                                Accuracy: <%= String.format("%.0f", accuracy * 100) %>% (<%= correctCount %>/<%= totalCount %>)
                                            </span>
                                        </div>
                                    </div>
                        <% 
                                }
                            } else {
                        %>
                                <div class="glass-card" style="text-align: center; color: var(--text-secondary); padding: 40px;">
                                    No practice answer attempts recorded yet. Solve questions in the Practice Solver to identify weak spots!
                                </div>
                        <% 
                            } 
                        %>
                    </div>
                </div>

                <!-- Exam Timeline & Deadlines Widget -->
                <div style="margin-top: 30px;">
                    <div class="section-header">
                        <h3 class="section-title">Exam Timeline & Deadlines</h3>
                    </div>
                    <div class="glass-card" style="padding: 24px; border-radius: 16px; box-shadow: 0 4px 15px rgba(0,0,0,0.3); margin-bottom: 0;">
                        <% if (deadlineEvents != null && !deadlineEvents.isEmpty()) { %>
                            <div style="display: flex; flex-direction: column; gap: 20px;">
                                <% for (DeadlineEvent event : deadlineEvents) { 
                                    String label = event.getEventType().replace("_", " ");
                                    boolean isPast = event.getEventDate().isBefore(LocalDate.now());
                                    String textStyle = isPast ? "color: var(--text-secondary); text-decoration: line-through;" : "color: #fff;";
                                    String dotBg = isPast ? "background: #4b5563;" : ("APPLICATION_CLOSE".equalsIgnoreCase(event.getEventType()) ? "background: var(--error-color);" : "background: var(--accent-primary);");
                                %>
                                    <div style="display: flex; gap: 14px; align-items: flex-start; <%= textStyle %>">
                                        <div style="width: 10px; height: 10px; border-radius: 50%; <%= dotBg %> margin-top: 5px; flex-shrink: 0; box-shadow: 0 0 8px rgba(255,255,255,0.15);"></div>
                                        <div>
                                            <div style="font-size: 0.9rem; font-weight: 700; text-transform: capitalize;"><%= label.toLowerCase() %></div>
                                            <div style="font-size: 0.78rem; color: var(--text-secondary); margin-top: 6px; display: flex; flex-direction: column; gap: 4px;">
                                                <div>Date: <strong style="color: #fff;"><%= event.getEventDate() %></strong></div>
                                                <div style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap;">
                                                    <% if (event.isEstimated()) { %>
                                                        <span style="background: rgba(245, 158, 11, 0.15); color: #fbbf24; border: 1px solid rgba(245, 158, 11, 0.2); font-size: 0.7rem; font-weight: 700; padding: 1px 6px; border-radius: 4px;">Estimated (Pattern-Derived)</span>
                                                        <span>Confirm at: <a href="<%= event.getSource() %>" target="_blank" style="color: var(--accent-secondary); text-decoration: underline;"><%= event.getSource().replace("https://", "").replace("http://", "") %></a></span>
                                                    <% } else { %>
                                                        <span style="background: rgba(16, 185, 129, 0.15); color: #34d399; border: 1px solid rgba(16, 185, 129, 0.2); font-size: 0.7rem; font-weight: 700; padding: 1px 6px; border-radius: 4px;">Verified Official</span>
                                                        <span>Source: <a href="<%= event.getSource() %>" target="_blank" style="color: var(--success-color); text-decoration: underline;"><%= event.getSource().replace("https://", "").replace("http://", "") %></a></span>
                                                    <% } %>
                                                    <% if (event.getLastCheckedAt() != null) { %>
                                                        <span style="color: var(--text-secondary); font-size: 0.7rem;">&bull; Checked: <%= java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd").format(event.getLastCheckedAt()) %></span>
                                                    <% } %>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                <% } %>
                            </div>
                        <% } else { %>
                            <div style="text-align: center; color: var(--text-secondary); font-size: 0.9rem; padding: 20px 0;">
                                No deadline events registered for this exam.
                            </div>
                        <% } %>
                    </div>
                </div>

            </div>
        <% } %>

    </div>

    <!-- Toasts Box -->
    <div class="toast-container" id="toast-box"></div>

    <script>
        // Progress Ring variables
        const percent = <%= percentComplete %>;
        
        window.addEventListener('DOMContentLoaded', () => {
            updateRadialProgress(percent);
        });

        function updateRadialProgress(percentage) {
            const ring = document.getElementById('radial-progress-ring');
            if (ring) {
                const radius = ring.r.baseVal.value;
                const circumference = 2 * Math.PI * radius;
                const offset = circumference - (percentage / 100) * circumference;
                ring.style.strokeDashoffset = offset;
                
                // Update percentage text
                document.getElementById('progress-val-text').innerText = Math.round(percentage) + '%';
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

        function toggleTaskStatus(taskId, currentStatus, hours) {
            const row = document.getElementById(`task-row-${taskId}`);
            const btn = document.getElementById(`toggle-btn-${taskId}`);
            
            const isCompleting = (currentStatus !== 'COMPLETED');
            const newAction = isCompleting ? 'complete' : 'pending';

            fetch('dashboard', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: `taskId=${taskId}&action=${newAction}`
            })
            .then(async response => {
                const data = await response.json();
                if (response.ok) {
                    showToast(data.message, 'success');
                    
                    // Toggle visual classes
                    if (isCompleting) {
                        row.classList.add('task-completed');
                        btn.innerText = 'Mark Pending';
                        btn.classList.add('btn-completed');
                        btn.setAttribute('onclick', `toggleTaskStatus(${taskId}, 'COMPLETED', ${hours})`);
                    } else {
                        row.classList.remove('task-completed');
                        btn.innerText = 'Complete Task';
                        btn.classList.remove('btn-completed');
                        btn.setAttribute('onclick', `toggleTaskStatus(${taskId}, 'PENDING', ${hours})`);
                    }

                    // Recalculate dynamic hours and tasks stats values
                    updateStatsInRealTime(hours, isCompleting);
                } else {
                    throw new Error(data.message || 'Operation failed.');
                }
            })
            .catch(error => {
                showToast(error.message, 'error');
            });
        }

        function updateStatsInRealTime(hours, isCompleting) {
            // Read current stats values
            const hoursValText = document.getElementById('stats-hours-val');
            const tasksValText = document.getElementById('stats-tasks-val');

            if (!hoursValText || !tasksValText) return;

            // Parse: completedHours / totalHours
            const hoursParts = hoursValText.innerText.replace('h', '').split(' / ');
            let compHours = parseFloat(hoursParts[0]);
            let totHours = parseFloat(hoursParts[1]);

            // Parse: completedTasks / totalTasks
            const tasksParts = tasksValText.innerText.replace(' Tasks', '').split(' / ');
            let compTasks = parseInt(tasksParts[0]);
            let totTasks = parseInt(tasksParts[1]);

            // Adjust
            if (isCompleting) {
                compHours = Math.min(totHours, compHours + hours);
                compTasks = Math.min(totTasks, compTasks + 1);
            } else {
                compHours = Math.max(0.0, compHours - hours);
                compTasks = Math.max(0, compTasks - 1);
            }

            // Update text
            hoursValText.innerText = `${compHours.toFixed(1)} / ${totHours}h`;
            tasksValText.innerText = `${compTasks} / ${totTasks} Tasks`;

            // Update radial percentage
            const newPercentage = totHours > 0 ? (compHours / totHours) * 100 : 0.0;
            updateRadialProgress(newPercentage);

            // Update Chart.js in real time if it exists
            if (typeof weeklyChart !== 'undefined' && weeklyChart) {
                // Fetch all completed hours for last 7 days and sum them up
                // For simplicity, we can update today's completed hours on the chart
                const lastIdx = weeklyChart.data.datasets[0].data.length - 1;
                if (lastIdx >= 0) {
                    // Calculate the today's completion offset
                    // Read the daily completed tasks sum and update the last day point
                    // Let's query completed tasks from UI row states
                    let todayCompletedHours = 0;
                    document.querySelectorAll('.task-row').forEach(row => {
                        if (row.classList.contains('task-completed')) {
                            // Find the hour load from the badge
                            const badge = row.querySelector('.badge');
                            if (badge) {
                                const hVal = parseFloat(badge.innerText.replace('h Load', '').trim());
                                if (!isNaN(hVal)) {
                                    todayCompletedHours += hVal;
                                }
                            }
                        }
                    });
                    weeklyChart.data.datasets[0].data[lastIdx] = todayCompletedHours;
                    weeklyChart.update();
                }
            }
        }

        // Global Chart.js instance variable
        let weeklyChart = null;

        <%
            StringBuilder labelsJson = new StringBuilder("[");
            StringBuilder scheduledHoursJson = new StringBuilder("[");
            StringBuilder completedHoursJson = new StringBuilder("[");
            if (weeklyMetrics != null) {
                for (int i = 0; i < weeklyMetrics.size(); i++) {
                    Map<String, Object> day = weeklyMetrics.get(i);
                    LocalDate d = (LocalDate) day.get("date");
                    double sH = (Double) day.get("scheduledHours");
                    double cH = (Double) day.get("completedHours");
                    
                    String formattedDate = d.format(java.time.format.DateTimeFormatter.ofPattern("MMM dd"));
                    labelsJson.append("\"").append(formattedDate).append("\"");
                    scheduledHoursJson.append(sH);
                    completedHoursJson.append(cH);
                    
                    if (i < weeklyMetrics.size() - 1) {
                        labelsJson.append(",");
                        scheduledHoursJson.append(",");
                        completedHoursJson.append(",");
                    }
                }
            }
            labelsJson.append("]");
            scheduledHoursJson.append("]");
            completedHoursJson.append("]");
        %>

        // Initialize chart on page load
        window.addEventListener('DOMContentLoaded', () => {
            <% if (hasActivePlan && weeklyMetrics != null) { %>
                const ctx = document.getElementById('weeklyPerformanceChart').getContext('2d');
                
                // Gradients for area fills
                const compGradient = ctx.createLinearGradient(0, 0, 0, 240);
                compGradient.addColorStop(0, 'rgba(168, 85, 247, 0.3)');
                compGradient.addColorStop(1, 'rgba(168, 85, 247, 0)');

                const schedGradient = ctx.createLinearGradient(0, 0, 0, 240);
                schedGradient.addColorStop(0, 'rgba(99, 102, 241, 0.15)');
                schedGradient.addColorStop(1, 'rgba(99, 102, 241, 0)');

                weeklyChart = new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: <%= labelsJson.toString() %>,
                        datasets: [
                            {
                                label: 'Completed Hours',
                                data: <%= completedHoursJson.toString() %>,
                                borderColor: '#a855f7',
                                borderWidth: 3,
                                backgroundColor: compGradient,
                                fill: true,
                                tension: 0.35,
                                pointBackgroundColor: '#a855f7',
                                pointBorderColor: '#fff',
                                pointHoverRadius: 6,
                                pointHoverBackgroundColor: '#a855f7',
                                pointHoverBorderColor: '#fff',
                                pointHoverBorderWidth: 2
                            },
                            {
                                label: 'Scheduled Target',
                                data: <%= scheduledHoursJson.toString() %>,
                                borderColor: 'rgba(99, 102, 241, 0.6)',
                                borderWidth: 2,
                                borderDash: [5, 5],
                                backgroundColor: schedGradient,
                                fill: true,
                                tension: 0.35,
                                pointBackgroundColor: 'rgba(99, 102, 241, 0.6)',
                                pointBorderColor: 'transparent',
                                pointHoverRadius: 4
                            }
                        ]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {
                                position: 'top',
                                labels: {
                                    color: '#9ca3af',
                                    font: {
                                        family: 'Inter, system-ui, sans-serif',
                                        size: 12,
                                        weight: '600'
                                    },
                                    boxWidth: 15,
                                    padding: 15
                                }
                            },
                            tooltip: {
                                backgroundColor: 'rgba(11, 13, 27, 0.95)',
                                titleColor: '#fff',
                                bodyColor: '#9ca3af',
                                borderColor: 'rgba(255, 255, 255, 0.1)',
                                borderWidth: 1,
                                padding: 12,
                                cornerRadius: 8,
                                titleFont: { family: 'Inter, sans-serif', weight: 'bold' },
                                bodyFont: { family: 'Inter, sans-serif' },
                                callbacks: {
                                    label: function(context) {
                                        return ' ' + context.dataset.label + ': ' + context.raw + ' hrs';
                                    }
                                }
                            }
                        },
                        scales: {
                            x: {
                                grid: {
                                    color: 'rgba(255, 255, 255, 0.03)',
                                    borderColor: 'transparent'
                                },
                                ticks: {
                                    color: '#9ca3af',
                                    font: { family: 'Inter, sans-serif', size: 11 }
                                }
                            },
                            y: {
                                grid: {
                                    color: 'rgba(255, 255, 255, 0.05)',
                                    borderColor: 'transparent'
                                },
                                ticks: {
                                    color: '#9ca3af',
                                    font: { family: 'Inter, sans-serif', size: 11 },
                                    callback: function(value) {
                                        return value + 'h';
                                    }
                                },
                                suggestedMax: 6,
                                beginAtZero: true
                            }
                        }
                    }
                });
            <% } %>
        });
    </script>
</body>
</html>
