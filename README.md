# RFID Manager - Flutter Application

A comprehensive Flutter mobile application for managing RFID systems with real-time monitoring, analytics, and user management features.

## Features
![Home](Images/Appl.jpg)
### 🔐 Authentication
- Secure email/password authentication via Supabase Auth
- Session management with persistent login
- Password reset functionality
- User profile management

### 🏠 Dashboard (Home)
- Real-time system overview
- Statistics cards showing:
  - Total RFID readers
  - Active readers count
  - Total tags tracked
  - Today's scan count
- System status monitoring
- Quick action navigation

### 📊 Analytics
- Interactive scan activity trends
- Top performing tags analysis
- Daily/weekly/monthly scan charts
- Performance metrics
- System uptime monitoring

### 📝 Scan History
- Comprehensive scan event logging
- Advanced filtering by:
  - Date range
  - Reader ID
  - Scan type (entry, exit, inventory, maintenance)
- Pagination support
- Real-time updates

### ⚙️ Settings
- User profile management
- App preferences (notifications, auto-refresh)
- Refresh interval configuration
- System information display
- Secure logout functionality

## Tech Stack

- **Frontend**: Flutter 3.10+ with Material Design 3
- **Backend**: Supabase (PostgreSQL + Auth + Real-time)
- **State Management**: Provider pattern with services
- **Local Storage**: SharedPreferences
- **Charts**: Custom chart widgets
- **Typography**: Google Fonts (Poppins)

## Architecture

```
lib/
├── config/
│   ├── theme.dart           # App theming and colors
│   └── constants.dart       # App constants and configuration
├── models/
│   ├── user_model.dart      # User data model
│   ├── rfid_reader_model.dart # RFID reader model
│   ├── rfid_tag_model.dart  # RFID tag model
│   └── scan_history_model.dart # Scan event model
├── services/
│   ├── auth_service.dart    # Authentication service
│   ├── database_service.dart # Database operations
│   └── storage_service.dart # Local storage service
├── screens/
│   ├── splash_screen.dart   # App initialization
│   ├── login_screen.dart    # User authentication
│   ├── main_navigation.dart # Bottom navigation
│   ├── home_screen.dart     # Dashboard
│   ├── scan_history_screen.dart # Scan events
│   ├── analysis_screen.dart # Analytics & charts
│   └── settings_screen.dart # App settings
├── widgets/
│   ├── stat_card.dart       # Statistics display card
│   ├── loading_widget.dart  # Loading indicators
│   └── custom_card.dart     # Reusable card widget
├── utils/
│   ├── helpers.dart         # Utility functions
│   └── validators.dart      # Form validation
└── main.dart               # App entry point
```

## Color Scheme

The app uses a modern dark theme with carefully selected colors:

- **Primary**: Purple (#6C63FF) - Main accent color
- **Secondary**: Teal (#00D4AA) - Success states
- **Accent**: Coral Red (#FF6B6B) - Error/warning states
- **Background**: Dark (#121212) - Main background
- **Surface**: Dark Grey (#1E1E1E) - Cards and surfaces

## Database Schema

### Tables
- `users` - User profiles and authentication data
- `rfid_readers` - RFID reader device information
- `rfid_tags` - RFID tag asset tracking
- `scan_history` - All RFID scan events
- `settings` - Application and reader settings

## Setup Instructions

### Prerequisites
- Flutter SDK 3.10+
- Dart SDK 3.0+
- Android Studio / VS Code
- Supabase account

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd rfid-flutter-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   - Create a new Supabase project
   - Update the Supabase URL and anon key in `lib/main.dart`
   - Set up the database schema (see Database Setup section)

4. **Run the application**
   ```bash
   flutter run
   ```

### Database Setup

Create the following tables in your Supabase database:

```sql
-- Users table (extends Supabase auth.users)
CREATE TABLE users (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT NOT NULL,
  first_name TEXT,
  last_name TEXT,
  avatar_url TEXT,
  role TEXT DEFAULT 'user',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_login_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN DEFAULT TRUE
);

-- RFID Readers table
CREATE TABLE rfid_readers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  location TEXT NOT NULL,
  warehouse TEXT,
  status TEXT NOT NULL DEFAULT 'active',
  ip_address INET NOT NULL,
  port INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_seen_at TIMESTAMP WITH TIME ZONE,
  settings JSONB,
  description TEXT,
  is_online BOOLEAN DEFAULT FALSE
);

-- RFID Tags table
CREATE TABLE rfid_tags (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  tag_id TEXT UNIQUE NOT NULL,
  owner TEXT,
  description TEXT,
  status TEXT NOT NULL DEFAULT 'active',
  location TEXT,
  warehouse TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_seen_at TIMESTAMP WITH TIME ZONE,
  last_reader_id UUID REFERENCES rfid_readers(id),
  metadata JSONB,
  asset_type TEXT
);

-- Scan History table
CREATE TABLE scan_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  tag_id TEXT NOT NULL,
  reader_id UUID REFERENCES rfid_readers(id) NOT NULL,
  reader_name TEXT,
  location TEXT,
  warehouse TEXT,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  scan_type TEXT NOT NULL,
  signal_strength REAL,
  confidence REAL,
  additional_data JSONB,
  notes TEXT
);

-- Settings table
CREATE TABLE settings (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  key TEXT UNIQUE NOT NULL,
  value JSONB NOT NULL,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Row Level Security (RLS)

Enable RLS and create policies for secure data access:

```sql
-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE rfid_readers ENABLE ROW LEVEL SECURITY;
ALTER TABLE rfid_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE scan_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;

-- Create policies (example for users table)
CREATE POLICY "Users can view their own profile" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON users
  FOR UPDATE USING (auth.uid() = id);
```

## Demo Credentials

For testing purposes, you can use these demo credentials:
- **Email**: `admin@rfidmanager.com`
- **Password**: `password123`

## API Integration

The app integrates with Supabase through the following services:

### AuthService
- User authentication and session management
- Profile creation and updates
- Password reset functionality

### DatabaseService
- CRUD operations for all entities
- Real-time data synchronization
- Analytics data aggregation

### StorageService
- Local preference storage
- Cache management
- Offline data handling

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## Performance Optimization

- **Lazy loading**: Screens and widgets load on demand
- **Pagination**: Large datasets are paginated
- **Caching**: Frequently accessed data is cached locally
- **Debouncing**: Search and filter operations are debounced
- **Image optimization**: Images are compressed and cached

## Security Features

- **Secure authentication**: JWT tokens with automatic refresh
- **Data encryption**: Sensitive data is encrypted at rest
- **Input validation**: All user inputs are validated
- **SQL injection prevention**: Parameterized queries only
- **XSS protection**: Output sanitization

## Known Issues

- Charts library dependency may need updating for web builds
- Some animations may lag on older Android devices
- Real-time updates require stable internet connection

## Future Enhancements

- [ ] Offline mode support
- [ ] Push notifications
- [ ] Multi-language support
- [ ] Advanced reporting features
- [ ] QR code scanning
- [ ] Export functionality
- [ ] Role-based permissions

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation wiki

## Version History

- **v1.0.0** - Initial release with core features
  - Authentication system
  - Dashboard with real-time stats
  - Scan history management
  - Analytics and reporting
  - Settings and preferences 
