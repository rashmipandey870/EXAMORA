<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Personalized Onboarding — EXAMORA</title>
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
                radial-gradient(circle at 10% 20%, rgba(99, 102, 241, 0.12) 0%, transparent 45%),
                radial-gradient(circle at 90% 80%, rgba(168, 85, 247, 0.12) 0%, transparent 45%);
            color: var(--text-primary);
            font-family: var(--font-family);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        .container {
            width: 100%;
            max-width: 600px;
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

        .header {
            text-align: center;
            margin-bottom: 35px;
        }

        .logo-text {
            font-size: 1.5rem;
            font-weight: 800;
            background: linear-gradient(135deg, #6366f1 0%, #a855f7 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            letter-spacing: 0.5px;
            margin-bottom: 8px;
        }

        h2 {
            font-size: 1.6rem;
            font-weight: 800;
            margin-bottom: 8px;
        }

        .tagline {
            color: var(--text-secondary);
            font-size: 0.95rem;
        }

        .step-progress {
            display: flex;
            justify-content: space-between;
            margin-bottom: 35px;
            position: relative;
        }

        .step-progress::after {
            content: '';
            position: absolute;
            top: 15px;
            left: 10%;
            right: 10%;
            height: 2px;
            background: rgba(255, 255, 255, 0.05);
            z-index: 1;
        }

        .progress-line-active {
            position: absolute;
            top: 15px;
            left: 10%;
            width: 0%;
            height: 2px;
            background: linear-gradient(90deg, var(--accent-primary), var(--accent-secondary));
            z-index: 2;
            transition: width 0.4s ease;
        }

        .step-dot {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: #111322;
            border: 2px solid var(--card-border);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 0.9rem;
            z-index: 3;
            transition: all 0.3s;
        }

        .step-dot.active {
            border-color: var(--accent-primary);
            color: #fff;
            box-shadow: 0 0 10px rgba(99, 102, 241, 0.4);
        }

        .step-dot.completed {
            background: var(--accent-primary);
            border-color: var(--accent-primary);
            color: #fff;
        }

        .onboarding-step {
            display: none;
            animation: fadeIn 0.4s ease forwards;
        }

        .onboarding-step.active {
            display: block;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .question-title {
            font-size: 1.2rem;
            font-weight: 700;
            margin-bottom: 24px;
            text-align: center;
        }

        .options-grid {
            display: grid;
            grid-template-columns: 1fr;
            gap: 14px;
            margin-bottom: 30px;
        }

        .option-card {
            background: rgba(0, 0, 0, 0.2);
            border: 1px solid rgba(255, 255, 255, 0.05);
            padding: 18px 24px;
            border-radius: 16px;
            cursor: pointer;
            transition: all 0.25s ease;
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .option-card:hover {
            background: rgba(255, 255, 255, 0.03);
            border-color: rgba(99, 102, 241, 0.3);
        }

        .option-card.selected {
            background: rgba(99, 102, 241, 0.08);
            border-color: var(--accent-primary);
            box-shadow: 0 0 15px rgba(99, 102, 241, 0.15);
        }

        .option-icon {
            font-size: 1.5rem;
        }

        .option-details {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .option-label {
            font-weight: 600;
            font-size: 1rem;
        }

        .option-desc {
            font-size: 0.85rem;
            color: var(--text-secondary);
        }

        .btn-row {
            display: flex;
            justify-content: space-between;
            margin-top: 25px;
            gap: 16px;
        }

        .btn {
            padding: 14px 28px;
            border-radius: 12px;
            font-size: 0.95rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            outline: none;
            border: none;
        }

        .btn-prev {
            background: rgba(255, 255, 255, 0.05);
            color: var(--text-secondary);
            border: 1px solid var(--card-border);
        }

        .btn-prev:hover {
            background: rgba(255, 255, 255, 0.08);
            color: var(--text-primary);
        }

        .btn-next {
            background: linear-gradient(135deg, var(--accent-primary) 0%, var(--accent-secondary) 100%);
            color: white;
            flex-grow: 1;
            box-shadow: 0 4px 15px rgba(99, 102, 241, 0.25);
        }

        .btn-next:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(99, 102, 241, 0.4);
        }

        .btn-next:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            transform: none;
            box-shadow: none;
        }

        /* Error notification */
        .error-message {
            background: rgba(239, 68, 68, 0.1);
            border: 1px solid rgba(239, 68, 68, 0.2);
            color: #f87171;
            padding: 12px 16px;
            border-radius: 10px;
            font-size: 0.9rem;
            margin-bottom: 20px;
            text-align: center;
        }
    </style>
</head>
<body>

    <div class="container">
        <div class="glass-card">
            <div class="header">
                <div class="logo-text">EXAMORA</div>
                <h2>Let's build your strategy</h2>
                <p class="tagline">Answer three quick questions to discover and align your study focus.</p>
            </div>

            <!-- Step Progress Dots -->
            <div class="step-progress">
                <div class="progress-line-active" id="progress-line"></div>
                <div class="step-dot active" id="dot-1">1</div>
                <div class="step-dot" id="dot-2">2</div>
                <div class="step-dot" id="dot-3">3</div>
            </div>

            <% if (request.getAttribute("error") != null) { %>
                <div class="error-message">
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>

            <form id="onboarding-form" action="onboarding" method="POST">
                <!-- Step 1: Academic Background -->
                <div class="onboarding-step active" id="step-1-content">
                    <h3 class="question-title">What is your academic background?</h3>
                    <input type="hidden" name="background" id="background-input">
                    
                    <div class="options-grid">
                        <div class="option-card" onclick="selectOption('background', 'B_TECH_CSE', this)">
                            <div class="option-icon">💻</div>
                            <div class="option-details">
                                <span class="option-label">B.Tech / BE Computer Science</span>
                                <span class="option-desc">Algorithms, systems, software engineering</span>
                            </div>
                        </div>

                        <div class="option-card" onclick="selectOption('background', 'B_TECH_STEM', this)">
                            <div class="option-icon">⚙️</div>
                            <div class="option-details">
                                <span class="option-label">B.Tech / BE (Other STEM branch)</span>
                                <span class="option-desc">Electrical, Mechanical, Civil, Biotech, etc.</span>
                            </div>
                        </div>

                        <div class="option-card" onclick="selectOption('background', 'COMMERCE', this)">
                            <div class="option-icon">📊</div>
                            <div class="option-details">
                                <span class="option-label">Commerce / Business Studies</span>
                                <span class="option-desc">B.Com, BBA, economics, accounts</span>
                            </div>
                        </div>

                        <div class="option-card" onclick="selectOption('background', 'SCIENCE_GRAD', this)">
                            <div class="option-icon">🔬</div>
                            <div class="option-details">
                                <span class="option-label">General Science Graduate</span>
                                <span class="option-desc">B.Sc Physics, Chemistry, Math, Biology</span>
                            </div>
                        </div>

                        <div class="option-card" onclick="selectOption('background', 'CLASS_12_PCM', this)">
                            <div class="option-icon">📐</div>
                            <div class="option-details">
                                <span class="option-label">High School (Class 12 PCM)</span>
                                <span class="option-desc">Physics, Chemistry, Mathematics stream</span>
                            </div>
                        </div>

                        <div class="option-card" onclick="selectOption('background', 'WORKING_PROFESSIONAL', this)">
                            <div class="option-icon">💼</div>
                            <div class="option-details">
                                <span class="option-label">Working Professional</span>
                                <span class="option-desc">College graduate looking for transition/upskill</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Step 2: Goal -->
                <div class="onboarding-step" id="step-2-content">
                    <h3 class="question-title">What is your primary preparation goal?</h3>
                    <input type="hidden" name="goal" id="goal-input">

                    <div class="options-grid">
                        <div class="option-card" onclick="selectOption('goal', 'HIGHER_STUDIES', this)">
                            <div class="option-icon">🎓</div>
                            <div class="option-details">
                                <span class="option-label">Higher Studies Entrances</span>
                                <span class="option-desc">Masters/Ph.D at premier institutions (GATE, CAT, etc.)</span>
                            </div>
                        </div>

                        <div class="option-card" onclick="selectOption('goal', 'GOVT_JOB', this)">
                            <div class="option-icon">🏛️</div>
                            <div class="option-details">
                                <span class="option-label">Government Public Service</span>
                                <span class="option-desc">Civil services or public sector jobs (UPSC, Banking, SSC)</span>
                            </div>
                        </div>

                        <div class="option-card" onclick="selectOption('goal', 'PLACEMENT', this)">
                            <div class="option-icon">🚀</div>
                            <div class="option-details">
                                <span class="option-label">Campus Placement Prep</span>
                                <span class="option-desc">Technical and coding tests for corporate jobs</span>
                            </div>
                        </div>

                        <div class="option-card" onclick="selectOption('goal', 'CERTIFICATION', this)">
                            <div class="option-icon">🎖️</div>
                            <div class="option-details">
                                <span class="option-label">Professional Certification</span>
                                <span class="option-desc">Technical industry certifications (AWS, Azure, GCP)</span>
                            </div>
                        </div>

                        <div class="option-card" onclick="selectOption('goal', 'EXPLORING', this)">
                            <div class="option-icon">🔍</div>
                            <div class="option-details">
                                <span class="option-label">Just Exploring Options</span>
                                <span class="option-desc">Browse general exam patterns and catalog details</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Step 3: Target Timeline -->
                <div class="onboarding-step" id="step-3-content">
                    <h3 class="question-title">When are you planning to take the exam?</h3>
                    <input type="hidden" name="targetTimeline" id="timeline-input">

                    <div class="options-grid">
                        <div class="option-card" onclick="selectOption('timeline', '2027', this)">
                            <div class="option-icon">🗓️</div>
                            <div class="option-details">
                                <span class="option-label">This Year (2027 Exams)</span>
                                <span class="option-desc">Fast-track schedule; exam within 12 months</span>
                            </div>
                        </div>

                        <div class="option-card" onclick="selectOption('timeline', '2028', this)">
                            <div class="option-icon">⏳</div>
                            <div class="option-details">
                                <span class="option-label">Next Year (2028 Exams)</span>
                                <span class="option-desc">Extended buffer timeline; systematic build</span>
                            </div>
                        </div>

                        <div class="option-card" onclick="selectOption('timeline', 'EXPLORING', this)">
                            <div class="option-icon">🌍</div>
                            <div class="option-details">
                                <span class="option-label">Flexible / Rolling Schedule</span>
                                <span class="option-desc">On-demand certs or general schedule layout</span>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Navigation buttons -->
                <div class="btn-row">
                    <button type="button" class="btn btn-prev" id="btn-prev" onclick="prevStep()" style="display:none;">Back</button>
                    <button type="button" class="btn btn-next" id="btn-next" onclick="nextStep()" disabled>Continue</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        let currentStep = 1;
        const totalSteps = 3;

        function selectOption(category, value, element) {
            // Set hidden input value
            document.getElementById(category + '-input').value = value;

            // Clear previously selected elements in the same grid
            const cards = element.parentElement.querySelectorAll('.option-card');
            cards.forEach(card => card.classList.remove('selected'));

            // Select this element
            element.classList.add('selected');

            // Enable next button
            document.getElementById('btn-next').disabled = false;
        }

        function updateStepUI() {
            // Hide all steps, show active step
            for (let i = 1; i <= totalSteps; i++) {
                const el = document.getElementById('step-' + i + '-content');
                if (i === currentStep) {
                    el.classList.add('active');
                } else {
                    el.classList.remove('active');
                }

                // Update dots
                const dot = document.getElementById('dot-' + i);
                if (i < currentStep) {
                    dot.className = 'step-dot completed';
                    dot.innerText = '✓';
                } else if (i === currentStep) {
                    dot.className = 'step-dot active';
                    dot.innerText = i;
                } else {
                    dot.className = 'step-dot';
                    dot.innerText = i;
                }
            }

            // Update progress line
            const percentage = ((currentStep - 1) / (totalSteps - 1)) * 80;
            document.getElementById('progress-line').style.width = percentage + '%';

            // Update buttons
            const btnPrev = document.getElementById('btn-prev');
            const btnNext = document.getElementById('btn-next');

            if (currentStep === 1) {
                btnPrev.style.display = 'none';
            } else {
                btnPrev.style.display = 'block';
            }

            if (currentStep === totalSteps) {
                btnNext.innerText = 'Find My Exams';
            } else {
                btnNext.innerText = 'Continue';
            }

            // Check if current step hidden input has value to toggle next button disable status
            let currentInputId = '';
            if (currentStep === 1) currentInputId = 'background-input';
            else if (currentStep === 2) currentInputId = 'goal-input';
            else if (currentStep === 3) currentInputId = 'timeline-input';

            if (document.getElementById(currentInputId).value) {
                btnNext.disabled = false;
            } else {
                btnNext.disabled = true;
            }
        }

        function nextStep() {
            if (currentStep < totalSteps) {
                currentStep++;
                updateStepUI();
            } else {
                // Submit Form
                document.getElementById('onboarding-form').submit();
            }
        }

        function prevStep() {
            if (currentStep > 1) {
                currentStep--;
                updateStepUI();
            }
        }
    </script>
</body>
</html>
