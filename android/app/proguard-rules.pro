# Remove log statements from the app
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
}
# Keep TensorFlow Lite GPU delegate classes
-keep class org.tensorflow.lite.gpu.** { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }

-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options
