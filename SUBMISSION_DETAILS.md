# Flutter Butler - Hackathon Submission

## Project Name
**Recall: The Flutter Butler**

## Project Description
**Recall** is an intelligent personal assistant application designed to act as your digital "Butler". Built to help you stay on top of your chaotic digital life, Recall aggregates your emails, manages your agenda, and listens to your voice commands to keep you organized.

Unlike standard to-do apps, Recall leverages **Serverpod** for a robust, Dart-based backend that handles complex background synchronization tasks (like fetching emails via Google APIs) while delivering a smooth, native experience on mobile using **Flutter**.

### Key Features
- **🗣️ Voice-First Interface**: Just speak to your Butler. Using on-device speech-to-text, you can add notes, query your schedule, or set reminders without typing.
- **📧 Smart Sync**: Automatically syncs with your Gmail to highlight important messages and seamlessly integrates them into your daily dashboard.
- **📅 Agenda Management**: Aggregates your calendar and tasks into a single, easy-to-read timeline.
- **🧠 Groq AI Intelligence**: Uses **Groq (Llama 3)** for ultra-fast intent recognition, meeting summarization, and context-aware RAG responses.
- **🔔 Intelligent Notifications**: Uses Firebase Cloud Messaging (FCM) to nudge you at the right time, ensuring you never miss a beat.
- **⚡ Real-time & Offline**: Built with Hive for local caching and Serverpod for real-time updates, ensuring the app is always fast and responsive, efficiently syncing when back online.

### How It Was Built
The project is a full-stack Dart application:
- **Backend (Serverpod)**: Acts as the brain. It handles authentication (Google Sign-In), manages the PostgreSQL database, and runs scheduled background jobs (Future Calls) to sync external data like Gmail. It exposes a type-safe API that the Flutter client consumes directly.
- **Frontend (Flutter)**: A riverpod-based reactive UI. It uses `speech_to_text` for voice inputs, acts as the presentation layer for the Serverpod protocol-generated models, and manages local state for a fluid user experience.
- **AI Layer**: We switched from Gemini to **Groq** to leverage the blazing fast inference speeds of Llama 3, ensuring our "Butler" responds instantly to voice commands and queries.

1.  **Future Calls for Background Sync**: 
    - We utilize **Future Calls** (`GmailSyncFutureCall`) to handle heavy lifting like Gmail synchronization in the background. This ensures the user UI remains snappy while the server processes thousands of emails asynchronously.
    - *Efficiency Win*: Decoupling sync logic from API endpoints prevents timeouts and keeps the dashboard real-time.

2.  **Type-Safe Communication**:
    - By defining our data models (Agenda Items, Chat Messages) in `.spy.yaml` files, we generated client-side code automatically.
    - *Efficiency Win*: This eliminated "magic strings" and serialization errors entirely. If the backend model changes, the Flutter client knows immediately at compile time.

3.  **Serverpod Auth & Firebase Integration**:
    - We integrated standard implementation of Serverpod's authentication module for secure Google Sign-In, effectively managing user sessions without reinventing the wheel.
    - *Efficiency Win*: We skipped weeks of boiler-plate auth code and went straight to building features.

4.  **PostgreSQL with Serverpod ORM**:
    - The generated ORM methods made database interactions seamless. We used complex queries to filter and aggregate agenda items without writing raw SQL, keeping our codebase clean and maintainable.

---

## Demo Video Script (3 Minute Limit)

**[0:00 - 0:30] Intro & The Problem**
* **Visual**: Fast cuts of a busy calendar, unread emails, and a stressed user.
* **Audio**: "We all have too much to remember. Meetings, emails, tasks... it's easy to get overwhelmed. Meet Recall—your personal Flutter Butler."
* **Visual**: Logo reveal of 'Recall', transitioning to the clean, calm Home Screen of the app.

**[0:30 - 1:00] Powered by Serverpod (The Brain)**
* **Visual**: Split screen: Left side shows `protocol/*.spy.yaml` files, Right side shows the generated Dart code.
* **Audio**: "Recall isn't just another wrapper. It's powered by **Serverpod**. We used Serverpod's **Future Calls** to build a robust background sync engine that processes your digital life without draining your battery."
* **Visual**: A graphic showing "Gmail API" -> "Serverpod Future Call" -> "Postgres DB" -> "Flutter Client".
* **Audio**: "While you focus on your day, our Serverpod backend is asynchronously organizing your agenda, ensuring data consistency with strong typing from server to client."

**[1:00 - 1:40] Feature: Voice & Real-time Dashboard**
* **Visual**: User taps microphone. "Add meeting with Alex tomorrow."
* **Audio**: "Voice commands are processed instantly. Thanks to Serverpod's generated client, our Flutter app talks directly to the API with zero friction."
* **Action**: item appears instantly on the dashboard.

**[1:40 - 2:30] Deep Dive: Efficiency & Architecture**
* **Visual**: Scrolling through the `recall_server` project structure. Highlighting `endpoints` and `migrations`.
* **Audio**: "We leveraged the generated ORM to handle complex queries for your daily agenda. No raw SQL, just clean Dart code. And with Serverpod Authentication, your data stays secure."

**[2:30 - 3:00] Conclusion**
* **Visual**: User closing the app with a sense of relief/accomplishment. Final screen with GitHub Repository link.
* **Audio**: "Recall. Built with Flutter, supercharged by Serverpod. Check out the code to see our Future Calls in action."



### Architecture Diagram (Mermaid)

`mermaid
graph TD
    User[User] -->|Voice/Touch| Flutter[Flutter App]
    Flutter -->|Websocket/HTTP| Serverpod[Serverpod Backend]
    
    subgraph "Serverpod Server"
        Serverpod -->|Auth| GoogleAuth[Google Sign-In]
        Serverpod -->|ORM| Postgres[(PostgreSQL)]
        Serverpod -->|Background Job| FutureCalls[Future Calls]
    end
    
    FutureCalls -->|Fetch Emails| Gmail[Gmail API]
    FutureCalls -->|Analyze Content| Groq[Groq API (Llama 3)]
    
    Groq -->|Intent/Summary| Serverpod
    Gmail -->|Raw Data| Serverpod
    
    Serverpod -->|Push Notification| FCM[Firebase Cloud Messaging]
    FCM -->|Alert| Flutter
``n
### NotebookLM Context (For PPT Generation)
*Use the following text as a source in NotebookLM to generate your presentation:*

**Title**: Recall - The Intelligent Flutter Butler
**Problem**: Modern professionals are overwhelmed by digital noise�cluttered inboxes, scattered calendars, and forgotten tasks. Existing tools are passive; they wait for input.
**Solution**: Recall is an *agentic* personal relationship manager. It proactively syncs your data, understands your context, and whispers what matters.
**Tech Stack**:
*   **Flutter**: For a beautiful, native cross-platform experience.
*   **Serverpod**: The Dart-native backend. chosen for its "Future Calls" (background processing) and "Type-Safe" protocol generation.
*   **Groq (Llama 3)**: Selected for its sub-second latency, making the AI feel real-time and conversational.
*   **PostgreSQL**: For robust data storage.
**Key Differentiators**:
1.  **Voice-First**: Designed for "on-the-go" usage.
2.  **Privacy-Centric**: Your data is processed by your own "Butler" instance.
3.  **Speed**: Groq + Serverpod + Flutter = Instant interactions.
