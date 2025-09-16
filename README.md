# Social Media Feed App

A modern Flutter application that displays a social media feed with posts, comments, and interactive features. Built using Clean Architecture principles and BLoC pattern for state management.

## 🚀 Features

### Core Features
- **Social Media Feed**: Display posts with text, images, and videos
- **Like System**: Optimistic UI updates for instant feedback
- **Comments**: View and add comments to posts
- **User Profiles**: Navigate to user profile pages
- **Pull-to-Refresh**: Refresh feed content
- **Infinite Scroll**: Load more posts automatically
- **Dark/Light Theme**: Toggle between themes
- **Connectivity Banner**: Real-time network status indicator
- **Media Support**: Image and video content with caching

### Technical Features
- **Offline Support**: Local caching with SQLite
- **Optimized Performance**: Video player optimization and image caching
- **Responsive Design**: Adaptive UI for different screen sizes
- **Error Handling**: Comprehensive error states and retry mechanisms
- **Network Monitoring**: Automatic connectivity detection

## 🏗️ Architecture

The project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                          # Shared utilities and services
│   ├── api_const/                 # API constants and base classes
│   ├── consts/                    # App constants (colors, themes, strings)
│   ├── error/                     # Error handling (exceptions, failures)
│   ├── extensions/                # Dart extensions
│   ├── interceptor/               # HTTP interceptors
│   ├── network/                   # Network utilities
│   ├── routes/                    # App routing
│   ├── services/                  # Core services (cache, connectivity, theme)
│   └── utilities/                 # Helper utilities
├── features/
│   └── feed/                      # Feed feature module
│       ├── data/                  # Data layer
│       │   ├── datasources/       # Remote & local data sources
│       │   ├── models/            # Data models
│       │   └── repositories/      # Repository implementations
│       ├── domain/                # Domain layer
│       │   ├── entities/          # Business entities
│       │   ├── repositories/      # Repository contracts
│       │   └── usecases/          # Business logic
│       └── presentation/          # Presentation layer
│           ├── bloc/              # BLoC state management
│           ├── pages/             # UI pages
│           └── widgets/           # Reusable widgets
├── injection_container.dart       # Dependency injection setup
└── main.dart                     # App entry point
```

### Layer Responsibilities

#### 1. **Data Layer**
- **Remote Data Source**: API calls to JSONPlaceholder
- **Local Data Source**: SQLite database operations
- **Models**: JSON serialization/deserialization
- **Repository Implementation**: Data source coordination

#### 2. **Domain Layer**
- **Entities**: Core business objects (Post, User, Comment)
- **Use Cases**: Business logic (GetPosts, LikePost, AddComment)
- **Repository Contracts**: Data access interfaces

#### 3. **Presentation Layer**
- **BLoC**: State management and business logic
- **Pages**: Screen-level widgets
- **Widgets**: Reusable UI components

## 🔧 Dependencies

### Core Dependencies
```yaml
# State Management
flutter_bloc: ^9.1.0
equatable: ^2.0.7

# Network & HTTP
dio: ^5.8.0+1
http: ^1.2.2
connectivity_plus: ^6.1.3

# Functional Programming
dartz: ^0.10.1

# Local Storage
sqflite: ^2.4.1
shared_preferences: ^2.5.2
flutter_secure_storage: ^9.2.4

# Dependency Injection
get_it: ^8.0.3

# Media & UI
cached_network_image: ^3.4.1
video_player: ^2.9.2
shimmer: ^3.0.0
google_fonts: ^6.2.1

# JSON & Code Generation
json_annotation: ^4.9.0
json_serializable: ^6.8.0
build_runner: ^2.4.13
```

## 🌐 API Endpoints

The app uses **JSONPlaceholder** as a mock REST API:

### Base URL
```
https://jsonplaceholder.typicode.com
```

### Endpoints

| Method | Endpoint | Description | Parameters |
|--------|----------|-------------|------------|
| GET | `/posts` | Get paginated posts | `_page`, `_limit` |
| GET | `/posts/{id}/comments` | Get comments for a post | `{id}` - Post ID |
| POST | `/posts/{id}/like` | Like a post | `{id}` - Post ID |
| DELETE | `/posts/{id}/like` | Unlike a post | `{id}` - Post ID |
| POST | `/posts/{id}/comments` | Add comment | `{id}` - Post ID, body |

### Example Requests

#### Get Posts
```http
GET /posts?_page=1&_limit=10
```

#### Get Comments
```http
GET /posts/1/comments
```

#### Like Post
```http
POST /posts/1/like
```

## 🔄 State Management

The app uses **BLoC (Business Logic Component)** pattern for state management:

### Feed BLoC States
- `FeedInitial`: Initial state
- `FeedLoading`: Loading posts
- `FeedLoaded`: Posts loaded successfully
- `FeedError`: Error occurred
- `PostLikeUpdating`: Like operation in progress
- `PostLikeUpdated`: Like operation completed
- `CommentAdding`: Adding comment
- `CommentAdded`: Comment added
- `CommentsLoading`: Loading comments
- `CommentsLoaded`: Comments loaded

### Feed BLoC Events
- `LoadFeedEvent`: Load initial posts
- `LoadMorePostsEvent`: Load more posts (pagination)
- `LikePostEvent`: Like a post
- `UnlikePostEvent`: Unlike a post
- `AddCommentEvent`: Add a comment
- `LoadCommentsEvent`: Load post comments

## 🎨 UI Components

### Custom Widgets

#### PostCard
- Displays post content with user info
- Gradient background with shadows
- Media content (images/videos)
- Action buttons (like, bookmark)

#### OptimizedLikeButton
- Animated like button with count
- Optimistic UI updates
- Scale animation on tap
- Real-time count updates

#### ConnectivityBanner
- Network status indicator
- Animated slide-in/out
- Different states for online/offline
- Auto-hide on reconnection

#### CachedVideoPlayerWidget
- Optimized video playback
- Automatic play/pause based on visibility
- Loading states and error handling
- Memory management

### Theme System
- **Dark/Light Mode**: System and manual toggle
- **Color Palette**: Consistent color scheme
- **Typography**: Google Fonts integration
- **Gradients**: Modern gradient effects

## 📱 Performance Optimizations

### Video Player
- Lazy loading and disposal
- Visibility-based playback control
- Memory leak prevention
- Background/foreground handling

### Image Caching
- `cached_network_image` for efficient caching
- Placeholder and error widgets
- Progressive loading

### List Performance
- `ValueNotifier` for local state
- Optimistic UI updates
- Minimal rebuilds
- Stable widget keys

### Network Optimizations
- Retry interceptors
- Connection monitoring
- Offline caching
- Request deduplication

## 🚦 How It Works

### App Flow

1. **App Launch**
   ```
   main.dart → setupLocator() → FeedPage
   ```

2. **Feed Loading**
   ```
   FeedPage → BlocProvider → FeedBloc → LoadFeedEvent
   → GetPosts UseCase → FeedRepository → RemoteDataSource
   → API Call → Response → FeedLoaded State → UI Update
   ```

3. **Like Interaction**
   ```
   User Tap → OptimizedLikeButton → ValueNotifier Update
   → Instant UI Change → (Optional) API Call
   ```

4. **Offline Handling**
   ```
   No Internet → ConnectivityService → ConnectivityBanner
   → LocalDataSource → Cached Data → UI Display
   ```

### Data Flow

1. **Remote First**: Try to fetch from API
2. **Cache Fallback**: Use local data if network fails
3. **Optimistic Updates**: Update UI immediately for better UX
4. **Background Sync**: Sync changes when network is available

## 🛠️ Setup & Installation

### Prerequisites
- Flutter SDK (^3.9.0)
- Dart SDK
- Android Studio / VS Code
- Device or Emulator

### Installation Steps

1. **Clone Repository**
   ```bash
   git clone <repository-url>
   cd feeds_task
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run App**
   ```bash
   flutter run
   ```

### Build for Production

#### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

#### iOS
```bash
flutter build ipa --release
```

## 🧪 Testing

### Running Tests
```bash
# Unit Tests
flutter test

# Integration Tests
flutter test integration_test/

# Coverage Report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Test Structure
```
test/
├── unit/                   # Unit tests
│   ├── data/              # Data layer tests
│   ├── domain/            # Domain layer tests
│   └── presentation/      # Presentation layer tests
├── widget/                # Widget tests
└── integration/           # Integration tests
```

## 🔧 Configuration

### Environment Variables
Create `.env` file for configuration:
```env
API_BASE_URL=https://jsonplaceholder.typicode.com
API_TIMEOUT=30000
CACHE_DURATION=3600
```

### Build Flavors
```bash
# Development
flutter run --flavor dev --dart-define=ENVIRONMENT=dev

# Production
flutter run --flavor prod --dart-define=ENVIRONMENT=prod
```

## 📊 Performance Metrics

### Key Performance Indicators
- **App Launch Time**: < 2 seconds
- **Feed Load Time**: < 1 second (cached), < 3 seconds (network)
- **Like Response Time**: < 100ms (optimistic)
- **Memory Usage**: < 150MB typical usage
- **APK Size**: < 50MB

### Monitoring
- Frame rate monitoring
- Memory leak detection
- Network request tracking
- Error reporting

## 🐛 Troubleshooting

### Common Issues

#### Build Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
```

#### Network Issues
- Check internet connectivity
- Verify API endpoints
- Clear app cache

#### Performance Issues
- Enable performance overlay: `flutter run --profile`
- Check for memory leaks
- Optimize images and videos

## 🚀 Future Enhancements

### Planned Features
- [ ] Real-time notifications
- [ ] User authentication
- [ ] Story feature
- [ ] Direct messaging
- [ ] Content search
- [ ] Hashtag support
- [ ] Photo/video upload
- [ ] User following system

### Technical Improvements
- [ ] GraphQL integration
- [ ] Advanced caching strategies
- [ ] Background sync
- [ ] Push notifications
- [ ] Analytics integration
- [ ] Crashlytics
- [ ] Performance monitoring

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation

---

**Built with ❤️ using Flutter**
