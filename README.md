# Shared ToDo

A collaborative todo list app backed by a Node.js + PostgreSQL REST API ([shared-todo-api](https://github.com/kadjrkoroglu/shared-todo-api)).

## Features

- **Authentication**: Email/password registration and login
- **Unique ID System**: 6-digit unique ID for each user
- **Friend System**: Add friends by their unique ID
- **Shared Lists**: Create and manage shared todo lists with friends
- **Personal Tasks**: A private task list per user
- **Refresh**: Pull to refresh (no real-time sync)

## Tech Stack

- Flutter, Provider, Clean Architecture (data / domain / presentation)
- REST API client (`http`), JWT stored with `flutter_secure_storage`
- Backend: Node.js, Express, PostgreSQL, Prisma, Docker (deployed on Railway)


<img width="1200" height="900" alt="collage" src="https://github.com/user-attachments/assets/85dbc3f2-4e5a-45ea-ac89-329b5dc679bc" />

