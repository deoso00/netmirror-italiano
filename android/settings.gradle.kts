pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // MODIFICATO: Abbassato il plugin Android a 8.2.2 per la massima stabilità con Kotlin 1.9
    id("com.android.application") version "8.2.2" apply false
    // MODIFICATO: Lasciato a 1.9.24 per la stabilità dei plugin
    id("org.jetbrains.kotlin.android") version "1.9.24" apply false
}

include(":app")
