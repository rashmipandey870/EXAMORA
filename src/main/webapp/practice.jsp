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

        /* --- EXAM MODE & CHATBOT STYLES --- */
        .mode-switcher {
            display: flex;
            gap: 10px;
            margin-bottom: 24px;
            background: rgba(255, 255, 255, 0.03);
            padding: 6px;
            border-radius: 12px;
            border: 1px solid rgba(255, 255, 255, 0.05);
            width: fit-content;
        }
        .mode-btn {
            padding: 10px 20px;
            border-radius: 8px;
            font-size: 0.9rem;
            font-weight: 700;
            color: var(--text-secondary);
            border: none;
            background: none;
            cursor: pointer;
            transition: all 0.2s;
        }
        .mode-btn.active {
            color: #fff;
            background: rgba(99, 102, 241, 0.15);
            border: 1px solid rgba(99, 102, 241, 0.2);
        }

        .option-lbl:has(input[type="radio"]:checked) {
            background: rgba(99, 102, 241, 0.12);
            border-color: var(--accent-primary);
            box-shadow: 0 0 12px rgba(99, 102, 241, 0.15);
        }

        .exam-setup-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 16px;
            padding: 35px;
            margin-bottom: 30px;
            text-align: center;
        }
        .exam-setup-card h3 {
            font-size: 1.45rem;
            font-weight: 850;
            color: #fff;
            margin-bottom: 12px;
        }
        .exam-setup-desc {
            font-size: 0.95rem;
            color: var(--text-secondary);
            line-height: 1.6;
            margin-bottom: 24px;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
        }
        .btn-start-exam {
            background: linear-gradient(135deg, var(--accent-primary) 0%, var(--accent-secondary) 100%);
            color: #fff;
            font-weight: 800;
            font-size: 1rem;
            padding: 14px 28px;
            border-radius: 12px;
            border: none;
            cursor: pointer;
            transition: all 0.3s;
            box-shadow: 0 4px 15px rgba(99, 102, 241, 0.3);
        }
        .btn-start-exam:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(99, 102, 241, 0.5);
        }

        .exam-navigation {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 24px;
            padding-top: 20px;
            border-top: 1px solid rgba(255, 255, 255, 0.05);
        }
        .exam-btn {
            padding: 12px 24px;
            border-radius: 10px;
            font-weight: 750;
            font-size: 0.9rem;
            border: none;
            cursor: pointer;
            transition: all 0.2s;
        }
        .exam-btn-prev {
            background: rgba(255, 255, 255, 0.05);
            color: #f3f4f6;
        }
        .exam-btn-prev:hover {
            background: rgba(255, 255, 255, 0.1);
        }
        .exam-btn-next {
            background: var(--accent-primary);
            color: #fff;
        }
        .exam-btn-next:hover {
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
        }
        .exam-btn-skip {
            background: rgba(255, 255, 255, 0.03);
            color: var(--text-secondary);
            border: 1px dashed rgba(255, 255, 255, 0.15);
        }
        .exam-btn-skip:hover {
            background: rgba(239, 68, 68, 0.1);
            color: #f87171;
            border-color: rgba(239, 68, 68, 0.2);
        }
        .exam-btn-submit {
            background: var(--success-color);
            color: #fff;
        }
        .exam-btn-submit:hover {
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
        }
        .exam-status-indicator {
            font-size: 0.85rem;
            color: var(--text-secondary);
            font-weight: 600;
        }

        .exam-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: rgba(13, 18, 36, 0.8);
            border: 1px solid var(--card-border);
            border-radius: 12px;
            padding: 14px 20px;
            margin-bottom: 24px;
        }
        .exam-timer {
            font-size: 1.1rem;
            font-weight: 800;
            color: #f87171;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .exam-progress-tracker {
            display: flex;
            gap: 6px;
        }
        .exam-progress-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.1);
            transition: all 0.3s;
        }
        .exam-progress-dot.active {
            background: var(--accent-primary);
            box-shadow: 0 0 8px var(--accent-primary);
        }
        .exam-progress-dot.answered {
            background: var(--success-color);
        }
        .exam-progress-dot.skipped {
            background: #f59e0b;
        }

        .scorecard-card {
            background: linear-gradient(135deg, rgba(13, 18, 36, 0.9) 0%, rgba(99, 102, 241, 0.05) 100%);
            border: 1px solid rgba(99, 102, 241, 0.25);
            border-radius: 20px;
            padding: 40px;
            margin-bottom: 35px;
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.4);
            text-align: center;
        }
        .scorecard-header {
            font-size: 1.6rem;
            font-weight: 850;
            background: linear-gradient(135deg, #fff 0%, #a5b4fc 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 24px;
        }
        .scorecard-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }
        .scorecard-stat {
            background: rgba(0, 0, 0, 0.25);
            border: 1px solid var(--card-border);
            border-radius: 12px;
            padding: 16px;
        }
        .scorecard-stat-label {
            font-size: 0.75rem;
            font-weight: 700;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 6px;
        }
        .scorecard-stat-val {
            font-size: 1.5rem;
            font-weight: 850;
            color: #fff;
        }
        .scorecard-score-big {
            font-size: 3rem;
            font-weight: 900;
            color: var(--success-color);
            text-shadow: 0 0 15px rgba(16, 185, 129, 0.2);
            margin-bottom: 8px;
        }

        .chatbot-toggle-btn {
            background: rgba(99, 102, 241, 0.08);
            border: 1px solid rgba(99, 102, 241, 0.2);
            color: #a5b4fc;
            padding: 10px 18px;
            border-radius: 8px;
            font-size: 0.85rem;
            font-weight: 700;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s;
            margin-top: 18px;
        }
        .chatbot-toggle-btn:hover {
            background: var(--accent-primary);
            color: #fff;
        }
        .chatbot-box {
            border: 1px solid rgba(255, 255, 255, 0.08);
            background: rgba(0, 0, 0, 0.3);
            border-radius: 12px;
            margin-top: 14px;
            padding: 16px;
            display: none;
            flex-direction: column;
            gap: 12px;
        }
        .chat-messages {
            max-height: 200px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
            gap: 10px;
            padding-right: 6px;
        }
        .chat-msg {
            padding: 10px 14px;
            border-radius: 10px;
            font-size: 0.88rem;
            line-height: 1.45;
            max-width: 85%;
        }
        .chat-msg-user {
            background: rgba(99, 102, 241, 0.2);
            color: #fff;
            align-self: flex-end;
            border-bottom-right-radius: 2px;
        }
        .chat-msg-tutor {
            background: rgba(255, 255, 255, 0.04);
            color: var(--text-primary);
            align-self: flex-start;
            border-bottom-left-radius: 2px;
        }
        .chat-input-form {
            display: flex;
            gap: 8px;
            border-top: 1px solid rgba(255, 255, 255, 0.05);
            padding-top: 10px;
        }
        .chat-input {
            flex-grow: 1;
            background: rgba(0, 0, 0, 0.4);
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 8px;
            padding: 8px 12px;
            color: #fff;
            font-size: 0.85rem;
            outline: none;
        }
        .chat-input:focus {
            border-color: var(--accent-primary);
        }
        .chat-btn-send {
            background: var(--accent-primary);
            color: #fff;
            border: none;
            border-radius: 8px;
            padding: 8px 14px;
            font-weight: 700;
            font-size: 0.85rem;
            cursor: pointer;
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

        <!-- Mode Switcher -->
        <div class="mode-switcher" id="practice-mode-switcher" style="display: none;">
            <button class="mode-btn active" id="btn-practice-mode" onclick="setMode('PRACTICE')">Practice Mode</button>
            <button class="mode-btn" id="btn-exam-mode" onclick="setMode('EXAM')">Exam Mode</button>
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

        <!-- Exam Setup Instructions Card -->
        <div class="exam-setup-card" id="exam-instructions-card" style="display: none;">
            <h3 id="exam-instructions-title">DBMS Exam Setup</h3>
            <p class="exam-setup-desc">
                You are entering <strong>Exam Mode</strong>. This simulates an official GATE examination.
                <br><br>
                <strong>Rules & Pattern:</strong>
                <br>
                • 1-Mark Questions: <strong>+1.0</strong> for correct answer, <strong>-0.33</strong> penalty for incorrect answers.
                <br>
                • 2-Mark Questions: <strong>+2.0</strong> for correct answer, <strong>-0.67</strong> penalty for incorrect answers.
                <br>
                • Unattempted or skipped questions receive <strong>0.0</strong> marks.
                <br><br>
                Timer limit is set to <strong>30 minutes</strong>. Submit early if completed. Good luck!
            </p>
            <button class="btn-start-exam" onclick="startExam()">Start Exam Mode</button>
        </div>

        <!-- Running Exam Header -->
        <div class="exam-header" id="exam-running-header" style="display: none;">
            <div class="exam-timer">
                ⏱️ <span id="exam-timer-display">30:00</span>
            </div>
            <div class="exam-progress-tracker" id="exam-progress-dots">
                <!-- Javascript will populate dots -->
            </div>
        </div>

        <!-- Exam Scorecard Card -->
        <div class="scorecard-card" id="exam-scorecard-card" style="display: none;">
            <h2 class="scorecard-header">GATE Exam Scorecard</h2>
            <div class="scorecard-score-big" id="scorecard-total-score">0.00 / 0.00</div>
            <p style="color: var(--text-secondary); margin-bottom: 24px; font-weight: 600; font-size: 1.05rem;" id="scorecard-result-msg">Completed!</p>
            
            <div class="scorecard-grid">
                <div class="scorecard-stat">
                    <div class="scorecard-stat-label">Correct Answers</div>
                    <div class="scorecard-stat-val" id="scorecard-correct-count" style="color: var(--success-color);">0</div>
                </div>
                <div class="scorecard-stat">
                    <div class="scorecard-stat-label">Incorrect Answers</div>
                    <div class="scorecard-stat-val" id="scorecard-incorrect-count" style="color: var(--error-color);">0</div>
                </div>
                <div class="scorecard-stat">
                    <div class="scorecard-stat-label">Skipped / N/A</div>
                    <div class="scorecard-stat-val" id="scorecard-skipped-count" style="color: #fbbf24;">0</div>
                </div>
                <div class="scorecard-stat">
                    <div class="scorecard-stat-label">Accuracy</div>
                    <div class="scorecard-stat-val" id="scorecard-accuracy">0%</div>
                </div>
            </div>
            <button class="btn-start-exam" onclick="exitExamReview()">Review Questions & Solutions</button>
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

                        <!-- AI Chatbot Box -->
                        <button class="chatbot-toggle-btn" 
                                id="chatbot-toggle-<%= q.getId() %>"
                                onclick="toggleChatbot(<%= q.getId() %>)"
                                style="display: <%= hasAttempted ? "inline-flex" : "none" %>;">
                            💬 Ask AI Tutor
                        </button>
                        
                        <div class="chatbot-box" id="chatbot-<%= q.getId() %>">
                            <div class="chat-messages" id="chat-messages-<%= q.getId() %>">
                                <div class="chat-msg chat-msg-tutor">
                                    Hi! I am your AI Tutor. Need help understanding this question or functional details about DBMS? Ask me anything!
                                </div>
                            </div>
                            <form class="chat-input-form" onsubmit="sendChat(event, <%= q.getId() %>)">
                                <input type="text" class="chat-input" id="chat-input-<%= q.getId() %>" placeholder="Type your doubt here..." required>
                                <button type="submit" class="chat-btn-send" id="chat-send-<%= q.getId() %>">Send</button>
                            </form>
                        </div>
                    </div>
        <%
                }
        %>
                <!-- Exam Mode Navigation Footer -->
                <div class="exam-navigation" id="exam-running-navigation" style="display: none;">
                    <button class="exam-btn exam-btn-prev" onclick="prevExamQuestion()">← Previous</button>
                    <div class="exam-status-indicator" id="exam-status-indicator">Question 1 of 5</div>
                    <div style="display: flex; gap: 10px;">
                        <button class="exam-btn exam-btn-skip" onclick="skipExamQuestion()">Skip Question</button>
                        <button class="exam-btn exam-btn-next" onclick="saveNextExamQuestion()">Save & Next →</button>
                        <button class="exam-btn exam-btn-submit" onclick="submitExam()" style="display: none;">Submit Exam</button>
                    </div>
                </div>
        <%
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

        // --- EXAM MODE & CHATBOT CLIENT VARIABLES ---
        let activeMode = 'PRACTICE'; 
        let examQuestionsList = [];
        let examCurrentIndex = 0;
        let examSelections = {}; 
        let examSkippedIds = new Set(); 
        let examTimerInterval = null;
        let examTimeRemaining = 1800; 

        const allQuestionsData = {
            <% if (questions != null) {
                for (PYQQuestion q : questions) { %>
                    <%= q.getId() %>: {
                        id: <%= q.getId() %>,
                        year: <%= q.getYear() %>,
                        marks: <%= q.getMarks() %>,
                        correctAnswer: "<%= q.getCorrectAnswer() %>"
                    },
            <% } } %>
        };
        
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

            // Show mode switcher for valid years
            const switcher = document.getElementById('practice-mode-switcher');
            if (yearTotals[year] && yearTotals[year] > 0) {
                switcher.style.display = 'flex';
            } else {
                switcher.style.display = 'none';
            }

            // Reset exam state
            if (activeMode === 'EXAM') {
                resetExamState();
                setMode('EXAM'); // Refresh instructions card
            } else {
                updateVisibleQuestions();
                updateYearSummaryStats();
            }
        }

        function toggleBookmarkFilter() {
            if (activeMode === 'EXAM') return; // Disable filters during active exam
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
            if (activeMode === 'PRACTICE') {
                // Ensure instructions and exam frames are hidden
                document.getElementById('exam-instructions-card').style.display = 'none';
                document.getElementById('exam-running-header').style.display = 'none';
                document.getElementById('exam-running-navigation').style.display = 'none';
                document.getElementById('exam-scorecard-card').style.display = 'none';
                document.getElementById('year-stats-header').style.display = 'flex';

                document.querySelectorAll('.q-card').forEach(card => {
                    const year = parseInt(card.getAttribute('data-year'));
                    const qId = parseInt(card.getAttribute('data-qid'));
                    const matchesYear = (year === currentYear);
                    const matchesBookmark = !showBookmarksOnly || bookmarkedIds.has(qId);
                    
                    // Restore standard controls
                    card.querySelector('.btn-submit').style.display = 'block';
                    card.querySelector('.q-bookmark-btn').style.display = 'inline-flex';
                    
                    const explainBox = card.querySelector('.explain-box');
                    const tutorBtn = card.querySelector('.chatbot-toggle-btn');
                    const chatBox = card.querySelector('.chatbot-box');
                    
                    if (userAttempts[qId] && userAttempts[qId].attempted) {
                        explainBox.style.display = 'block';
                        tutorBtn.style.display = 'inline-flex';
                    } else {
                        explainBox.style.display = 'none';
                        tutorBtn.style.display = 'none';
                        chatBox.style.display = 'none';
                    }

                    if (matchesYear && matchesBookmark) {
                        card.style.display = 'block';
                    } else {
                        card.style.display = 'none';
                    }
                });
            }
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

        // --- EXAM MODE & CHATBOT INTERACTIVE METHODS ---
        function setMode(mode) {
            activeMode = mode;
            
            document.getElementById('btn-practice-mode').classList.toggle('active', mode === 'PRACTICE');
            document.getElementById('btn-exam-mode').classList.toggle('active', mode === 'EXAM');

            if (mode === 'PRACTICE') {
                clearInterval(examTimerInterval);
                document.getElementById('session-finish-card').style.display = 'none';
                updateVisibleQuestions();
                updateYearSummaryStats();
            } else {
                clearInterval(examTimerInterval);
                document.getElementById('year-stats-header').style.display = 'none';
                document.getElementById('session-finish-card').style.display = 'none';
                
                document.querySelectorAll('.q-card').forEach(card => card.style.display = 'none');
                
                document.getElementById('exam-scorecard-card').style.display = 'none';
                document.getElementById('exam-running-header').style.display = 'none';
                document.getElementById('exam-running-navigation').style.display = 'none';
                
                const instructions = document.getElementById('exam-instructions-card');
                document.getElementById('exam-instructions-title').innerText = 'GATE DBMS ' + currentYear + ' Practice Exam';
                instructions.style.display = 'block';
            }
        }

        function resetExamState() {
            clearInterval(examTimerInterval);
            examTimeRemaining = 1800;
            examSelections = {};
            examSkippedIds.clear();
            examCurrentIndex = 0;
            
            document.querySelectorAll('.q-card').forEach(card => {
                card.querySelectorAll('input[type="radio"]').forEach(radio => {
                    radio.checked = false;
                    radio.disabled = false;
                });
            });
        }

        function startExam() {
            resetExamState();
            
            examQuestionsList = [];
            document.querySelectorAll('.q-card').forEach(card => {
                const year = parseInt(card.getAttribute('data-year'));
                if (year === currentYear) {
                    examQuestionsList.push(card);
                }
            });

            if (examQuestionsList.length === 0) {
                alert("No questions available for this year.");
                setMode('PRACTICE');
                return;
            }

            document.getElementById('exam-instructions-card').style.display = 'none';
            document.getElementById('exam-running-header').style.display = 'flex';
            document.getElementById('exam-running-navigation').style.display = 'flex';

            const tracker = document.getElementById('exam-progress-dots');
            tracker.innerHTML = '';
            examQuestionsList.forEach((card, idx) => {
                const dot = document.createElement('div');
                dot.className = 'exam-progress-dot' + (idx === 0 ? ' active' : '');
                dot.id = 'exam-dot-' + idx;
                tracker.appendChild(dot);
            });

            startExamTimer();
            updateExamQuestionView();
        }

        function startExamTimer() {
            const display = document.getElementById('exam-timer-display');
            display.innerText = "30:00";
            
            examTimerInterval = setInterval(() => {
                examTimeRemaining--;
                if (examTimeRemaining <= 0) {
                    clearInterval(examTimerInterval);
                    alert("Time is up! Submitting your exam automatically...");
                    submitExam();
                    return;
                }
                const mins = Math.floor(examTimeRemaining / 60);
                const secs = examTimeRemaining % 60;
                display.innerText = (mins < 10 ? '0' : '') + mins + ':' + (secs < 10 ? '0' : '') + secs;
            }, 1000);
        }

        function updateExamQuestionView() {
            examQuestionsList.forEach(card => card.style.display = 'none');

            const activeCard = examQuestionsList[examCurrentIndex];
            activeCard.style.display = 'block';

            activeCard.querySelector('.btn-submit').style.display = 'none';
            activeCard.querySelector('.q-bookmark-btn').style.display = 'none';
            activeCard.querySelector('.explain-box').style.display = 'none';
            activeCard.querySelector('.chatbot-toggle-btn').style.display = 'none';
            activeCard.querySelector('.chatbot-box').style.display = 'none';

            document.getElementById('exam-status-indicator').innerText = 'Question ' + (examCurrentIndex + 1) + ' of ' + examQuestionsList.length;

            for (let i = 0; i < examQuestionsList.length; i++) {
                const dot = document.getElementById('exam-dot-' + i);
                if (dot) {
                    dot.className = 'exam-progress-dot';
                    if (i === examCurrentIndex) {
                        dot.classList.add('active');
                    } else {
                        const qId = examQuestionsList[i].getAttribute('data-qid');
                        if (examSelections[qId]) {
                            dot.classList.add('answered');
                        } else if (examSkippedIds.has(qId)) {
                            dot.classList.add('skipped');
                        }
                    }
                }
            }

            const nextBtn = document.querySelector('.exam-btn-next');
            const submitBtn = document.querySelector('.exam-btn-submit');
            
            if (examCurrentIndex === examQuestionsList.length - 1) {
                nextBtn.style.display = 'none';
                submitBtn.style.display = 'block';
            } else {
                nextBtn.style.display = 'block';
                submitBtn.style.display = 'none';
            }
        }

        function saveNextExamQuestion() {
            const activeCard = examQuestionsList[examCurrentIndex];
            const qId = activeCard.getAttribute('data-qid');
            const selected = activeCard.querySelector('input[type="radio"]:checked');
            
            if (selected) {
                examSelections[qId] = selected.value;
                examSkippedIds.delete(qId);
            }
            
            if (examCurrentIndex < examQuestionsList.length - 1) {
                examCurrentIndex++;
                updateExamQuestionView();
            }
        }

        function skipExamQuestion() {
            const activeCard = examQuestionsList[examCurrentIndex];
            const qId = activeCard.getAttribute('data-qid');
            
            const checked = activeCard.querySelector('input[type="radio"]:checked');
            if (checked) checked.checked = false;
            
            delete examSelections[qId];
            examSkippedIds.add(qId);

            if (examCurrentIndex < examQuestionsList.length - 1) {
                examCurrentIndex++;
                updateExamQuestionView();
            } else {
                updateExamQuestionView();
            }
        }

        function prevExamQuestion() {
            if (examCurrentIndex > 0) {
                examCurrentIndex--;
                updateExamQuestionView();
            }
        }

        function submitExam() {
            clearInterval(examTimerInterval);

            const lastCard = examQuestionsList[examCurrentIndex];
            const lastQId = lastCard.getAttribute('data-qid');
            const selected = lastCard.querySelector('input[type="radio"]:checked');
            if (selected) {
                examSelections[lastQId] = selected.value;
                examSkippedIds.delete(lastQId);
            }

            let totalMarks = 0.0;
            let correctCount = 0;
            let incorrectCount = 0;
            let skippedCount = 0;
            let maxExamMarks = 0.0;

            const submitPromises = [];

            examQuestionsList.forEach(card => {
                const qId = parseInt(card.getAttribute('data-qid'));
                const qData = allQuestionsData[qId];
                const weight = qData ? qData.marks : 1.0;
                maxExamMarks += weight;

                const choice = examSelections[qId];
                if (choice) {
                    const isCorrect = (choice.trim().toUpperCase() === qData.correctAnswer.trim().toUpperCase());
                    
                    if (isCorrect) {
                        correctCount++;
                        totalMarks += weight;
                        userAttempts[qId] = { attempted: true, correct: true };
                    } else {
                        incorrectCount++;
                        totalMarks -= (weight / 3.0);
                        userAttempts[qId] = { attempted: true, correct: false };
                    }

                    const params = new URLSearchParams();
                    params.append('questionId', qId);
                    params.append('selectedOption', choice);
                    
                    const p = fetch('practice', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded'
                        },
                        body: params.toString()
                    });
                    submitPromises.push(p);
                } else {
                    skippedCount++;
                    userAttempts[qId] = { attempted: false, correct: false };
                }
            });

            Promise.all(submitPromises)
                .then(() => {
                    console.log("Exam responses successfully saved to database.");
                })
                .catch(err => {
                    console.error("Error saving exam attempts: ", err);
                });

            const accuracy = (correctCount + incorrectCount) > 0 
                ? Math.round((correctCount / (correctCount + incorrectCount)) * 100) 
                : 0;

            document.getElementById('exam-running-header').style.display = 'none';
            document.getElementById('exam-running-navigation').style.display = 'none';
            examQuestionsList.forEach(card => card.style.display = 'none');

            document.getElementById('scorecard-total-score').innerText = totalMarks.toFixed(2) + ' / ' + maxExamMarks.toFixed(2);
            document.getElementById('scorecard-correct-count').innerText = correctCount;
            document.getElementById('scorecard-incorrect-count').innerText = incorrectCount;
            document.getElementById('scorecard-skipped-count').innerText = skippedCount;
            document.getElementById('scorecard-accuracy').innerText = accuracy + '%';

            const ratio = maxExamMarks > 0 ? (totalMarks / maxExamMarks) : 0;
            const msgEl = document.getElementById('scorecard-result-msg');
            if (ratio >= 0.7) {
                msgEl.innerText = "🏆 Outstanding Performance! You are ready for GATE!";
                msgEl.style.color = "var(--success-color)";
            } else if (ratio >= 0.4) {
                msgEl.innerText = "👍 Good effort! Solid understanding, check the recommended topics to clear doubts.";
                msgEl.style.color = "#fbbf24";
            } else {
                msgEl.innerText = "📚 Keep practicing! DBMS normalization and indexing require a review.";
                msgEl.style.color = "#f87171";
            }

            document.getElementById('exam-scorecard-card').style.display = 'block';
        }

        function exitExamReview() {
            document.getElementById('exam-scorecard-card').style.display = 'none';
            activeMode = 'PRACTICE';
            
            examQuestionsList.forEach(card => {
                const qId = card.getAttribute('data-qid');
                const choice = examSelections[qId];
                if (choice) {
                    const radio = card.querySelector('input[value="' + choice + '"]');
                    if (radio) radio.checked = true;
                }
                card.querySelectorAll('input[type="radio"]').forEach(input => input.disabled = true);
            });

            updateVisibleQuestions();
            updateYearSummaryStats();
        }

        function toggleChatbot(qId) {
            const chatBox = document.getElementById('chatbot-' + qId);
            if (chatBox.style.display === 'none' || chatBox.style.display === '') {
                chatBox.style.display = 'flex';
                // Focus input
                document.getElementById('chat-input-' + qId).focus();
            } else {
                chatBox.style.display = 'none';
            }
        }

        function sendChat(event, qId) {
            event.preventDefault();
            const input = document.getElementById('chat-input-' + qId);
            const msg = input.value.trim();
            if (!msg) return;

            const messagesContainer = document.getElementById('chat-messages-' + qId);
            
            const userBubble = document.createElement('div');
            userBubble.className = 'chat-msg chat-msg-user';
            userBubble.innerText = msg;
            messagesContainer.appendChild(userBubble);
            input.value = '';
            messagesContainer.scrollTop = messagesContainer.scrollHeight;

            const loadingBubble = document.createElement('div');
            loadingBubble.className = 'chat-msg chat-msg-tutor';
            loadingBubble.innerHTML = '<em>Thinking...</em>';
            messagesContainer.appendChild(loadingBubble);
            messagesContainer.scrollTop = messagesContainer.scrollHeight;

            const params = new URLSearchParams();
            params.append('questionId', qId);
            params.append('message', msg);

            fetch('tutor-chat', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: params.toString()
            })
            .then(async response => {
                const data = await response.json();
                loadingBubble.remove();
                if (response.ok && data.status === 'SUCCESS') {
                    const replyBubble = document.createElement('div');
                    replyBubble.className = 'chat-msg chat-msg-tutor';
                    replyBubble.innerText = data.reply;
                    messagesContainer.appendChild(replyBubble);
                } else {
                    const errorBubble = document.createElement('div');
                    errorBubble.className = 'chat-msg chat-msg-tutor';
                    errorBubble.style.color = 'var(--error-color)';
                    errorBubble.innerText = "Error: " + (data.message || "Failed to reach AI Tutor.");
                    messagesContainer.appendChild(errorBubble);
                }
                messagesContainer.scrollTop = messagesContainer.scrollHeight;
            })
            .catch(error => {
                loadingBubble.remove();
                const errorBubble = document.createElement('div');
                errorBubble.className = 'chat-msg chat-msg-tutor';
                errorBubble.style.color = 'var(--error-color)';
                errorBubble.innerText = "Network error: " + error.message;
                messagesContainer.appendChild(errorBubble);
                messagesContainer.scrollTop = messagesContainer.scrollHeight;
            });
        }
    </script>
</body>
</html>
