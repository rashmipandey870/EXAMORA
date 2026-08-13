<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.examora.model.Exam" %>
<%@ page import="com.examora.model.PYQQuestion" %>
<%@ page import="com.examora.model.PYQAttempt" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.HashSet" %>
<%
    Exam activeExam = (Exam) request.getAttribute("activeExam");
    List<PYQQuestion> questions = (List<PYQQuestion>) request.getAttribute("questions");
    String username = (String) request.getAttribute("username");
    List<PYQAttempt> userAttempts = (List<PYQAttempt>) request.getAttribute("userAttempts");
    List<Integer> bookmarkedIds = (List<Integer>) request.getAttribute("bookmarkedIds");
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

        /* Part A Styling: Year tabs rail */
        .year-tabs-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            padding: 12px 20px;
            border-radius: 16px;
            margin-bottom: 24px;
            gap: 16px;
        }

        .year-tabs-scroll {
            display: flex;
            gap: 10px;
            overflow-x: auto;
            padding-bottom: 4px;
            flex-grow: 1;
        }

        .year-tabs-scroll::-webkit-scrollbar {
            height: 4px;
        }
        .year-tabs-scroll::-webkit-scrollbar-thumb {
            background: rgba(255,255,255,0.1);
            border-radius: 2px;
        }

        .year-tab-btn {
            background: rgba(255, 255, 255, 0.02);
            border: 1px solid var(--card-border);
            color: var(--text-secondary);
            padding: 8px 16px;
            border-radius: 10px;
            font-weight: 700;
            font-size: 0.9rem;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 6px;
            transition: all 0.2s ease;
            white-space: nowrap;
        }

        .year-tab-btn:hover:not(.disabled) {
            background: rgba(255, 255, 255, 0.05);
            color: #fff;
            border-color: rgba(255,255,255,0.2);
        }

        .year-tab-btn.active {
            background: linear-gradient(135deg, var(--accent-primary) 0%, var(--accent-secondary) 100%);
            color: #fff;
            border-color: transparent;
            box-shadow: 0 4px 12px rgba(99,102,241,0.2);
        }

        .year-tab-btn.disabled {
            opacity: 0.35;
            cursor: not-allowed;
            background: transparent;
            border-style: dashed;
        }

        .tab-badge-complete {
            background: var(--success-color);
            color: #fff;
            font-size: 0.65rem;
            width: 14px;
            height: 14px;
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
        }

        .tab-badge-na {
            font-size: 0.65rem;
            color: var(--text-secondary);
            opacity: 0.8;
        }

        .tab-badge-count {
            background: rgba(255, 255, 255, 0.1);
            color: var(--text-primary);
            font-size: 0.65rem;
            padding: 1px 5px;
            border-radius: 6px;
        }

        /* Bookmark & Filter Styling */
        .filter-bookmark-btn {
            background: rgba(255, 255, 255, 0.02);
            border: 1px solid var(--card-border);
            color: var(--text-secondary);
            padding: 8px 16px;
            border-radius: 10px;
            font-weight: 700;
            font-size: 0.9rem;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 6px;
            transition: all 0.2s ease;
            white-space: nowrap;
        }

        .filter-bookmark-btn:hover {
            color: #fff;
            background: rgba(255, 255, 255, 0.06);
        }

        .filter-bookmark-btn.active {
            border-color: #fbbf24;
            color: #fbbf24;
            background: rgba(251, 191, 36, 0.1);
        }

        .q-bookmark-btn {
            background: none;
            border: none;
            cursor: pointer;
            font-size: 1.2rem;
            color: var(--text-secondary);
            transition: color 0.2s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 4px;
        }

        .q-bookmark-btn:hover {
            color: #fbbf24;
        }

        .q-bookmark-btn.bookmarked {
            color: #fbbf24;
            filter: drop-shadow(0 0 4px rgba(251, 191, 36, 0.3));
        }

        /* Accuracy Stats Header */
        .active-year-stats-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            padding: 20px;
            border-radius: 16px;
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 16px;
        }

        .active-year-stats-card h3 {
            font-size: 1.1rem;
            font-weight: 700;
            color: #fff;
        }

        .stats-progress-container {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-grow: 1;
            max-width: 400px;
        }

        .stats-bar-outer {
            height: 8px;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 4px;
            flex-grow: 1;
            overflow: hidden;
            position: relative;
        }

        .stats-bar-inner {
            height: 100%;
            background: linear-gradient(90deg, var(--accent-primary) 0%, var(--accent-secondary) 100%);
            border-radius: 4px;
            transition: width 0.4s ease;
        }

        .stats-text {
            font-size: 0.8rem;
            color: var(--text-secondary);
            font-weight: 600;
            white-space: nowrap;
        }

        .accuracy-badge {
            background: rgba(16, 185, 129, 0.15);
            color: #34d399;
            border: 1px solid rgba(16, 185, 129, 0.2);
            padding: 4px 10px;
            border-radius: 8px;
            font-size: 0.8rem;
            font-weight: 700;
        }

        /* Session Summary Card */
        .finish-card {
            background: linear-gradient(135deg, rgba(16, 185, 129, 0.08) 0%, rgba(99, 102, 241, 0.08) 100%);
            border: 1px solid rgba(16, 185, 129, 0.2);
            padding: 24px;
            border-radius: 16px;
            margin-top: 24px;
            display: none;
            box-shadow: 0 8px 32px rgba(16, 185, 129, 0.1);
        }

        .finish-card h3 {
            font-size: 1.25rem;
            font-weight: 800;
            color: #34d399;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .finish-card p {
            font-size: 0.95rem;
            color: var(--text-secondary);
            margin-bottom: 16px;
        }

        .rec-list {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 10px;
            margin-top: 8px;
        }

        .rec-link {
            display: inline-block;
            color: #a5b4fc;
            text-decoration: none;
            font-weight: 700;
            font-size: 0.9rem;
            transition: color 0.2s ease;
        }

        .rec-link:hover {
            color: #fff;
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
                            <% if (cov.getSourceUrl() != null && !cov.getSourceUrl().trim().isEmpty()) { %>
                                <div style="margin-top: 12px; font-size: 0.7rem; text-overflow: ellipsis; overflow: hidden; white-space: nowrap;">
                                    <a href="<%= cov.getSourceUrl() %>" target="_blank" style="color: #818cf8; text-decoration: none;">
                                        🔗 Source URL
                                    </a>
                                </div>
                            <% } %>
                        </div>
                    <% } %>
                </div>
            </div>
        <% } %>

        <%
            java.util.Map<Integer, Integer> yearTotalQ = new java.util.HashMap<>();
            java.util.Map<Integer, Integer> yearAttemptedQ = new java.util.HashMap<>();
            java.util.Map<Integer, Integer> yearCorrectQ = new java.util.HashMap<>();
            java.util.Set<Integer> attemptedQIds = new java.util.HashSet<>();
            java.util.Map<Integer, Boolean> qCorrectState = new java.util.HashMap<>();

            // 1. Process attempts
            if (userAttempts != null) {
                for (com.examora.model.PYQAttempt att : userAttempts) {
                    if (!attemptedQIds.contains(att.getQuestionId())) {
                        attemptedQIds.add(att.getQuestionId());
                        qCorrectState.put(att.getQuestionId(), att.isCorrect());
                    }
                }
            }

            // 2. Count questions per year
            if (questions != null) {
                for (PYQQuestion q : questions) {
                    int yr = q.getYear();
                    yearTotalQ.put(yr, yearTotalQ.getOrDefault(yr, 0) + 1);
                    if (attemptedQIds.contains(q.getId())) {
                        yearAttemptedQ.put(yr, yearAttemptedQ.getOrDefault(yr, 0) + 1);
                        if (Boolean.TRUE.equals(qCorrectState.get(q.getId()))) {
                            yearCorrectQ.put(yr, yearCorrectQ.getOrDefault(yr, 0) + 1);
                        }
                    }
                }
            }

            java.util.Set<Integer> bookmarkedSet = new java.util.HashSet<>();
            if (bookmarkedIds != null) {
                bookmarkedSet.addAll(bookmarkedIds);
            }
            
            // Build the topicNames map in JSP
            java.util.List<com.examora.model.Topic> topicsList = (java.util.List<com.examora.model.Topic>) request.getAttribute("topicsList");
        %>

        <!-- Year-Tabbed Navigation Rail -->
        <div class="year-tabs-container">
            <div class="year-tabs-scroll">
                <% 
                    int activeYear = -1;
                    if (coverageList != null && !coverageList.isEmpty()) {
                        for (com.examora.model.PYQCoverage cov : coverageList) {
                            int yr = cov.getYear();
                            int totalQ = yearTotalQ.getOrDefault(yr, 0);
                            int attemptedQ = yearAttemptedQ.getOrDefault(yr, 0);
                            boolean isComplete = totalQ > 0 && attemptedQ >= totalQ;
                            boolean isAvailable = totalQ > 0;
                            
                            if (activeYear == -1 && isAvailable) {
                                activeYear = yr;
                            }
                %>
                            <button class="year-tab-btn <%= (isAvailable ? "" : "disabled") %>" 
                                    onclick="switchYear(<%= yr %>, <%= isAvailable %>)" 
                                    id="tab-<%= yr %>"
                                    data-year="<%= yr %>">
                                <span><%= yr %></span>
                                <% if (isComplete) { %>
                                    <span class="tab-badge-complete">✓</span>
                                <% } else if (!isAvailable) { %>
                                    <span class="tab-badge-na">N/A</span>
                                <% } else { %>
                                    <span class="tab-badge-count"><%= totalQ - attemptedQ %> left</span>
                                <% } %>
                            </button>
                <% 
                        } 
                    } 
                %>
            </div>
            <!-- Bookmark Filter Toggle -->
            <button class="filter-bookmark-btn" onclick="toggleBookmarkFilter()" id="bookmark-filter-btn">
                ⭐ Review Flags
            </button>
        </div>

        <!-- Active Year Stats Header -->
        <div class="active-year-stats-card" id="year-stats-header">
            <div>
                <h3 id="year-stats-title">Subject Practice: DBMS</h3>
                <p id="year-subtitle" style="font-size: 0.8rem; color: var(--text-secondary); margin-top: 4px;"></p>
            </div>
            <div class="stats-progress-container">
                <div class="stats-bar-outer">
                    <div class="stats-bar-inner" id="year-progress-bar" style="width: 0%;"></div>
                </div>
                <span class="stats-text" id="year-stats-text">0/0 Answered</span>
            </div>
            <div id="year-accuracy-badge" class="accuracy-badge">Accuracy: 0%</div>
        </div>

        <%
            if (questions != null && !questions.isEmpty()) {
                for (PYQQuestion q : questions) {
                    boolean isBookmarked = bookmarkedSet.contains(q.getId());
                    boolean hasAttempted = attemptedQIds.contains(q.getId());
                    boolean wasCorrect = hasAttempted && Boolean.TRUE.equals(qCorrectState.get(q.getId()));
        %>
                    <div class="q-card" data-year="<%= q.getYear() %>" data-qid="<%= q.getId() %>" data-topic-id="<%= q.getTopicId() %>" style="display: none;">
                        <div class="q-meta">
                            <div style="display: flex; align-items: center; gap: 10px;">
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
                            <div style="display: flex; align-items: center; gap: 12px;">
                                <div class="q-marks">
                                    Difficulty: <strong><%= q.getDifficulty() %></strong> &bull; Marks: <strong><%= q.getMarks() %></strong>
                                </div>
                                <button class="q-bookmark-btn <%= isBookmarked ? "bookmarked" : "" %>" 
                                        onclick="toggleBookmark(<%= q.getId() %>, this); event.stopPropagation();" 
                                        title="Mark for later review">
                                    <%= isBookmarked ? "★" : "☆" %>
                                </button>
                            </div>
                        </div>

                        <div class="q-text">
                            <%= q.getQuestionText() %>
                        </div>

                        <div class="options-list">
                            <%
                                java.util.Map<String, String> options = q.getParsedOptions();
                                if (options.isEmpty()) {
                            %>
                                    <p style="color: var(--error-color);">This question's answer options could not be loaded. Please report this question.</p>
                            <%
                                } else {
                                    for (java.util.Map.Entry<String, String> entry : options.entrySet()) {
                                        String optionVal = entry.getKey();
                                        String optionText = entry.getValue();
                            %>
                                        <label class="option-lbl">
                                            <input type="radio" 
                                                   name="opt-<%= q.getId() %>" 
                                                   value="<%= optionVal %>"
                                                   <%= hasAttempted ? "disabled" : "" %>>
                                            <span><strong><%= optionVal %>.</strong> <%= optionText %></span>
                                        </label>
                            <%
                                    }
                                }
                            %>
                        </div>

                        <button class="btn-submit" 
                                onclick="checkAnswer(<%= q.getId() %>)"
                                <%= hasAttempted ? "disabled" : "" %>>
                            Submit Answer
                        </button>

                        <!-- Explanation Box -->
                        <div class="explain-box" 
                             id="explain-<%= q.getId() %>" 
                             style="display: <%= hasAttempted ? "block" : "none" %>;">
                            <span class="result-status" 
                                  id="result-<%= q.getId() %>"
                                  style="color: <%= wasCorrect ? "var(--success-color)" : "var(--error-color)" %>;">
                                <%= wasCorrect ? "✓ Correct Answer!" : "✗ Incorrect! The correct answer was: " + q.getCorrectAnswer() %>
                            </span>
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

        <!-- Session Finish Summary Card -->
        <div class="finish-card" id="session-finish-card">
            <h3>🎉 Year Completed!</h3>
            <p>Congratulations! You have completed all questions for this past paper year.</p>
            <div style="background: rgba(255, 255, 255, 0.03); padding: 16px; border-radius: 12px; margin-bottom: 20px; border: 1px solid rgba(255,255,255,0.05);">
                <span style="font-weight: 700; color: #fff; display: block; margin-bottom: 4px;">Session Accuracy:</span>
                <span id="finish-score" style="font-size: 1.2rem; font-weight: 800; color: #34d399;">0/0 Correct (0% Accuracy)</span>
            </div>
            
            <h4 id="finish-rec-title" style="color: #a5b4fc; font-size: 0.9rem; font-weight: 700; margin-bottom: 10px; display: none;">Recommended Study Material to Review:</h4>
            <ul class="rec-list" id="finish-recommendations">
                <!-- Javascript will inject list of topics here -->
            </ul>
        </div>
    </div>

    <script>
        let currentYear = <%= activeYear %>;
        let showBookmarksOnly = false;
        
        // Topic Names Map for recommendations
        const topicNames = {
            <% 
               if (topicsList != null) {
                   for (com.examora.model.Topic t : topicsList) {
            %>
                       <%= t.getId() %>: "<%= t.getName() %>",
            <% 
                   }
               }
            %>
        };

        // Bookmarks set in JS
        const bookmarkedIds = new Set([
            <%
                if (bookmarkedIds != null) {
                    for (int id : bookmarkedIds) {
            %>
                        <%= id %>,
            <%
                    }
                }
            %>
        ]);

        // In-memory progress tracking
        const yearTotals = {
            <% for(Map.Entry<Integer, Integer> e : yearTotalQ.entrySet()) { %>
                <%= e.getKey() %>: <%= e.getValue() %>,
            <% } %>
        };

        const userAttempts = {
            <% 
              if (questions != null) {
                for(PYQQuestion q : questions) { 
                   boolean attempted = attemptedQIds.contains(q.getId());
                   boolean correct = attempted && Boolean.TRUE.equals(qCorrectState.get(q.getId()));
            %>
                   <%= q.getId() %>: { attempted: <%= attempted %>, correct: <%= correct %> },
            <% 
                } 
              }
            %>
        };

        // Initialize display
        document.addEventListener("DOMContentLoaded", () => {
            if (currentYear !== -1) {
                switchYear(currentYear, true);
            } else {
                document.getElementById('year-stats-header').style.display = 'none';
            }
        });

        function switchYear(year, isAvailable) {
            if (!isAvailable) {
                alert("This year's past papers are not yet available.");
                return;
            }
            currentYear = year;
            
            // Toggle active classes on tab buttons
            document.querySelectorAll('.year-tab-btn').forEach(btn => {
                btn.classList.remove('active');
            });
            const activeTab = document.getElementById('tab-' + year);
            if (activeTab) {
                activeTab.classList.add('active');
            }
            
            updateVisibleQuestions();
            updateYearSummaryStats();
        }

        function toggleBookmarkFilter() {
            showBookmarksOnly = !showBookmarksOnly;
            const filterBtn = document.getElementById('bookmark-filter-btn');
            if (showBookmarksOnly) {
                filterBtn.classList.add('active');
                filterBtn.innerHTML = '★ Flagged Only';
            } else {
                filterBtn.classList.remove('active');
                filterBtn.innerHTML = '⭐ Review Flags';
            }
            updateVisibleQuestions();
        }

        function updateVisibleQuestions() {
            document.querySelectorAll('.q-card').forEach(card => {
                const year = parseInt(card.getAttribute('data-year'));
                const qId = parseInt(card.getAttribute('data-qid'));
                const matchesYear = (year === currentYear);
                const matchesBookmark = !showBookmarksOnly || bookmarkedIds.has(qId);
                
                if (matchesYear && matchesBookmark) {
                    card.style.display = 'block';
                } else {
                    card.style.display = 'none';
                }
            });
        }

        function updateYearSummaryStats() {
            const questions = document.querySelectorAll('.q-card[data-year="' + currentYear + '"]');
            const total = yearTotals[currentYear] || 0;
            
            let attempted = 0;
            let correct = 0;
            
            questions.forEach(card => {
                const qId = parseInt(card.getAttribute('data-qid'));
                if (userAttempts[qId] && userAttempts[qId].attempted) {
                    attempted++;
                    if (userAttempts[qId].correct) {
                        correct++;
                    }
                }
            });
            
            const pct = total > 0 ? (attempted / total) * 100 : 0;
            const accuracy = attempted > 0 ? Math.round((correct / attempted) * 100) : 0;
            
            document.getElementById('year-stats-title').innerText = 'Subject Practice: DBMS ' + currentYear;
            document.getElementById('year-progress-bar').style.width = pct + '%';
            document.getElementById('year-stats-text').innerText = attempted + ' of ' + total + ' Questions Answered';
            
            const accBadge = document.getElementById('year-accuracy-badge');
            accBadge.innerText = 'Accuracy: ' + accuracy + '% (' + correct + ' Correct)';
            
            // Toggle completion session card
            const finishCard = document.getElementById('session-finish-card');
            if (attempted >= total && total > 0) {
                finishCard.style.display = 'block';
                document.getElementById('finish-score').innerText = correct + ' / ' + total + ' Correct (' + accuracy + '% Accuracy)';
                
                // Find if there were incorrect questions in this year, list topics to study
                let weakTopicIds = new Set();
                questions.forEach(card => {
                    const qId = parseInt(card.getAttribute('data-qid'));
                    const topicId = parseInt(card.getAttribute('data-topic-id'));
                    if (userAttempts[qId] && userAttempts[qId].attempted && !userAttempts[qId].correct) {
                        weakTopicIds.add(topicId);
                    }
                });
                
                // Render weak topics study recommendation links
                const recList = document.getElementById('finish-recommendations');
                recList.innerHTML = '';
                if (weakTopicIds.size > 0) {
                    document.getElementById('finish-rec-title').style.display = 'block';
                    weakTopicIds.forEach(topicId => {
                        const name = topicNames[topicId] || "Related Topic";
                        const li = document.createElement('li');
                        li.innerHTML = '<a href="notes?topicId=' + topicId + '" class="rec-link">📖 Study Notes for: ' + name + ' &rarr;</a>';
                        recList.appendChild(li);
                    });
                } else {
                    document.getElementById('finish-rec-title').style.display = 'none';
                }
                
                // Add complete badge to the active tab button dynamically
                const tabBtn = document.getElementById('tab-' + currentYear);
                if (tabBtn) {
                    let badge = tabBtn.querySelector('.tab-badge-complete');
                    if (!badge) {
                        let oldBadge = tabBtn.querySelector('.tab-badge-count');
                        if (oldBadge) oldBadge.remove();
                        badge = document.createElement('span');
                        badge.className = 'tab-badge-complete';
                        badge.innerText = '✓';
                        tabBtn.appendChild(badge);
                    }
                }
            } else {
                finishCard.style.display = 'none';
            }
        }

        function toggleBookmark(qId, btn) {
            const params = new URLSearchParams();
            params.append('questionId', qId);
            params.append('action', 'bookmark');

            fetch('practice', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: params.toString()
            })
            .then(async response => {
                if (response.ok) {
                    if (bookmarkedIds.has(qId)) {
                        bookmarkedIds.delete(qId);
                        btn.classList.remove('bookmarked');
                        btn.innerText = '☆';
                    } else {
                        bookmarkedIds.add(qId);
                        btn.classList.add('bookmarked');
                        btn.innerText = '★';
                    }
                    updateVisibleQuestions();
                } else {
                    alert("Failed to toggle review flag.");
                }
            })
            .catch(error => {
                alert("Network error: " + error.message);
            });
        }

        function checkAnswer(qId) {
            const selected = document.querySelector('input[name="opt-' + qId + '"]:checked');
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
                    const explainBox = document.getElementById('explain-' + qId);
                    const resultStatus = document.getElementById('result-' + qId);
                    const explainText = explainBox.querySelector('p');
                    
                    explainBox.style.display = "block";
                    if (data.isCorrect) {
                        resultStatus.innerText = "✓ Correct Answer!";
                        resultStatus.style.color = "var(--success-color)";
                        userAttempts[qId] = { attempted: true, correct: true };
                    } else {
                        resultStatus.innerText = "✗ Incorrect! The correct answer was: " + data.correctAnswer;
                        resultStatus.style.color = "var(--error-color)";
                        userAttempts[qId] = { attempted: true, correct: false };
                    }
                    if (data.explanation) {
                        explainText.innerHTML = '<strong>Explanation:</strong> ' + data.explanation;
                    }
                    
                    // Disable options radios and button once submitted
                    document.querySelectorAll('input[name="opt-' + qId + '"]').forEach(input => input.disabled = true);
                    const btn = document.querySelector('button[onclick*="checkAnswer(' + qId + ')"]');
                    if (btn) btn.disabled = true;
                    
                    // Update year stats and progress dynamically
                    updateYearSummaryStats();
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
