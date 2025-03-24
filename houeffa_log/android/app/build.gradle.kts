// android/app/build.gradle.kts
plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.houeffa_log"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

//dependencies {
  //  implementation("io.flutter:flutter_embedding_debug:1.0.0")
  //  implementation(platform("com.google.firebase:firebase-bom:33.1.0"))
   // implementation("com.google.firebase:firebase-auth")
   // implementation("com.google.firebase:firebase-firestore")
   // implementation("com.google.android.gms:play-services-auth:21.2.0")
//}