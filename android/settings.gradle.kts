pluginManagement {
    includeBuild("../programs/flutter/packages/flutter_tools/gradle")
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.2.1" apply false
    id("org.jetbrains.kotlin.android") version "1.9.22" apply false
}

// THE FIX: The typo has been removed from this line.
include(":app")
