# Flutter rules are compiled into the base Flutter Gradle plugin. We add them here for consistency.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.engine.plugins.**  { *; }

# Firebase SDK rules
-keep class com.google.firebase.** { *; }
-keep interface com.google.firebase.** { *; }

# Keep setters and getters for your data classes
-keep class com.example.smart_waste_management.models.** { *; }