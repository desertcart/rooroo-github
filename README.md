
See original repo for docs. This just changes the custom prompts to work with github issues, instead of using a local state file for observability.

Watch your roocode run on your repo in github issues.

Set up your org / repo name is `issue-manager.sh`

Run `gh auth` in your command line to authenticate first.

You may need to create the labels required in your repo first


# 🚀 rooroo (如如): Minimalist AI Orchestration with Specialist Agents 🚀

**Version: v0.1.1** [Changelog](changelog.md)

> **Note on v0.1.0 (Breaking Change):** This version introduces a major architectural shift separating planning (`Strategic Planner`) and execution (`Workflow Coordinator`), and removes the `Apex Implementer` in favor of built-in IDE coding modes. This aims for simplicity, avoids redundancy, and enables cost savings. **[See detailed rationale here.](v0.1.0.md)**

Welcome to `rooroo`, an AI-powered system designed to achieve **minimalist AI orchestration** for software development using a focused crew of **specialist agents** right within your VS Code environment via the [Roo Code extension](https://github.com/RooVetGit/Roo-Code). Think of it as having a lean, expert virtual team, precisely coordinated through distinct planning and execution phases.

## 🤔 What's in a Name? The Meaning of "rooroo (如如)"

The name "rooroo" comes from the term **"如如" (rú rú)** found in Buddhist philosophy. It relates to the concept of **Tathātā**, often translated as "Thusness" or "Suchness."

![img](https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQeUmsB4LIHLErFEbei5g8PfIFG-XQntgqLyA&s)

*   **Thusness/Suchness (真如):** Refers to the fundamental, unchanging, true nature of all phenomena – reality as it is.
*   **Equality & Non-Duality (不二平等):** Implies that, at the ultimate level, all things share this same essential nature.
*   **Emphasis:** The repetition "如如" emphasizes that this inherent "thusness" is pervasive across *all* things.

In the context of this project, the name evokes the idea of an underlying, consistent nature guiding the orchestration. This philosophy informs the **minimalist approach**, focusing on the essential 'thusness' of each agent's specialized role.

## 🎯 Key Problems Addressed

`rooroo` is designed to tackle common challenges in leveraging AI for software development:

1.  **Over-Complexity & Lack of Focus:** Many AI systems try to be everything. `rooroo` addresses this with a **minimalist crew of highly specialized agents**. Each agent excels in its specific domain (planning, coordination, design, validation, documentation).
2.  **Interaction Overhead & Lack of Clear Process:** Managing multiple AI interactions or a single monolithic AI can be cumbersome. `rooroo` solves this with a **two-stage orchestration model:**
    *   **🏛️ Strategic Planner:** Handles initial goal understanding and high-level task planning.
    *   **🚦 Workflow Coordinator:** Manages the execution flow, delegating tasks to specialists or **built-in VS Code AI capabilities (like code generation/debugging)**, managing state via `project_overview.json` and individual task files, and interacting with the user for key decisions. This separation clarifies the process and streamlines interaction.
3.  **Inconsistent Development Practices:** AI-driven development can lack structure. `rooroo` promotes **Document-Driven Development (DDD) and Test-Driven Development (TDD)** principles through its structured workflow, use of specifications (`.specs/`, `.design/`), validation (`.reports/`), and dedicated documentation management (`.docs/`).

## 🤔 Design Philosophy

The `rooroo` project was conceived with several core principles:

*   **Simplicity & Minimalism:** Avoid unnecessary complexity. Keep the agent team focused.
*   **Specialized Roles:** Each agent has a clear, distinct role.
*   **Separation of Concerns (Planning vs. Execution):** Use distinct agents for strategic planning and workflow coordination (Addresses Problem 2).
*   **Leverage Built-in Capabilities:** Delegate standard coding and debugging tasks to efficient, built-in AI modes when possible (Addresses Problem 2).
*   **Document & Test-Based Approach:** Emphasize clarity and reliability through DDD/TDD.

## ✨ Why Use rooroo? ✨

`rooroo` offers a structured and potentially more efficient approach:

*   **🎯 Focused Expertise:** Delegate design, validation, and documentation tasks to the right specialist AI. (Solves Problem 1)
*   **⚙️ Clear Two-Stage Orchestration:** Interact with the `Strategic Planner` for initial setup and the `Workflow Coordinator` for execution monitoring and decisions. This separation simplifies understanding and management. (Solves Problem 2)
*   **⚡ Efficient Implementation:** Leverages **built-in code/debug modes** for core implementation and bug fixing, potentially leading to faster and more cost-effective results for these common tasks. (Supports Problem 2)
*   **🏗️ Structured Workflow:** Follows a defined process (Plan, Design, Implement, Validate), encouraging DDD/TDD. (Solves Problem 3)
*   **💾 Clear Artifacts:** Organizes outputs (`.specs/`, `.design/`, `.docs/`, `.reports/`) for traceability. (Supports Problem 3)

## 🔑 Core Concepts

1.  **Minimalist Agent Crew:** A lean team: Planner, Coordinator, Architect, UX Specialist, Validator, DocuCrafter.
2.  **Two-Stage Orchestration:**
    *   **🏛️ Strategic Planner:** Interprets goals, creates the initial plan, defines tasks in `.state/tasks/`, populates `project_overview.json`.
    *   **🚦 Workflow Coordinator:** Monitors `project_overview.json`, delegates tasks (to specialists *or* built-in `code`/`debug` modes), interprets outcomes, updates state, prompts user for test decisions.
3.  **Specialist Roles:** Architect, UX Specialist, Validator, DocuCrafter handle specific, complex tasks. **Note:** Code implementation is *not* handled by a dedicated specialist agent in this version.
4.  **Delegation to Built-in Modes:** The `Workflow Coordinator` delegates tasks like `feature`, `refactor`, `chore`, `bugfix`, and `test_execution` to the integrated `code` or `debug` modes within the IDE.
5.  **State Management:** Uses `project_overview.json` (summary) and `.state/tasks/{taskId}.json` (details) for coordination. The Coordinator infers the status of tasks handled by built-in modes.
6.  **Structured Artifacts:** Relies on `.specs/`, `.design/`, `.docs/`, `.reports/`.

## 💡 LLM Cost Optimization

Different AI models have varying capabilities and costs. `rooroo`'s design allows for potential cost optimization by using different underlying LLMs for different agents:

*   **🧠 Smart/Expensive LLMs (e.g., O-Series, Claude Sonnet, Gemini 2.5 Pro):** Best suited for tasks requiring deep reasoning, complex planning, or nuanced design decisions.
    *   **Recommended:** `Strategic Planner`, `Solution Architect`
*   **⚡ Fast/Cheap LLMs (e.g., Gemini Flash, Grok mini, Deepseek V3):** Suitable for more constrained tasks, validation, documentation generation, or coordination based on structured data.
    *   **Recommended:** `Workflow Coordinator`, `UX Specialist` (depending on complexity), `Guardian Validator`, `DocuCrafter`
*   **Built-in Modes (`code`, `debug`):** These often utilize highly optimized models provided by the IDE extension, balancing capability and cost for coding tasks.

By configuring the underlying LLM for each agent mode (if supported by your environment, like Roo Code), you can potentially significantly reduce operational costs while maintaining high quality for critical planning and design phases.

## 🔄 The Core Development Workflow

`rooroo` guides development through a structured lifecycle:

1.  **🎯 Goal Setting:** You provide your high-level goal to the **🏛️ Strategic Planner**.
2.  **✍️ Planning:** The Planner interprets the goal, creates a plan, defines initial tasks (with types like `design`, `feature`, `validation`), sets up dependencies, populates `project_overview.json` and the initial `.state/tasks/` files, and then **hands off** to the Coordinator.
3.  **🚦 Coordination & Design Delegation:** The **🚦 Workflow Coordinator** takes over, monitors `project_overview.json`, and delegates ready `design` tasks to specialist agents:
    *   **📐 Solution Architect:** Creates technical specifications (`.specs/`).
    *   **🎨 UX Specialist:** Defines user experience and UI design (`.design/`). (These agents update their own task files and the overview upon completion).
4.  **💻 Implementation (via Built-in Modes):** Once designs are 'Done', the Coordinator delegates implementation tasks (`feature`, `refactor`, `chore`) to the **built-in `code` mode**, providing necessary context (specs, files to edit).
5.  **❓ State Inference & User Decision:** The Coordinator **infers** when the `code` mode task is complete (e.g., based on file changes or your confirmation) and updates the task status to `'Implemented'` in `project_overview.json`. It then **prompts you** to decide the next step (run tests, skip, defer).
6.  **✅ Validation / Test Execution:** Based on your input, the Coordinator delegates:
    *   Test execution tasks (`test_execution`) to the **built-in `debug` or `code` mode** (instructed to run tests).
    *   Validation tasks (`validation`) to the **🛡️ Guardian Validator**, referencing the specs/requirements.
    The Coordinator updates the original task's status based on the outcome reported or inferred.
7.  **🐞 Bug Fixing (via Built-in Mode):** If validation fails or tests reveal issues, the Coordinator delegates `bugfix` tasks to the **built-in `debug` mode**.
8.  **🔄 Iteration:** The Coordinator manages the loop based on outcomes, potentially triggering new planning phases with the Strategic Planner if major changes are needed.

*(Note: Documentation tasks are handled separately by the DocuCrafter, initiated via the Coordinator).*

## 🤖 Meet the Crew 🤖

*   **🏛️ Strategic Planner (Primary):** Interprets goals, creates high-level plans, defines initial tasks, sets up state files (`project_overview.json`, `.state/tasks/`), and hands off to the Coordinator. *Candidate for smart/expensive LLM.*
*   **🚦 Workflow Coordinator:** Manages execution. Monitors overview, delegates tasks to specialists **or built-in modes (`code`, `debug`)**, interprets outcomes (including inferring status from built-in modes), updates state, handles user test decisions, manages errors. *Candidate for fast/cheap LLM.*
*   **📐 Solution Architect:** Creates detailed technical specifications (`.specs/`) based on tasks delegated by the Coordinator. Updates its own task file and overview status. *Candidate for smart/expensive LLM.*
*   **🎨 UX Specialist:** Designs user flows and UI structures (`.design/`) based on tasks delegated by the Coordinator. Updates its own task file and overview status. *Candidate for smart/cheap LLM depending on task.*
*   **🛡️ Guardian Validator:** Independently validates implementation or runs specific tests based on tasks delegated by the Coordinator. Generates reports (`.reports/`). Updates its own task file and overview status. *Candidate for fast/cheap LLM.*
*   **✍️ DocuCrafter:** Generates/updates documentation (`.docs/`) based on tasks delegated by the Coordinator. Updates its own task file and overview status. *Candidate for fast/cheap LLM.*
*   **(Implicit) Built-in `code` / `debug` Modes:** Handled by the IDE extension, used by the Coordinator for core implementation, bug fixing, and test execution. *Cost/model determined by the extension.*

## 🚀 Get Started! 🚀

To use this `rooroo` agent team:

1.  **Install Roo Code:** Ensure the [Roo Code VS Code extension](https://marketplace.visualstudio.com/items?itemName=RooVeterinaryInc.roo-cline) is installed.
2.  **Override Local Modes:** Copy the latest `.roomodes` file (v0.1.0+) into your workspace root.
3.  **Reload VS Code:** Use `Ctrl+Shift+P` or `Cmd+Shift+P` -> "Developer: Reload Window".
4.  **Activate the Planner:** Open Roo Code chat, select **🏛️ Strategic Planner**.
5.  **State Your Goal:** Describe the project or task. The Planner will create the initial plan and state files.
6.  **Automatic Handoff:** The Planner should automatically switch control to the **🚦 Workflow Coordinator** using `<switch_mode>`. If not, manually switch to the Coordinator mode.
7.  **Collaborate with Coordinator:** Follow the Coordinator's lead as it delegates tasks (to specialists or built-in modes), asks for decisions (e.g., about testing), and reports progress based on `project_overview.json`.
8.  **Manage Documentation:** Ask the Coordinator to delegate `init` or `update` tasks to the **✍️ DocuCrafter**.
9.  **Review Artifacts & State:** Monitor progress via `.specs/`, `.design/`, `.docs/`, `.reports/` and state files.

Let `rooroo` bring **structured, two-stage orchestration** and **specialized expertise** to your AI development!
