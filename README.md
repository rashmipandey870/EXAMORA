# EXAMORA – AI-Powered Exam Preparation & Study Platform 🎓🤖

An intelligent, full-stack Java Enterprise web platform designed to streamline competitive and university examination preparation through AI-driven topic recommendation, syllabus tracking, dynamic study task generation, and Previous Year Questions (PYQ) analytics.

[![Java](https://img.shields.io/badge/Java-17-orange.svg)](https://www.oracle.com/java/)
[![Jakarta EE](https://img.shields.io/badge/Jakarta%20EE-Servlet%206.0-red.svg)](https://jakarta.ee/)
[![Apache Maven](https://img.shields.io/badge/Maven-Build%20Tool-blue.svg)](https://maven.apache.org/)
[![MySQL](https://img.shields.io/badge/MySQL-Database-4479A1.svg)](https://www.mysql.com/)
[![OpenAI](https://img.shields.io/badge/OpenAI-API%20Integration-green.svg)](https://openai.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## 📌 Problem & Overview

Students preparing for high-stakes university and competitive examinations often suffer from fragmented study plans, lack of visibility into high-weightage topics, and disorganised question banks. 

**EXAMORA** solves this by uniting syllabus breakdown, past-year question (PYQ) coverage, AI-driven topic prioritization, and automated schedule generation into a unified web portal.

---

## 🏗️ System Architecture

```
                       Browser Client (JSP / CSS / JavaScript)
                                        │
                                        ▼
                            Jakarta Servlet 6.0 (Tomcat 11)
                                        │
             ┌──────────────────────────┼──────────────────────────┐
             ▼                          ▼                          ▼
     [Auth & Security]          [Core Controllers]         [Admin & Ingestion]
     (BCrypt, Sessions)         ├── SyllabusServlet        └── PYQIngestServlet
                                ├── PlannerServlet
                                └── PracticeServlet
                                        │
                                        ▼
                               [Service Layer]
             ┌──────────────────────────┼──────────────────────────┐
             ▼                          ▼                          ▼
    TopicPriorityService          PlannerService             OpenAIService
    (Weightage Analytics)      (Dynamic Task Allocator)   (AI Explanation & Insights)
                                        │
                                        ▼
                            [Data Access Layer (DAO)]
             ├── UserDAO               ├── TopicDAO           ├── StudyTaskDAO
             ├── ExamDAO               ├── StudyPlanDAO       └── PYQQuestionDAO
                                        │
                                        ▼
                            MySQL Relational Database
```

---

## ✨ Core Features

- 🤖 **AI-Enhanced Study Assistance:** Integrates OpenAI API to generate topic summaries, personalized study strategies, and question explanations.
- 📈 **Topic Priority & Weightage Scoring:** Analyzes historical exam patterns to calculate priority ratings and recommended study hours per unit.
- 📅 **Dynamic Study Task Planner:** Generates customized day-by-day task lists, dynamically rescheduling incomplete tasks based on upcoming deadlines.
- 📝 **PYQ Ingestion & Practice Portal:** Categorized question bank with real-time attempt tracking, accuracy metrics, and coverage analysis.
- 🔐 **Secure Authentication:** Session-based user authentication featuring BCrypt password hashing and role-based authorization (Student vs. Administrator).

---

## 🛠️ Tech Stack

- **Backend:** Java 17, Jakarta Servlet API 6.0, JSTL 3.0
- **Build & Dependency Management:** Apache Maven
- **Web Tier:** Jakarta Server Pages (JSP), HTML5, CSS3, Vanilla JS
- **Database:** MySQL (JDBC Connection Pooling)
- **AI / External APIs:** OpenAI REST API
- **Deployment Server:** Apache Tomcat 11

---

## 📂 Project Architecture

```
src/main/
├── java/com/examora/
│   ├── controller/       # Jakarta Servlet request handlers
│   ├── dao/              # Database Access Objects (CRUD & complex queries)
│   ├── model/            # Domain entities (User, Exam, Topic, StudyPlan, PYQ)
│   ├── service/          # Business logic, Priority algorithms, OpenAI integration
│   └── util/             # DBConnection pool, PasswordUtil (BCrypt hashing)
├── resources/
│   └── application.properties # Database connection & environment configuration
└── webapp/
    ├── admin/            # Administrative portal (PYQ ingestion & management)
    ├── WEB-INF/          # web.xml servlet deployment descriptors
    ├── dashboard.jsp     # Real-time student progress & overview
    ├── planner.jsp       # Interactive study calendar
    ├── practice.jsp      # Question bank & mock testing interface
    └── syllabus.jsp      # Unit & topic breakdown viewer
```

---

## ⚙️ Local Setup & Deployment

### Prerequisites
- JDK 17 or higher
- Apache Maven 3.8+
- MySQL Server 8.0+
- Apache Tomcat 10.1 / 11.0

### Step-by-Step Instructions

1. **Clone the repository:**
   ```bash
   git clone https://github.com/rashmipandey870/EXAMORA.git
   cd EXAMORA
   ```

2. **Configure the Database:**
   Execute the schema initialization scripts found in `database/`:
   ```sql
   CREATE DATABASE examora;
   USE examora;
   SOURCE database/schema.sql;
   ```

3. **Update Configuration:**
   Edit `src/main/resources/application.properties` with your MySQL credentials:
   ```properties
   db.url=jdbc:mysql://localhost:3306/examora
   db.username=root
   db.password=your_password
   openai.api.key=your_openai_key
   ```

4. **Build the WAR package:**
   ```bash
   mvn clean package
   ```

5. **Deploy:**
   Deploy the generated `target/examora.war` to your Apache Tomcat `webapps/` directory and start the server.

---

## 👩‍💻 Author
**Rashmi Pandey**  
- [GitHub](https://github.com/rashmipandey870)  
- [LinkedIn](https://www.linkedin.com/in/rashmipandey870)
