# Flutter Todo - Riverpod 3.x + Supabase + Clean Architecture

A production-ready Flutter todo application built with Riverpod 3.x state management, Supabase backend, and Clean Architecture principles.

## Features

- ✅ **Clean Architecture** - Separation of concerns with domain, data, and presentation layers
- 🎯 **Riverpod 3.x** - Type-safe state management with code generation
- 🔥 **Supabase** - Backend as a Service (authentication, real-time database)
- 🧊 **Freezed** - Immutable models with code generation
- 🗺️ **Go Router** - Declarative routing with authentication guards
- 🎨 **Material Design 3** - Modern UI with custom theming
- 🌍 **Localization** - Turkish date/time formatting support
- ⚡ **Real-time updates** - Live todo list synchronization

## Architecture

```
lib/
├── core/                    # Shared utilities and configurations
│   ├── config/             # App configuration (theme, Supabase)
│   ├── router/             # Navigation setup
│   ├── utils/              # Error handling utilities
│   └── widgets/            # Reusable widgets
├── features/               # Feature modules
│   ├── auth/              # Authentication feature
│   │   ├── data/          # Data sources, models, repositories
│   │   ├── domain/        # Entities, repository interfaces
│   │   └── presentation/  # UI, providers, screens
│   └── todos/             # Todos feature
│       ├── data/
│       ├── domain/
│       └── presentation/
└── main.dart              # App entry point
```

## Tech Stack

- **Flutter SDK** ^3.9.2
- **State Management:** Riverpod 3.0.3 + Hooks
- **Backend:** Supabase 2.10.3
- **Navigation:** Go Router 16.3.0
- **Code Generation:** Freezed 3.2.3, Build Runner 2.6.1
- **Linting:** Flutter Lints 6.0.0, Riverpod Lint 3.0.3

## Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK (3.9.2 or higher)
- A Supabase account and project

### Installation

1. Clone the repository:
```bash
git clone https://github.com/YOUR_USERNAME/flutter_todo_riverpod_supabase.git
cd flutter_todo_riverpod_supabase
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate code:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Configure Supabase:
   - Update `lib/core/config/supabase_config.dart` with your Supabase URL and key

5. Run the app:
```bash
flutter run
```

## Supabase Setup

Create a `todos` table in your Supabase project:

```sql
create table todos (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users not null,
  task text not null,
  completed boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable Row Level Security
alter table todos enable row level security;

-- Create policies
create policy "Users can view their own todos"
  on todos for select
  using (auth.uid() = user_id);

create policy "Users can insert their own todos"
  on todos for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own todos"
  on todos for update
  using (auth.uid() = user_id);

create policy "Users can delete their own todos"
  on todos for delete
  using (auth.uid() = user_id);
```

## Project Highlights

### Clean Architecture Layers

- **Domain Layer:** Pure Dart business logic, framework-independent
- **Data Layer:** API integration, data models with JSON serialization
- **Presentation Layer:** UI components, state management, user interaction

### Code Generation

The project uses code generation for:
- Riverpod providers (`*.g.dart`)
- Freezed immutable models (`*.freezed.dart`, `*.g.dart`)
- JSON serialization

### Error Handling

Centralized error handling with user-friendly messages for:
- Authentication errors
- Network errors
- Database errors
- Validation errors

## License

This project is licensed under the MIT License.

## Author

Built with ❤️ using Flutter
