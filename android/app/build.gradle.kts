import java.util.Properties
import java.io.FileInputStream

// Load the keystore properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "monster.oaf.bass_scale_visualizer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
            sourceCompatibility = JavaVersion.VERSION_17
            targetCompatibility = JavaVersion.VERSION_17
        }

    kotlinOptions {
        jvmTarget = "17"
    }

    // Define the signing configuration using our key.properties
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it as String) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    defaultConfig {
        applicationId = "monster.oaf.bass_scale_visualizer"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Tell the release build to use our 'release' config instead of 'debug'
            signingConfig = signingConfigs.getByName("release")

            // Updated names for Kotlin DSL
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "/home/corey/development/bass_scales"
}