# Wishboard

![Ruby](https://img.shields.io/badge/Ruby-3.3.0-CC342D?style=flat&logo=ruby&logoColor=white)
![Rails](https://img.shields.io/badge/Rails-7.1-CC0000?style=flat&logo=rubyonrails&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791?style=flat&logo=postgresql&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-7-DC382D?style=flat&logo=redis&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?style=flat&logo=docker&logoColor=white)
![ActionCable](https://img.shields.io/badge/ActionCable-WebSockets-CC0000?style=flat&logo=rubyonrails&logoColor=white)
![Bootstrap](https://img.shields.io/badge/Bootstrap-3-7952B3?style=flat&logo=bootstrap&logoColor=white)
![Cloudinary](https://img.shields.io/badge/Cloudinary-Image%20CDN-3448C5?style=flat&logo=cloudinary&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Push%20Notifications-FFCA28?style=flat&logo=firebase&logoColor=black)
![HAML](https://img.shields.io/badge/HAML-Templates-ECB753?style=flat)

A wish-based social media platform where users post, share, and fundraise for their aspirations — with real-time chat powered by ActionCable.

---

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Real-Time Chat (ActionCable)](#real-time-chat-actioncable)
- [Data Model](#data-model)
- [Docker Setup](#docker-setup)
- [Environment Variables](#environment-variables)
- [Getting Started (Local)](#getting-started-local)
- [Admin Dashboard](#admin-dashboard)

---

## Features

- **Wishes (Showcases)** — Users post three types of wishes:
  - _Showpiece_ — already fulfilled aspirations
  - _Wish_ — future aspirations with optional funding goals
  - _Instant_ — momentary/in-the-moment wishes
- **Social graph** — Follow/follower system with an interest-based discovery feed
- **Crowdfunding** — Fund other users' wishes directly (Cocotransfer system)
- **Wows & Comments** — Appreciation and discussion on wishes
- **Collections** — Curate and organize wishes into named boards
- **Real-time Chat** — Public and private chat rooms with live presence indicators
- **Rental Marketplace** — List products for rent or giveaway; booking & payment flow
- **Giveaways** — Users offer items for free to the community
- **Notifications** — Real-time push and in-app notifications via Firebase and ActionCable
- **User Wiki** — Personal info pages per user
- **Assistance Requests** — Ask the community for help fulfilling a wish
- **Admin Panel** — Forest Liana-backed admin with user verification, moderation, and fund management

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                        Browser                          │
│          (HAML + Bootstrap 3 + Vanilla JS)              │
└────────────────────┬────────────────────────────────────┘
                     │  HTTP / WebSocket
┌────────────────────▼────────────────────────────────────┐
│               Rails 7.1 Application (Puma)              │
│                                                         │
│  ┌──────────────┐   ┌────────────────┐   ┌──────────┐   │
│  │  Controllers │   │  ActionCable   │   │   Jobs   │   │
│  │  (REST API)  │   │   Channels     │   │(ActiveJob│   │
│  └──────┬───────┘   └───────┬────────┘   └────┬─────┘   │
│         │                   │                 │         │
│  ┌──────▼───────────────────▼─────────────────▼──────┐  │
│  │                    Models (ActiveRecord)          │  │
│  └──────────────────────────┬────────────────────────┘  │
└─────────────────────────────┼───────────────────────────┘
                              │
            ┌─────────────────┴──────────────────┐
            │                                    │
┌───────────▼──────────┐           ┌─────────────▼────────┐
│   PostgreSQL 15      │           │     Redis 7          │
│   (Primary DB)       │           │  ActionCable Pub/Sub │
│                      │           │  + Session Cache     │
└──────────────────────┘           └──────────────────────┘

External Services
  ├── Cloudinary     — Image storage & CDN
  ├── Firebase FCM   — Mobile push notifications
  ├── Plivo          — SMS OTP
  ├── Citrus Pay     — Payment gateway
  ├── OmniAuth/FB    — Social login (Facebook)
  └── Forest Liana   — Admin dashboard SaaS
```

### Key Design Decisions

| Concern             | Solution                                 |
| ------------------- | ---------------------------------------- |
| Real-time messaging | ActionCable over Redis pub/sub           |
| Image uploads       | CarrierWave + Cloudinary CDN             |
| Authentication      | Devise (email/password + Facebook OAuth) |
| Templating          | HAML with Bootstrap 3                    |
| Search              | Searchkick (Elasticsearch-based)         |
| Pagination          | Kaminari + Bootstrap                     |
| SEO URLs            | FriendlyId slugs                         |
| PDF generation      | WickedPDF + wkhtmltopdf                  |
| Deployment          | Capistrano                               |

---

## Tech Stack

| Layer              | Technology                     |
| ------------------ | ------------------------------ |
| Language           | Ruby 3.3.0                     |
| Framework          | Ruby on Rails 7.1.3            |
| Database           | PostgreSQL 15                  |
| Cache / Pub-Sub    | Redis 7                        |
| Web Server         | Puma 5                         |
| Templates          | HAML                           |
| CSS Framework      | Bootstrap 3                    |
| Image Storage      | Cloudinary (CarrierWave)       |
| WebSockets         | ActionCable                    |
| Background Jobs    | ActiveJob                      |
| Authentication     | Devise + OmniAuth (Facebook)   |
| Push Notifications | Firebase Cloud Messaging (FCM) |
| SMS                | Plivo                          |
| Payments           | Citrus Pay                     |
| Search             | Searchkick                     |
| Admin              | Forest Liana                   |
| Containerization   | Docker + Docker Compose        |

---

## Real-Time Chat (ActionCable)

Wishboard uses **ActionCable** (Rails' built-in WebSocket layer) backed by **Redis** for real-time features.

### Channels

| Channel         | Stream Key       | Purpose                                             |
| --------------- | ---------------- | --------------------------------------------------- |
| `ChatChannel`   | `chat_room_<id>` | Room messages + member presence (online/offline)    |
| `UserChannel`   | `user_<id>`      | Personal notifications, wish updates, unread counts |
| `GlobalChannel` | `global_channel` | System-wide broadcasts                              |

### Chat Flow

```
User types message
      │
      ▼
ChatChannel#save_message
      │  saves to chat_messages table
      ▼
ChatBroadcastJob
      │  broadcasts via Redis
      ▼
chat_room_<id> stream
      │
      ├──► All room members: new message HTML
      └──► Each member's UserChannel: updated unread badge count
```

### Presence Tracking

- `Membership` records store `online` boolean and `last_seen` timestamp.
- `ChatChannel#subscribed` marks user online and broadcasts presence via `AppearanceBroadcastJob`.
- `ChatChannel#unsubscribed` marks user offline when all connections close (multiple-tab safe).

### Cable Configuration (`config/cable.yml`)

```yaml
development:
  adapter: redis
  url: <%= ENV["REDIS_URL"] %>

production:
  adapter: redis
  url: <%= ENV["REDIS_URL"] %>
```

---

## Data Model

### Core Entities

```
User
 ├── Profile          (name, avatar, bio, business settings)
 ├── Wallet           (balance for crowdfunding)
 ├── Showcase (many)  (wishes — Showpiece / Wish / Instant)
 │    ├── Wow (many)
 │    ├── Comment (many)
 │    ├── Coin (many)        ← appreciation/recognition
 │    ├── Tagging (many) ──► Tag
 │    └── AssistanceRequest (many)
 ├── Product (many)   (rental / giveaway listings)
 │    └── Transaction (many)
 ├── ChatRoom (many, through Membership)
 │    └── ChatMessage (many)
 ├── Relationship (many) ──► User  (follow graph)
 ├── Interest (many) ──► Tag       (preference graph)
 └── Collection (many) ──► Showcase (curated boards)
```

### Payment / Transfer Flow

```
Cocotransfer  (polymorphic: Showcase or User)
 ├── funds_amount, wallet_amount, coins
 ├── payment_status  (pending / completed / failed)
 └── transaction_status

Withdraw      ← user withdraws accumulated funds
Txdetail      ← per-item breakdown of a Transaction
```

### Showcase Hierarchy

Wishes support a parent/grandparent structure to represent evolution of an aspiration (e.g., a Wish becoming a Showpiece once fulfilled), tracked via `parent_id` and `grandparent_id` foreign keys on the `showcases` table.

---

## Docker Setup

The application ships with a ready-to-use `docker-compose.yml` for local development and deployment.

### Services

| Service | Image                   | Purpose                                                |
| ------- | ----------------------- | ------------------------------------------------------ |
| `db`    | `postgres:15`           | Primary database (persists via `shared-pgdata` volume) |
| `redis` | `redis:7`               | ActionCable pub/sub + session cache                    |
| `web`   | Built from `Dockerfile` | Rails + Puma application server                        |

### Start Everything

```bash
# Build and start all services
docker compose up --build

# Run in the background
docker compose up --build -d

# View logs
docker compose logs -f web
```

The `entrypoint.sh` script automatically:

1. Waits until PostgreSQL accepts connections
2. Runs `rails db:prepare` (creates DB + runs migrations if needed)
3. Starts Puma

### Dockerfile Highlights

```
Base image : ruby:3.3.0
System deps: postgresql-client, Node.js, Yarn,
             ImageMagick, wkhtmltopdf, libvips
Assets     : precompiled at build time (production target)
Server     : Puma (configured via config/puma.rb)
```

### Useful Commands

```bash
# Open a Rails console inside the running container
docker compose exec web rails console

# Run database migrations
docker compose exec web rails db:migrate

# Tail application logs
docker compose logs -f web

# Stop all services
docker compose down

# Remove volumes (wipes the database)
docker compose down -v
```

---

## Environment Variables

Copy `.env.example` to `.env` (or set the variables in your environment) before starting:

| Variable                | Description                                                         |
| ----------------------- | ------------------------------------------------------------------- |
| `POSTGRES_USER`         | PostgreSQL username                                                 |
| `POSTGRES_PASSWORD`     | PostgreSQL password                                                 |
| `POSTGRES_HOST`         | PostgreSQL host (e.g. `db` in Docker)                               |
| `POSTGRES_DB`           | Database name                                                       |
| `REDIS_URL`             | Redis connection URL (e.g. `redis://redis:6379/1`)                  |
| `CLOUDINARY_CLOUD_NAME` | Cloudinary cloud name                                               |
| `CLOUDINARY_API_KEY`    | Cloudinary API key                                                  |
| `CLOUDINARY_API_SECRET` | Cloudinary API secret                                               |
| `FIREBASE_SERVER_KEY`   | Firebase FCM server key                                             |
| `PLIVO_AUTH_ID`         | Plivo SMS auth ID                                                   |
| `PLIVO_AUTH_TOKEN`      | Plivo SMS auth token                                                |
| `CITRUS_MERCHANT_ID`    | Citrus Pay merchant ID                                              |
| `CITRUS_SECRET_KEY`     | Citrus Pay secret key                                               |
| `FACEBOOK_APP_ID`       | Facebook OAuth app ID                                               |
| `FACEBOOK_APP_SECRET`   | Facebook OAuth app secret                                           |
| `SECRET_KEY_BASE`       | Rails secret key base                                               |
| `ACTION_CABLE_URL`      | Full WebSocket URL for ActionCable (e.g. `wss://yourapp.com/cable`) |

---

## Getting Started (Local)

### Prerequisites

- Docker & Docker Compose, **or**
- Ruby 3.3.0, PostgreSQL 15, Redis 7, Node.js, Yarn

### With Docker (recommended)

```bash
git clone <repo-url>
cd wishboard

# Set up environment variables
cp .env.example .env  # edit values as needed

# Build and start
docker compose up --build
```

Visit `http://localhost:3000`.

### Without Docker

```bash
bundle install
yarn install

# Configure database
cp config/database.yml.example config/database.yml  # edit credentials

rails db:create db:migrate db:seed

# Start Redis separately, then:
rails server
```

---

## Admin Dashboard

Wishboard uses **Forest Liana** as its admin panel, mounted at `/forest`.

Core admin capabilities:

- User verification and locking
- Product approval / featured flagging
- Fund transfer (Cocotransfer) management
- Withdrawal processing
- Firebase push notification broadcast

Admin-specific controllers live under `app/controllers/admin/`.

---

## License

This project is open-source and available under the [MIT License](https://opensource.org/licenses/MIT).
