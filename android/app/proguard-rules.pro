# ProGuard configuration for ALONU App
# This file configures code minification and obfuscation for release builds

# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.**

# Keep Riverpod classes
-keep class riverpod.** { *; }
-keep class flutter_riverpod.** { *; }
-dontwarn riverpod.**

# Keep generated code
-keep class **.*.g { *; }
-keep class **.*.g.dart { *; }

# Keep model classes
-keep class com.alonu.alonu_app.data.models.** { *; }
-keep class com.alonu.alonu_app.domain.entities.** { *; }

# Keep Firebase classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Keep Dio classes
-keep class io.flutter.embedding.engine.plugins.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Hive classes
-keep class com.hive.** { *; }

# Generic rules for keeping classes
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-keep public class * {
    public protected *;
}

# Optimization
-optimizationpasses 5
-dontusemixedcaseclassnames
-verbose

# Remove logging calls
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
