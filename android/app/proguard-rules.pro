# =================================================================
# ProGuard / R8 Hardening Rules for iSecure CCE Pro
# Anti-Decompilation, Obfuscation & Security Policy
# =================================================================

# 1. Bytecode Obfuscation & Repackaging
-repackageclasses 'cce.sec'
-allowaccessmodification

# 2. Strip Debug Information and Source File metadata to impede decompilation
-renamesourcefileattribute 'Source'
-keepattributes Exceptions,InnerClasses,Signature,Deprecated,EnclosingMethod

# 3. Strip Logging Calls in Release (Prevent Information Leakage in Logcat)
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int d(...);
    public static int i(...);
    public static int w(...);
}

-assumenosideeffects class java.io.PrintStream {
    public void println(...);
    public void print(...);
}

# 4. Flutter Engine and Plugin Preservation
-keep class io.flutter.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# 5. Native JNI Method Preservation
-keepclasseswithmembernames class * {
    native <methods>;
}

# 6. Preserve Android Application & Activity Entrypoints
-keep public class com.myschool.cce.myschool.MainActivity { *; }
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application

# 7. Suppress warnings from third-party plugins
-dontwarn **
-ignorewarnings
