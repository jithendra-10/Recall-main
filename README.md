# Recall: The Flutter Butler 🤖✨

> **Your intelligent, voice-first personal relationship manager.**

**Recall** is not just another to-do list. It is an agentic "Butler" that proactively organizes your digital life. By aggregating your emails, managing your agenda, and listening to your voice commands, Recall helps you stay on top of the chaos without being glued to your screen.

---

## 🚀 Why Recall?

Modern professionals are overwhelmed by digital noise—cluttered inboxes, scattered calendars, and forgotten networking follow-ups. Existing tools are passive; they wait for you to input data.

**Recall is different.**
*   **It listens**: Add tasks or query your schedule purely by voice.
*   **It acts**: Automatically syncs and analyzes your Gmail in the background to find what matters.
*   **It remembers**: Keeps track of your connections and context so you don't have to.

---

## 🏗️ Tech Stack

This project is a masterclass in **Dart Full Stack** development, leveraging the power of **Serverpod** to build a robust, scalable backend with ease.

| Component | Technology | Description |
| :--- | :--- | :--- |
| **Backend** | **Serverpod** | The Dart-native server. Handles API generation, database ORM, and background jobs. |
| **Frontend** | **Flutter** | A beautiful, reactive UI built for performance on iOS and Android. |
| **AI Engine** | **Groq (Llama 3)** | Blazing fast inference for real-time intent recognition and summarization. |
| **Database** | **PostgreSQL** | Robust relational data storage, managed via Serverpod ORM. |
| **Notifications** | **Firebase (FCM)** | Intelligent push notifications to nudge you at the right time. |
| **Sync** | **Google APIs** | Deep integration with Gmail for background synchronization. |

---

## 🏛️ Architecture

We leverage **Serverpod's Future Calls** to decouple heavy processing from the user interface, ensuring the app feels instant while the backend crunches data.

```mermaid
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
```

---

## ✨ Key Features

### 🗣️ Voice-First Interface
Don't type. Just talk.
*   *"Remind me to call Alex tomorrow at 2 PM."*
*   *"What do I have scheduled for today?"*
*   Recall uses on-device speech-to-text to capture your intent instantly.

### 📧 Smart Sync (Powered by Future Calls)
Your Butler works while you sleep.
*   Recall periodically syncs with your **Gmail** using Serverpod's background workers.
*   It filters out spam and newsletters, identifying only personal or professional correspondence that needs action.

### 🧠 Groq AI Intelligence
*   We replaced standard LLMs with **Groq (Llama 3)** for sub-second latency.
*   The AI summarizes long email threads, extracts meeting details, and even drafts context-aware replies.

### 📅 Unified Agenda
*   See your meetings, tasks, and reminders in one simple, linear timeline.
*   Real-time updates via Serverpod's WebSocket connection mean your dashboard is always in sync.

---

## 🛠️ Getting Started

### Prerequisites
*   **Docker** (for running PostgreSQL and Redis)
*   **Dart SDK** (>= 3.0)
*   **Flutter SDK** (>= 3.19)

### 1. Clone the Repository
```bash
git clone https://github.com/jithendra-10/Recall-main.git
cd Recall-main
```

### 2. Environment Configuration
Security is paramount. Create a `.env` file in the root directory (and copy it to `recall_server/` and `recall_flutter/` assets if needed by your setup script).

**Required Keys:**
```env
# AI Provider
GROQ_API_KEY=your_groq_api_key

# Google OAuth (for Auth & Gmail)
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret

# Server Configuration
SERVER_URL=http://localhost:8080/
```

### 3. Start the Backend
Navigate to the server directory and start the docker containers.
```bash
cd recall_server
docker-compose up -d --build
```

Run the migrations and start the server:
```bash
dart bin/main.dart --apply-migrations
dart bin/main.dart
```

### 4. Run the App
Open a new terminal configuration.
```bash
cd recall_flutter
flutter run
```

---

## 📂 Project Structure

*   **`/recall_server`**
    *   `lib/src/endpoints`: API definitions (The "Controller" layer).
    *   `lib/src/protocol`: Data models defined in `.spy.yaml` (The "Model" layer).
    *   `lib/src/future_calls`: Background jobs for Gmail sync (The "Worker" layer).
*   **`/recall_client`**
    *   Auto-generated Dart client code. **Do not edit manually.**
*   **`/recall_flutter`**
    *   The mobile application code, structured by features (Auth, Dashboard, Settings).

---

## 🏆 Hackathon Submission

This project was built for the **Serverpod Hackathon**.
*   **Serverpod Version**: 1.2
*   **AI Model**: Llama 3-70b via Groq

---

Made with ❤️ by [Your Name/Team Name]
