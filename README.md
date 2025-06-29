# pockettasksapp


How to Run

Installation Steps

Clone the project

Install dependencies
run flutter pub get

Run the app
flutter run

Why Riverpod?
I chose Flutter Riverpod as the state management solution:

🔒 Compile-time Safety: Riverpod catches provider errors at compile time, preventing runtime crashes
🧪 Testability: Providers can be easily overridden for testing without complex mocking
📦 No Context Dependency: Providers can be read anywhere without requiring BuildContext
🔄 Automatic Disposal: Providers are automatically disposed when no longer needed


Architecture Summary
UI Layer → Consumer widgets watch providers
State Layer → Riverpod providers manage state
Business Layer → StateNotifiers handle business logic
Data Layer → DatabaseService manages SQLite operations
