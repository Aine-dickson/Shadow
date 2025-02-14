# Shadow

A feature-rich, WhatsApp-inspired chat application built with **Rust** (backend) and **Vue** (web frontend). This project goes beyond traditional messaging, introducing unique features like ghost messaging, stealth mode, and scheduled messages. It showcases a blend of real-time communication, security, privacy and user-centric design.

---

## Features

### Core Features
- **User Authentication**
  - Secure login via QR code or email/password.
  - Session management with multi-device support.

- **End to End encryption**
  - Messages and every kind of media shared over **Shadow**
  - On device key generation (public and private)

- **Real-Time Messaging**
  - One-to-one and group chats with WebSocket support.
  - Message statuses: Sent, Delivered, Read.

- **Multimedia Sharing**
  - Send/receive images, videos, voice notes, and documents.
  - Drag-and-drop file upload.
 
- **Calls**
  - Group and private calls for non ghost chats
  - Merge private calls to conference calls

- **Status updates**
  - Share stories to all contacts or selected ones
  - Set status expiry to not more than 24hr

- **Search and Filters**
  - Search messages and chats.
  - Filter by date, media type, and more.

- **Articles**
  - Space for writers.
  - Articles can stay forever until writer suspends it

### Fancy Features
- **Ghost Messaging**: Send messages to anonymous like-minded people anonymously. Ghost chats dissapear when app is closed/logged out or at a defined initiator time
- **Scheduled Messaging**: Schedule messages to be sent at a later time once or at an interval.
- **Stealth Mode**: Browse chats, status updates without updating "last seen" or "read receipts" or "views" on status
- **Rewind && fast forward on status**: Gain more control on status update viewing. Rewind, pause or fast forward media
- **Extra privace on status**: Choose who can see your status, whether viewers can screenshot/record your status updates
- **Scheduled statuses**: Choose when to update a given status allowing send before
- **Custom status expiration**: Set after how long the status update expires, a duration not more than 24hrs
- **No capture mode**: Determine whether your status updates, or profile photo or chats can be screenshot or recorded
- **Message Recall**: Unsend messages within a specific time frame when unread.
- **Selective message visibility**: Choose who can see a message sent to a group chat
- **Auto-Reply**: Configure automated responses for when you're unavailable.
- **Advanced Analytics**: Visualize messaging habits and trends.
- **Chat Themes**: Customize chat backgrounds, text colors, and fonts.
- **Multi-Language Support**: Translate messages on the fly.
- **Call merging**: Support for merging more than one private calls to a conference call
- **Collaborative Groups**: Shared to-do lists, polls, and file storage.

---

## Roadmap
- [ ] Authentication and registration implementation
- [ ] Text message chatting implementation
- [ ] Articles feature implementation
- [ ] Status updates feature engineering
- [ ] Include Video and voice calls
- [ ] Implement Ghost messaging feature
- [ ] Implement stealth mode
- [ ] Implement app automations, i.e auto-reply, message recall, scheduling
- [ ] Settings implementation
- [ ] Implement not capture mode
- [ ] Translation feature
- [ ] Enhance group collaboration features with task management.
- [ ] Implement advanced analytics for visaualization

## Tech Stack

### Backend
- **Framework**: [Axum](https://github.com/tokio-rs/axum) for REST APIs and WebSocket support.
- **Database**: PostgreSQL for relational data, Redis for caching.
- **Encryption**: End-to-end encryption with Rust's `ring` library.
- **Storage**: AWS S3 or MinIO for media uploads.

### Frontend
- **Framework**: [Vuejs](https://vuejs.org/) for building the web user interface.
- **Real-Time Updates**: WebSocket client for live messaging.
- **Responsive Design**: Optimized for desktop and mobile browsers.

### Additional Tools
- **Push Notifications**: Firebase Cloud Messaging.
- **Background Tasks**: Cron jobs or task queues for scheduled and ghost messages.

---

## Installation

### Prerequisites
- Rust installed ([instructions](https://www.rust-lang.org/tools/install)).
- PostgreSQL and Redis installed and running.

### Backend Setup
1. Clone the repository:
   ```bash
   git clone https://github.com/aine-dickson/Shadow.git
   cd Shadow/backend
   ```
2. Install dependencies:
   ```bash
   cargo build
   ```
3. Configure the `.env` file:
   ```env
   DATABASE_URL=postgres://username:password@localhost/awesome_whatsapp
   REDIS_URL=redis://127.0.0.1:6379
   JWT_SECRET=your_secret_key
   ```
4. Run migrations:
   ```bash
   diesel migration run
   ```
5. Start the server:
   ```bash
   cargo watch -x run
   ```

### Frontend Setup
  Server Side rendered

---

## Usage
1. Open the application in your browser at `http://localhost:3000`.
2. Log in or register to start chatting.
3. Explore features like ghost messaging, scheduling, and more!

---

---

## Contributing
Contributions are welcome! To contribute:
1. Fork the repository.
2. Create a feature branch (`git checkout -b feature-name`).
3. Commit your changes (`git commit -m 'Add feature name'`).
4. Push to the branch (`git push origin feature-name`).
5. Open a pull request.

---

## License
This project is licensed under the MIT License. See the `LICENSE` file for details.

---

## Acknowledgements
- [Actix](https://actix.rs/)
- [Leptos](https://github.com/leptos-rs/leptos)
- [Rust](https://www.rust-lang.org/)

---

**Built with ❤️ using Rust, Actix-web and Leptos**.
