# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Video player
-keep class com.google.android.exoplayer2.** { *; }
-keep class androidx.media3.** { *; }

# SQLite
-keep class net.sqlcipher.** { *; }
-keep class net.sqlcipher.database.* { *; }

# HTTP Client
-keepattributes Signature
-keepattributes *Annotation*
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**

# JSON serialization
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.SerializationKt
-keep,includedescriptorclasses class **$$serializer { *; }
-keepclassmembers class ** {
    *** Companion;
}
-keepclasseswithmembers class ** {
    kotlinx.serialization.KSerializer serializer(...);
}

# Connectivity
-keep class android.net.ConnectivityManager { *; }
-keep class android.net.NetworkInfo { *; }

# Keep data model classes
-keep class ** implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# General Flutter rules
-keep class androidx.lifecycle.DefaultLifecycleObserver