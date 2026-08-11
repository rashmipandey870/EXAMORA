<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.examora.model.Exam" %>
<%@ page import="java.util.List" %>
<%
    List<Exam> examsList = (List<Exam>) request.getAttribute("examsList");
    Exam activeExam = (Exam) request.getAttribute("activeExam");
    String selectFirst = request.getParameter("selectFirst");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Exam Focus — EXAMORA</title>
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

        /* Dashboard Sidebar Layout */
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
            margin-bottom: 40px;
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

        /* Notification message */
        .alert-info {
            background: rgba(245, 158, 11, 0.1);
            border: 1px solid rgba(245, 158, 11, 0.25);
            border-radius: 12px;
            padding: 16px 20px;
            color: #fcd34d;
            margin-bottom: 30px;
            font-size: 0.9rem;
            display: flex;
            align-items: center;
            gap: 10px;
            animation: fadeIn 0.5s ease-out;
        }

        /* Exam Cards Grid */
        .exams-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 24px;
            margin-bottom: 40px;
            perspective: 1000px;
        }

        .exam-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.4);
            cursor: pointer;
            position: relative;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            transform-style: preserve-3d;
            transform: translateZ(0);
        }

        .exam-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            height: 4px;
            background: transparent;
            transition: background 0.3s;
        }

        .exam-card:hover {
            transform: translateY(-8px) rotateX(2deg) rotateY(-2deg);
            box-shadow: 0 20px 40px rgba(99, 102, 241, 0.15);
            border-color: rgba(99, 102, 241, 0.3);
        }

        .exam-card.active-focus {
            border-color: var(--accent-primary);
            box-shadow: 0 0 25px rgba(99, 102, 241, 0.25);
        }

        .exam-card.active-focus::before {
            background: linear-gradient(90deg, var(--accent-primary), var(--accent-secondary));
        }

        .active-badge {
            position: absolute;
            top: 20px;
            right: 20px;
            background: rgba(16, 185, 129, 0.15);
            color: #34d399;
            font-size: 0.7rem;
            font-weight: 700;
            text-transform: uppercase;
            padding: 4px 8px;
            border-radius: 50px;
            border: 1px solid rgba(16, 185, 129, 0.2);
            letter-spacing: 0.5px;
        }

        .exam-icon {
            font-size: 2.5rem;
            margin-bottom: 20px;
        }

        .exam-title {
            font-size: 1.3rem;
            font-weight: 700;
            margin-bottom: 8px;
            color: var(--text-primary);
        }

        .exam-meta {
            font-size: 0.85rem;
            color: var(--text-secondary);
            margin-bottom: 24px;
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .btn-select {
            width: 100%;
            background: rgba(255, 255, 255, 0.05);
            border: 1px solid rgba(255, 255, 255, 0.08);
            color: var(--text-primary);
            padding: 12px;
            border-radius: 10px;
            font-weight: 600;
            font-size: 0.9rem;
            cursor: pointer;
            transition: all 0.3s;
            margin-top: auto;
        }

        .exam-card:hover .btn-select {
            background: rgba(99, 102, 241, 0.1);
            border-color: rgba(99, 102, 241, 0.3);
        }

        .exam-card.active-focus .btn-select {
            background: linear-gradient(135deg, var(--accent-primary) 0%, var(--accent-secondary) 100%);
            border: none;
            box-shadow: 0 4px 15px rgba(99, 102, 241, 0.3);
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
        }

        .toast.show {
            transform: translateY(0);
            opacity: 1;
        }

        .toast.success {
            border-left: 4px solid var(--success-color);
        }

        .toast.error {
            border-left: 4px solid var(--error-color);
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
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
            <li class="nav-item active">
                <a href="exams">
                    <span>My Exam Focus</span>
                </a>
            </li>
            <li class="nav-item">
                <a href="syllabus">
                    <span>Syllabus Explorer</span>
                </a>
            </li>
            <li class="nav-item nav-logout">
                <a href="logout">
                    <span>Sign Out</span>
                </a>
            </li>
        </ul>
    </div>

    <!-- Main Content Workspace -->
    <div class="main-content">
        <div class="header-section">
            <h1>Configure Target Examination</h1>
            <p class="header-desc">Choose your focus exam to initialize your adaptive syllabus tracker.</p>
        </div>

        <% if (selectFirst != null && "true".equals(selectFirst)) { %>
            <div class="alert-info">
                <span>⚠️ Please select a target examination focus before exploring your syllabus plan.</span>
            </div>
        <% } %>

        <div class="exams-grid">
            <% 
                if (examsList != null) {
                    for (Exam exam : examsList) {
                        boolean isActive = (activeExam != null && activeExam.getId() == exam.getId());
                        
                        // Select an icon based on name
                        String icon = "🎓";
                        if (exam.getName().contains("GATE")) icon = "💻";
                        else if (exam.getName().contains("JEE")) icon = "📐";
                        else if (exam.getName().contains("UPSC")) icon = "📜";
                        else if (exam.getName().contains("CAT")) icon = "📊";
            %>
                        <div class="exam-card <%= isActive ? "active-focus" : "" %>" onclick="setActiveExam(<%= exam.getId() %>)">
                            <% if (isActive) { %>
                                <span class="active-badge">Active Focus</span>
                            <% } %>
                            <div class="exam-icon"><%= icon %></div>
                            <h3 class="exam-title"><%= exam.getName() %></h3>
                            <div class="exam-meta">
                                <span>Target Year: <strong><%= exam.getExamYear() %></strong></span>
                                <span>Exam Date: <strong><%= exam.getExamDate() %></strong></span>
                            </div>
                            <button class="btn-select">
                                <%= isActive ? "Active Plan" : "Set as Focus Target" %>
                            </button>
                        </div>
            <% 
                    }
                } 
            %>
        </div>
    </div>

    <!-- Toasts box -->
    <div class="toast-container" id="toast-box"></div>

    <script>
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

        function setActiveExam(examId) {
            const params = new URLSearchParams();
            params.append('examId', examId);

            fetch('exams', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'Accept': 'application/json'
                },
                body: params.toString()
            })
            .then(async response => {
                const data = await response.json();
                if (response.ok) {
                    showToast(data.message, 'success');
                    setTimeout(() => {
                        window.location.href = 'syllabus';
                    }, 1200);
                } else {
                    throw new Error(data.message || 'Failed to update focus.');
                }
            })
            .catch(error => {
                showToast(error.message, 'error');
            });
        }
    </script>
</body>
</html>
