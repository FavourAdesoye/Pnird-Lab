# PNIRD Lab Mobile App — Overview for University IT

**Contact:** info@pnirdlab.com · Website: https://www.pnird.com/

**Privacy policy:** In-app privacy notice is live. A public web policy is planned at https://www.pnird.com/privacy (not published yet — pending domain access). Terms of use not yet published.

## What it is
**PNIRD Lab** is a mobile app for Virginia State University’s Psychology Department research lab. It connects **lab staff** and **community members** (students and participants) around lab updates, research studies, and events—not a clinical records system.

## Main features
- **Accounts & roles:** Staff and community sign-in (staff onboarding uses an invite code)
- **Home / feed:** Lab posts with images, likes, and comments
- **Studies & events:** Browse studies and events; staff create and manage them
- **Messaging:** Real-time DMs. Staff can message any user; community members can message staff only. Community members cannot message each other.
- **Search:** Find posts, studies, events, and users by username
- **Profiles:** Username, bio, and profile photo
- **Notifications:** Alerts for messages and study/event broadcasts
- **Games:** Optional cognitive / brain-training games on the device
- **Lab chatbot:** Q&A about the lab (research areas, director, publications)

## Data we store (MongoDB)
| Data | Examples | Notes |
|------|----------|--------|
| **User profiles** | Username, email, role, bio, profile photo URL, Firebase user ID | Passwords are **not** stored in our DB (Firebase Auth handles sign-in) |
| **Posts & comments** | Text, images, likes, replies | Only staff can create posts; signed-in users can like and comment |
| **Studies & events** | Titles, descriptions, images, dates, locations, optional external form links | |
| **Direct messages** | Sender/recipient IDs, message text, read status | Stored as plaintext in our database |
| **Notifications** | Alert text and references to related content | |
| **Chatbot conversations** | User questions and bot replies | Saved by default (~30 days); can be disabled in server config |

**Media** (profile photos, post/study images) is hosted on **Cloudinary** (URLs stored in MongoDB).

We do **not** treat this app as an EHR. Users are advised not to share sensitive health or research data in the chatbot or chats.

## AI capabilities
- Lab assistant powered by **OpenAI** (chat + embeddings)
- Answers questions about the lab using a curated lab document (RAG), not open web browsing of student records
- Conversation history can be saved briefly for continuity, with retention limits and purge
- Chatbot access requires a signed-in user

## Technology stack
| Layer | Technology |
|-------|------------|
| Mobile app | **Flutter** (iOS / Android; web not the primary target) |
| Backend API | **Node.js + Express** |
| Database | **MongoDB** |
| Authentication | **Firebase Authentication** (token-verified on the API) |
| Real-time chat | **Socket.IO** |
| Image hosting | **Cloudinary** |
| AI | **OpenAI** API |
| Session storage (app) | Secure device storage for auth session |

Security practices already in place include Firebase token checks on private APIs and sockets, staff-only write access for studies/events/posts, CORS and rate limiting, reduced exposure of emails on public endpoints, chatbot retention controls, in-app deletion of messages/notifications/chatbot history, and **full account deletion** (Settings → Delete Account) that removes the user’s app data and Firebase login.

## What we’re asking of IT
Access to the university’s **Apple App Store / Google Play** developer accounts (or equivalent distribution process) so the PNIRD Lab app can be published under VSU, with university review of privacy, data handling, and third-party processors (Firebase, MongoDB host, Cloudinary, OpenAI).
