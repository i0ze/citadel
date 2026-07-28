# Citadel

> **Work boards that are truly convenient to use.**

Citadel is a real-time collaborative workspace web application (inspired by Miro, Trello, and FigJam). Built on top of the Erlang VM using Elixir and Phoenix LiveView, it provides seamless, instant synchronization of boards and stickers across multiple users.

## Features

- **Real-Time Collaboration:** Instant state synchronization across all connected clients via `Phoenix PubSub`.
- **Interactive Boards:** Create, edit, and move stickers smoothly using custom Vanilla JS Drag & Drop hooks integrated with LiveView.
- **Role-Based Access Control:** Strict permission system defining Owners, Editors, and Viewers.
- **Smart Invites:** Secure, time-limited hash-token invitation links.
- **Secure Authentication:** Full auth flow with email verification (powered by `Swoosh` and `Bcrypt`).

## 🛠 Tech Stack

- **Core:** Elixir (~1.15), Phoenix LiveView (~1.1.0)
- **Database:** PostgreSQL, Ecto
- **Frontend:** HTML HEEx, Tailwind CSS v4, Vanilla JS for Drag & Drop
- **Server/HTTP:** Bandit, Req

## License
This project is licensed under the [GNU Affero General Public License v3.0](LICENSE).
