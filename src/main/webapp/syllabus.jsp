<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.examora.model.Exam" %>
<%@ page import="com.examora.model.Subject" %>
<%@ page import="com.examora.model.Unit" %>
<%@ page import="com.examora.model.Topic" %>
<%@ page import="com.examora.model.SubTopic" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.temporal.ChronoUnit" %>
<%@ page import="java.time.LocalDate" %>
<%
    Exam activeExam = (Exam) request.getAttribute("activeExam");
    List<Subject> syllabus = (List<Subject>) request.getAttribute("syllabus");
    List<Topic> highYieldTopics = (List<Topic>) request.getAttribute("highYieldTopics");

    // Calculate days remaining
    long daysRemaining = 0;
    if (activeExam != null && activeExam.getExamDate() != null) {
        daysRemaining = ChronoUnit.DAYS.between(LocalDate.now(), activeExam.getExamDate());
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Syllabus Explorer — EXAMORA</title>
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

        /* Main Workspace Container */
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

        /* Info Widget Panels */
        .dashboard-grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 30px;
            align-items: start;
        }

        .widgets-column {
            display: flex;
            flex-direction: column;
            gap: 24px;
        }

        .glass-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            padding: 24px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4);
            backdrop-filter: blur(12px);
        }

        /* Countdown Widget styling */
        .countdown-widget {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .countdown-title {
            font-size: 0.9rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: var(--text-secondary);
            margin-bottom: 4px;
        }

        .countdown-value {
            font-size: 2rem;
            font-weight: 800;
            color: #fff;
        }

        .countdown-days {
            font-size: 2.8rem;
            font-weight: 800;
            background: linear-gradient(135deg, var(--accent-primary) 0%, var(--accent-secondary) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        /* Progress ring widget */
        .progress-card {
            text-align: center;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .progress-ring-container {
            position: relative;
            width: 120px;
            height: 120px;
            margin-bottom: 16px;
        }

        .progress-ring-circle {
            transform: rotate(-90deg);
            transform-origin: 50% 50%;
        }

        .progress-text {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            font-size: 1.5rem;
            font-weight: 800;
            color: #fff;
        }

        /* Tab buttons styling */
        .tab-btn.active::after {
            content: '';
            position: absolute;
            bottom: -13px;
            left: 16px;
            right: 16px;
            height: 3px;
            background: linear-gradient(90deg, var(--accent-primary), var(--accent-secondary));
            border-radius: 2px;
        }

        /* Accordion subjects explorer */
        .syllabus-tree {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .subject-card {
            border: 1px solid var(--card-border);
            border-radius: 16px;
            background: rgba(13, 18, 36, 0.4);
            overflow: hidden;
            transition: all 0.3s;
        }

        .subject-card:hover {
            border-color: rgba(255, 255, 255, 0.15);
            background: rgba(13, 18, 36, 0.6);
        }

        .subject-header {
            padding: 20px 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            cursor: pointer;
            user-select: none;
        }

        .subject-title {
            font-size: 1.15rem;
            font-weight: 700;
            color: var(--text-primary);
        }

        .subject-meta {
            font-size: 0.85rem;
            color: var(--text-secondary);
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .arrow-icon {
            transition: transform 0.3s;
        }

        .subject-card.expanded .arrow-icon {
            transform: rotate(180deg);
        }

        .subject-body {
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.4s ease-out;
            border-top: 0 solid var(--card-border);
            background: rgba(0, 0, 0, 0.2);
        }

        .subject-card.expanded .subject-body {
            max-height: 1000px; /* arbitrary height to slide open */
            border-top-width: 1px;
        }

        .topics-list {
            padding: 16px 24px;
            display: flex;
            flex-direction: column;
            gap: 14px;
        }

        .topic-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 12px 16px;
            background: rgba(255, 255, 255, 0.02);
            border: 1px solid rgba(255, 255, 255, 0.04);
            border-radius: 12px;
            transition: all 0.2s;
        }

        .topic-row:hover {
            background: rgba(255, 255, 255, 0.04);
            border-color: rgba(99, 102, 241, 0.15);
        }

        .topic-info {
            display: flex;
            flex-direction: column;
            gap: 4px;
            max-width: 60%;
        }

        .topic-name {
            font-size: 0.95rem;
            font-weight: 600;
            color: #fff;
        }

        .topic-desc {
            font-size: 0.8rem;
            color: var(--text-secondary);
        }

        .topic-badges {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .badge {
            font-size: 0.7rem;
            font-weight: 700;
            text-transform: uppercase;
            padding: 4px 8px;
            border-radius: 6px;
            letter-spacing: 0.3px;
        }

        .badge.easy { background: rgba(16, 185, 129, 0.12); color: #34d399; }
        .badge.medium { background: rgba(245, 158, 11, 0.12); color: #fbbf24; }
        .badge.hard { background: rgba(239, 68, 68, 0.12); color: #f87171; }
        
        .badge.prio-vhigh { background: rgba(168, 85, 247, 0.15); color: #c084fc; border: 1px solid rgba(168, 85, 247, 0.25); }
        .badge.prio-high { background: rgba(99, 102, 241, 0.15); color: #818cf8; }
        .badge.prio-med { background: rgba(59, 130, 246, 0.15); color: #60a5fa; }
        
        .badge.status-todo { background: rgba(255, 255, 255, 0.05); color: var(--text-secondary); }

        .btn-info {
            background: rgba(255, 255, 255, 0.04);
            border: 1px solid rgba(255, 255, 255, 0.06);
            color: var(--text-secondary);
            width: 28px;
            height: 28px;
            border-radius: 50%;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 0.85rem;
            font-weight: 700;
            transition: all 0.2s;
        }

        .btn-info:hover {
            background: rgba(99, 102, 241, 0.2);
            color: #fff;
            border-color: var(--accent-primary);
        }

        /* 3D Glassmorphic Intelligence Modal */
        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100vw;
            height: 100vh;
            background: rgba(0, 0, 0, 0.7);
            backdrop-filter: blur(8px);
            z-index: 1000;
            opacity: 0;
            pointer-events: none;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: opacity 0.3s ease;
        }

        .modal-overlay.show {
            opacity: 1;
            pointer-events: auto;
        }

        .modal-card {
            background: rgba(13, 18, 36, 0.9);
            border: 1px solid rgba(255, 255, 255, 0.12);
            border-radius: 24px;
            width: 90%;
            max-width: 500px;
            padding: 32px;
            box-shadow: 0 30px 60px rgba(0, 0, 0, 0.8);
            transform: scale(0.9) translateY(20px);
            transition: transform 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            text-align: left;
        }

        .modal-overlay.show .modal-card {
            transform: scale(1) translateY(0);
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 24px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.08);
            padding-bottom: 16px;
        }

        .modal-close {
            background: transparent;
            border: none;
            color: var(--text-secondary);
            font-size: 1.5rem;
            cursor: pointer;
            transition: color 0.2s;
        }

        .modal-close:hover {
            color: #fff;
        }

        .modal-title {
            font-size: 1.25rem;
            font-weight: 800;
            color: #fff;
        }

        .modal-subtitle {
            font-size: 0.85rem;
            color: var(--text-secondary);
            margin-top: 4px;
        }

        .trend-metric-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
            margin-bottom: 20px;
        }

        .trend-metric-box {
            background: rgba(0, 0, 0, 0.2);
            border: 1px solid rgba(255, 255, 255, 0.05);
            border-radius: 12px;
            padding: 12px 16px;
        }

        .trend-metric-label {
            font-size: 0.75rem;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.3px;
            margin-bottom: 4px;
        }

        .trend-metric-val {
            font-size: 0.95rem;
            font-weight: 700;
            color: #fff;
        }

        /* Sourcing Provenance display styling */
        .provenance-card {
            background: rgba(99, 102, 241, 0.05);
            border: 1px solid rgba(99, 102, 241, 0.15);
            border-radius: 12px;
            padding: 16px;
            margin-top: 20px;
            font-size: 0.8rem;
            line-height: 1.5;
        }

        .provenance-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 8px;
            font-weight: 600;
            color: #818cf8;
        }

        .provenance-status {
            font-size: 0.65rem;
            font-weight: 700;
            text-transform: uppercase;
            padding: 2px 6px;
            border-radius: 4px;
            background: rgba(16, 185, 129, 0.15);
            color: #34d399;
        }

        .provenance-link {
            color: #fff;
            text-decoration: none;
            display: block;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            margin-top: 6px;
        }

        .provenance-link:hover {
            text-decoration: underline;
            color: var(--accent-primary);
        }
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
            <li class="nav-item active">
                <a href="syllabus">
                    <span>Syllabus Explorer</span>
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
        <div class="header-section">
            <div>
                <h1>Syllabus Explorer</h1>
                <p class="header-desc">
                    Active Targeted Focus: <strong><%= activeExam.getName() %> (<%= activeExam.getExamYear() %>)</strong>
                </p>
            </div>
        </div>

        <!-- Tabs Switcher -->
        <div class="tabs-container" style="display: flex; gap: 16px; margin-bottom: 24px; border-bottom: 1px solid var(--card-border); padding-bottom: 12px;">
            <button class="tab-btn active" id="tab-hierarchy" onclick="switchTab('hierarchy')" style="background: none; border: none; color: #fff; font-weight: 700; font-size: 1rem; cursor: pointer; padding: 8px 16px; position: relative;">Standard Syllabus Tree</button>
            <button class="tab-btn" id="tab-highyield" onclick="switchTab('highyield')" style="background: none; border: none; color: var(--text-secondary); font-weight: 700; font-size: 1rem; cursor: pointer; padding: 8px 16px; position: relative;">High-Yield Rankings 🚀</button>
        </div>

        <div class="syllabus-tree">
            <!-- 1. STANDARD HIERARCHY TREE VIEW -->
            <div id="hierarchy-view">
                <%
                    if (syllabus != null) {
                        for (Subject subject : syllabus) {
                            // Sum topics count across all units in this subject
                            int totalSubjectTopics = subject.getUnits().stream().mapToInt(u -> u.getTopics().size()).sum();
                %>
                            <div class="subject-card" id="subj-<%= subject.getId() %>" style="margin-bottom: 18px;">
                                <div class="subject-header" onclick="toggleSubject(<%= subject.getId() %>)">
                                    <div class="subject-title"><%= subject.getName() %></div>
                                    <div class="subject-meta">
                                        <span><%= totalSubjectTopics %> Modules</span>
                                        <svg class="arrow-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <polyline points="6 9 12 15 18 9"/>
                                        </svg>
                                    </div>
                                </div>
                                
                                <div class="subject-body" style="max-height: 2000px;">
                                    <div class="topics-list" style="padding: 20px 24px;">
                                        <%
                                            for (Unit unit : subject.getUnits()) {
                                        %>
                                                <!-- Unit Sub-Group -->
                                                <div style="margin-top: 15px; margin-bottom: 15px; border-left: 3px solid var(--accent-secondary); padding-left: 14px;">
                                                    <h4 style="font-size: 1.05rem; font-weight: 700; color: #a855f7;"><%= unit.getName() %></h4>
                                                    <p style="font-size: 0.82rem; color: var(--text-secondary); margin-top: 2px;"><%= unit.getDescription() %></p>
                                                </div>

                                                <%
                                                    for (Topic topic : unit.getTopics()) {
                                                        // Determine badges difficulty/priority
                                                        String diffClass = topic.getDifficulty().toLowerCase();
                                                        String prioClass = "prio-med";
                                                        if ("VERY HIGH".equals(topic.getPriority())) prioClass = "prio-vhigh";
                                                        else if ("HIGH".equals(topic.getPriority())) prioClass = "prio-high";
                                                %>
                                                        <div class="topic-row" style="flex-direction: column; align-items: stretch; gap: 8px; cursor: pointer; margin-bottom: 10px;" onclick="toggleTopicDetail(<%= topic.getId() %>)">
                                                            <div style="display: flex; justify-content: space-between; align-items: center; width: 100%;">
                                                                <div class="topic-info" style="max-width: 70%;">
                                                                    <span class="topic-name"><%= topic.getName() %></span>
                                                                    <span class="topic-desc"><%= topic.getDescription() %></span>
                                                                </div>
                                                                <div class="topic-badges" style="display: flex; align-items: center; gap: 8px;">
                                                                    <span class="badge <%= diffClass %>"><%= topic.getDifficulty() %></span>
                                                                    <span class="badge <%= prioClass %>"><%= topic.getPriority() %> Priority</span>
                                                                    <button class="btn-info" onclick="event.stopPropagation(); openTrendIntel('<%= topic.getName().replace("'", "\\'") %>', '<%= topic.getDifficulty() %>', '<%= topic.getPriority() %>', '<%= topic.getRecentFrequency() %>', '<%= topic.getYearsAppeared() %>', <%= topic.getNumberOfQuestions() %>, '<%= topic.getVerificationStatus() %>', '<%= topic.getTrendSourceTitle() %>', '<%= topic.getTrendSourceUrl() %>', '<%= topic.getTrendRetrievedAt() != null ? topic.getTrendRetrievedAt().toString() : "N/A" %>')">&quest;</button>
                                                                </div>
                                                            </div>

                                                            <!-- Nested subtopics & prerequisites detail container -->
                                                            <div class="topic-detail-expanded" id="topic-detail-<%= topic.getId() %>" style="display: none; padding: 12px 0 4px 0; border-top: 1px solid rgba(255,255,255,0.05); margin-top: 6px;" onclick="event.stopPropagation()">
                                                                <div style="display: flex; justify-content: space-between; align-items: center; font-size: 0.8rem; margin-bottom: 12px; color: var(--text-secondary); width: 100%;">
                                                                    <div style="display: flex; gap: 20px;">
                                                                        <span>Prep Time: <strong style="color: #fff;"><%= topic.getEstimatedHours() %> Hours</strong></span>
                                                                        <span>Weightage: <strong style="color: #fff;"><%= topic.getWeightage() != null ? topic.getWeightage() + "%" : "N/A" %></strong></span>
                                                                        <span>Yield Index: <strong style="color: var(--success-color);"><%= String.format("%.3f", topic.getComputedYieldScore()) %></strong></span>
                                                                    </div>
                                                                    <a href="notes?topicId=<%= topic.getId() %>" style="background: linear-gradient(135deg, var(--accent-primary) 0%, var(--accent-secondary) 100%); color: #fff; padding: 6px 14px; border-radius: 8px; text-decoration: none; font-weight: 700; font-size: 0.78rem; box-shadow: 0 4px 10px rgba(99,102,241,0.25);">Study Notes &rarr;</a>
                                                                </div>
                                                                
                                                                <% if (topic.getPrerequisites() != null && !topic.getPrerequisites().isEmpty()) { %>
                                                                    <div style="margin-bottom: 10px; font-size: 0.85rem;">
                                                                        <strong style="color: var(--warning-color);">Prerequisites:</strong> 
                                                                        <span style="color: #f3f4f6;"><%= String.join(", ", topic.getPrerequisites()) %></span>
                                                                    </div>
                                                                <% } %>
                                                                
                                                                <% if (topic.getSubTopics() != null && !topic.getSubTopics().isEmpty()) { %>
                                                                    <div style="font-size: 0.85rem;">
                                                                        <strong style="color: var(--accent-primary);">Sub-topics Coverage:</strong>
                                                                        <ul style="list-style: disc; margin-left: 20px; margin-top: 6px; display: flex; flex-direction: column; gap: 6px;">
                                                                            <% for (SubTopic sub : topic.getSubTopics()) { %>
                                                                                <li>
                                                                                    <strong style="color: #fff;"><%= sub.getName() %></strong> 
                                                                                    <% if (sub.getDescription() != null && !sub.getDescription().isEmpty()) { %>
                                                                                        <span style="color: var(--text-secondary);">&mdash; <%= sub.getDescription() %></span>
                                                                                    <% } %>
                                                                                </li>
                                                                            <% } %>
                                                                        </ul>
                                                                    </div>
                                                                <% } %>
                                                            </div>
                                                        </div>
                                                <%
                                                    }
                                                %>
                                        <%
                                            }
                                        %>
                                    </div>
                                </div>
                            </div>
                <%
                        }
                    }
                %>
            </div>

            <!-- 2. HIGH-YIELD PRIORITY RANKING VIEW -->
            <div id="highyield-view" style="display: none; animation: fadeIn 0.4s ease;">
                <div class="glass-card" style="padding: 24px; border-radius: 16px;">
                    <h3 style="font-size: 1.25rem; font-weight: 800; margin-bottom: 8px;">Top High-Yield Priority Rankings</h3>
                    <p style="font-size: 0.88rem; color: var(--text-secondary); margin-bottom: 24px;">
                        Dynamically ranked according to efficiency index: <code style="color: var(--accent-primary); background: rgba(0,0,0,0.3); padding: 2px 6px; border-radius: 4px;">Weightage / Prep Time</code>. Focus on top slots first!
                    </p>
                    <div class="topics-list" style="padding: 0; gap: 12px;">
                        <%
                            int rank = 1;
                            if (highYieldTopics != null) {
                                for (Topic topic : highYieldTopics) {
                                    String yieldFormatted = String.format("%.3f", topic.getComputedYieldScore());
                        %>
                                    <div class="topic-row" style="gap: 16px; align-items: center; justify-content: space-between;">
                                        <div style="display: flex; align-items: center; gap: 16px; flex-grow: 1;">
                                            <div style="font-size: 1.3rem; font-weight: 800; color: var(--accent-secondary); width: 32px; text-align: center;">
                                                #<%= rank++ %>
                                            </div>
                                            <div class="topic-info">
                                                <span class="topic-name" style="font-size: 0.95rem;"><%= topic.getName() %></span>
                                                <span class="topic-desc">Weightage: <strong><%= topic.getWeightage() != null ? topic.getWeightage() + "%" : "N/A" %></strong> &bull; Estimated Prep: <strong><%= topic.getEstimatedHours() %> Hours</strong></span>
                                            </div>
                                        </div>
                                        <div class="topic-badges" style="display: flex; align-items: center; gap: 8px;">
                                            <span class="badge" style="background: rgba(99, 102, 241, 0.15); color: #818cf8; border: 1px solid rgba(99, 102, 241, 0.2); font-weight: 700;">
                                                Yield: <%= yieldFormatted %>
                                            </span>
                                            <span class="badge <%= "VERY HIGH".equals(topic.getPriority()) ? "prio-vhigh" : ("HIGH".equals(topic.getPriority()) ? "prio-high" : "prio-med") %>"><%= topic.getPriority() %> Priority</span>
                                        </div>
                                    </div>
                        <%
                                }
                            }
                        %>
                    </div>
                </div>
            </div>

            <!-- Right Column: Info Widgets -->
            <div class="widgets-column">
                <!-- Countdown Card -->
                <div class="glass-card countdown-widget">
                    <div>
                        <div class="countdown-title">Target Date Countdown</div>
                        <div class="countdown-value"><%= activeExam.getExamDate() %></div>
                    </div>
                    <div class="countdown-days">
                        <%= daysRemaining %>d
                    </div>
                </div>

                <!-- Progress Tracker Ring Card -->
                <div class="glass-card progress-card">
                    <div class="countdown-title" style="align-self: flex-start; margin-bottom: 16px;">Syllabus Coverage</div>
                    <div class="progress-ring-container">
                        <svg width="120" height="120">
                            <circle class="progress-ring-circle" stroke="rgba(255,255,255,0.03)" stroke-width="10" fill="transparent" r="50" cx="60" cy="60"/>
                            <circle class="progress-ring-circle" stroke="url(#gradRing)" stroke-width="10" stroke-dasharray="314.15" stroke-dashoffset="314.15" fill="transparent" r="50" cx="60" cy="60"/>
                            <defs>
                                <linearGradient id="gradRing" x1="0%" y1="0%" x2="100%" y2="100%">
                                    <stop offset="0%" stop-color="#6366f1" />
                                    <stop offset="100%" stop-color="#a855f7" />
                                </linearGradient>
                            </defs>
                        </svg>
                        <div class="progress-text">0%</div>
                    </div>
                    <div style="font-size: 0.85rem; color: var(--text-secondary);">
                        0 of <%= (syllabus != null) ? syllabus.stream().flatMap(s -> s.getUnits().stream()).mapToInt(u -> u.getTopics().size()).sum() : 0 %> modules completed.
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Trend Intelligence Modal -->
    <div class="modal-overlay" id="intel-modal" onclick="closeTrendIntel()">
        <div class="modal-card" onclick="event.stopPropagation()">
            <div class="modal-header">
                <div>
                    <span class="countdown-title">Exam Trend Intelligence</span>
                    <div class="modal-title" id="m-topic-name">Topic Name</div>
                </div>
                <button class="modal-close" onclick="closeTrendIntel()">&times;</button>
            </div>
            
            <div class="trend-metric-row">
                <div class="trend-metric-box">
                    <div class="trend-metric-label">Appeared in Exam</div>
                    <div class="trend-metric-val" id="m-years">Years</div>
                </div>
                <div class="trend-metric-box">
                    <div class="trend-metric-label">Questions Checked</div>
                    <div class="trend-metric-val" id="m-questions">Q Count</div>
                </div>
            </div>

            <div class="trend-metric-row">
                <div class="trend-metric-box">
                    <div class="trend-metric-label">Recent Frequency</div>
                    <div class="trend-metric-val" id="m-freq">Freq</div>
                </div>
                <div class="trend-metric-box">
                    <div class="trend-metric-label">Calculated Priority</div>
                    <div class="trend-metric-val" id="m-prio">Prio</div>
                </div>
            </div>

            <!-- Sourcing Provenance Display -->
            <div class="provenance-card">
                <div class="provenance-header">
                    <span>Data Provenance Reference</span>
                    <span class="provenance-status" id="m-status">Verified</span>
                </div>
                <div style="margin-bottom: 6px;">Source: <strong id="m-source">Source Name</strong></div>
                <div style="font-size: 0.75rem; color: var(--text-secondary);">Retrieved at: <span id="m-date">Date</span></div>
                <a href="#" target="_blank" class="provenance-link" id="m-link">Link</a>
            </div>
        </div>
    </div>

    <script>
        function toggleSubject(subjectId) {
            const card = document.getElementById(`subj-${subjectId}`);
            card.classList.toggle('expanded');
        }

        function toggleTopicDetail(topicId) {
            const detailDiv = document.getElementById(`topic-detail-${topicId}`);
            if (detailDiv.style.display === 'none' || detailDiv.style.display === '') {
                detailDiv.style.display = 'block';
            } else {
                detailDiv.style.display = 'none';
            }
        }

        function switchTab(tab) {
            const tabHierarchy = document.getElementById('tab-hierarchy');
            const tabHighyield = document.getElementById('tab-highyield');
            const viewHierarchy = document.getElementById('hierarchy-view');
            const viewHighyield = document.getElementById('highyield-view');

            if (tab === 'hierarchy') {
                viewHierarchy.style.display = 'block';
                viewHighyield.style.display = 'none';
                tabHierarchy.classList.add('active');
                tabHighyield.classList.remove('active');
                tabHierarchy.style.color = '#fff';
                tabHighyield.style.color = 'var(--text-secondary)';
            } else {
                viewHierarchy.style.display = 'none';
                viewHighyield.style.display = 'block';
                tabHierarchy.classList.remove('active');
                tabHighyield.classList.add('active');
                tabHierarchy.style.color = 'var(--text-secondary)';
                tabHighyield.style.color = '#fff';
            }
        }

        function openTrendIntel(name, difficulty, priority, freq, years, qCount, status, sourceTitle, sourceUrl, date) {
            document.getElementById('m-topic-name').innerText = name;
            document.getElementById('m-years').innerText = years;
            document.getElementById('m-questions').innerText = qCount;
            document.getElementById('m-freq').innerText = freq;
            document.getElementById('m-prio').innerText = priority;
            
            const statusBadge = document.getElementById('m-status');
            statusBadge.innerText = status;
            if (status === 'VERIFIED') {
                statusBadge.style.background = 'rgba(16, 185, 129, 0.15)';
                statusBadge.style.color = '#34d399';
            } else {
                statusBadge.style.background = 'rgba(245, 158, 11, 0.15)';
                statusBadge.style.color = '#fbbf24';
            }

            document.getElementById('m-source').innerText = sourceTitle;
            document.getElementById('m-date').innerText = date.replace('T', ' ');
            
            const linkElement = document.getElementById('m-link');
            if (sourceUrl && sourceUrl !== 'N/A') {
                linkElement.href = sourceUrl;
                linkElement.innerText = sourceUrl;
                linkElement.style.display = 'block';
            } else {
                linkElement.style.display = 'none';
            }

            document.getElementById('intel-modal').classList.add('show');
        }

        function closeTrendIntel() {
            document.getElementById('intel-modal').classList.remove('show');
        }
    </script>
</body>
</html>
