## Flutter wrapper
-keep class **.zego.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.plugin.editing.** { *; }
-keep class com.iqonic.kivicare.MyFirebaseMessagingService { *; }
-dontwarn io.flutter.embedding.**
-ignorewarnings
-keep class * {
    public private *;
}