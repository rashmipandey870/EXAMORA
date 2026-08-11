<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String topicName = (String) request.getAttribute("topicName");
    String subjectName = (String) request.getAttribute("subjectName");
    String notesContent = (String) request.getAttribute("notesContent");
    String noteSource = (String) request.getAttribute("noteSource");
    Boolean rateLimited = (Boolean) request.getAttribute("rateLimited");
    if (rateLimited == null) rateLimited = false;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= topicName %> Notes — EXAMORA</title>
    <!-- Include Marked.js for markdown parsing -->
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
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
            padding: 40px 20px;
        }

        .container {
            width: 100%;
            max-width: 800px;
            margin: 0 auto;
        }

        .back-btn {
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid var(--card-border);
            color: var(--text-secondary);
            padding: 10px 18px;
            border-radius: 10px;
            text-decoration: none;
            font-weight: 600;
            font-size: 0.88rem;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 24px;
            transition: all 0.3s;
        }

        .back-btn:hover {
            color: #fff;
            background: rgba(255, 255, 255, 0.06);
            border-color: rgba(99, 102, 241, 0.3);
        }

        .glass-card {
            background: var(--card-bg);
            border: 1px solid var(--card-border);
            border-radius: 24px;
            padding: 40px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.6);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
        }

        .meta-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid var(--card-border);
            padding-bottom: 20px;
            margin-bottom: 30px;
        }

        .subj-lbl {
            font-size: 0.85rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: var(--accent-secondary);
            font-weight: 700;
            margin-bottom: 4px;
            display: block;
        }

        h2 {
            font-size: 1.8rem;
            font-weight: 800;
            color: #fff;
        }

        .badge-cache {
            font-size: 0.72rem;
            font-weight: 700;
            padding: 6px 12px;
            border-radius: 6px;
            border: 1px solid transparent;
        }

        .badge-live-ai {
            background: rgba(99, 102, 241, 0.12);
            color: #818cf8;
            border: 1px solid rgba(99, 102, 241, 0.2);
        }

        .badge-local-mock {
            background: rgba(245, 158, 11, 0.12);
            color: #fbbf24;
            border: 1px solid rgba(245, 158, 11, 0.2);
        }

        .badge-cached {
            background: rgba(16, 185, 129, 0.12);
            color: var(--success-color);
            border: 1px solid rgba(16, 185, 129, 0.2);
        }

        .rate-limit-banner {
            background: rgba(239, 68, 68, 0.15);
            border: 1px solid rgba(239, 68, 68, 0.2);
            color: #fca5a5;
            padding: 14px 20px;
            border-radius: 12px;
            margin-bottom: 24px;
            font-size: 0.88rem;
            line-height: 1.5;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        /* Markdown rendered styling */
        .notes-render {
            line-height: 1.7;
            font-size: 1rem;
        }

        .notes-render h1, .notes-render h2, .notes-render h3 {
            color: #fff;
            margin-top: 24px;
            margin-bottom: 12px;
            font-weight: 700;
        }

        .notes-render h1 { font-size: 1.5rem; }
        .notes-render h2 { font-size: 1.25rem; border-bottom: 1px solid rgba(255,255,255,0.05); padding-bottom: 6px; }
        .notes-render h3 { font-size: 1.1rem; }

        .notes-render p {
            margin-bottom: 16px;
            color: #d1d5db;
        }

        .notes-render ul, .notes-render ol {
            margin-left: 24px;
            margin-bottom: 16px;
            color: #d1d5db;
        }

        .notes-render li {
            margin-bottom: 6px;
        }

        .notes-render code {
            background: rgba(0, 0, 0, 0.3);
            padding: 2px 6px;
            border-radius: 4px;
            font-family: monospace;
            font-size: 0.9rem;
            color: #f472b6;
        }

        .notes-render blockquote {
            border-left: 4px solid var(--accent-primary);
            background: rgba(99, 102, 241, 0.05);
            padding: 14px 20px;
            border-radius: 0 12px 12px 0;
            margin: 20px 0;
            font-style: italic;
        }
    </style>
</head>
<body>

    <div class="container">
        <a href="syllabus" class="back-btn">&larr; Back to Syllabus Explorer</a>

        <% if (rateLimited) { %>
            <div class="rate-limit-banner">
                <span>⚠️</span>
                <span><strong>Daily Generation Cap Reached:</strong> You have hit your limit of 15 Live AI note generations per 24 hours. Displaying high-quality offline reference notes instead.</span>
            </div>
        <% } %>

        <div class="glass-card">
            <div class="meta-header">
                <div>
                    <span class="subj-lbl"><%= subjectName %></span>
                    <h2><%= topicName %></h2>
                </div>
                <div>
                    <% if ("LIVE_AI".equals(noteSource)) { %>
                        <span class="badge-cache badge-live-ai">
                            🤖 Live AI Generated
                        </span>
                    <% } else if ("LOCAL_MOCK".equals(noteSource)) { %>
                        <span class="badge-cache badge-local-mock">
                            📝 Local Reference Notes
                        </span>
                    <% } else { %>
                        <span class="badge-cache badge-cached">
                            ⚡ Cached Notes
                        </span>
                    <% } %>
                </div>
            </div>

            <!-- Div where markdown content will be rendered -->
            <div class="notes-render" id="notes-container"></div>
        </div>
    </div>

    <!-- Hidden textarea storing notes markdown content -->
    <textarea id="markdown-raw" style="display:none;"><%= notesContent %></textarea>

    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const rawContent = document.getElementById('markdown-raw').value;
            // Parse markdown using Marked.js
            document.getElementById('notes-container').innerHTML = marked.parse(rawContent);
        });
    </script>
</body>
</html>
