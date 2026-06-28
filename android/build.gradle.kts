plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android") version "1.9.24"
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    compileSdk = 34

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.netmirror.app"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

// BLOCCO SPECIALE: Costringe TUTTI i plugin esterni a usare Kotlin 1.9.24 ed evita il crash di Gradle
subprojects {
    afterEvaluate {
        if (plugins.hasPlugin("org.jetbrains.kotlin.android")) {
            dependencies {
                implementation(platform("org.jetbrains.kotlin:kotlin-bom:1.9.24"))
            }
        }
    }
}
