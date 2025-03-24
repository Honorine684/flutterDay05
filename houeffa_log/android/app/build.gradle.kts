plugins {
    id "com.android.application"
    id "com.google.gms.google-services"  // Firebase
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

android {
    namespace "com.example.houeffa_log"  // Doit correspondre à google-services.json
    compileSdk flutter.compileSdkVersion
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_11
        targetCompatibility JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId "com.example.houeffa_log"  // Vérifie dans google-services.json
        minSdk flutter.minSdkVersion
        targetSdk flutter.targetSdkVersion
        versionCode flutter.versionCode
        versionName flutter.versionName
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug  // Pour tests, à ajuster pour release
        }
    }
}

flutter {
    source "../.."
}

dependencies {
    // Gestion cohérente des versions Firebase avec BoM
    implementation platform('com.google.firebase:firebase-bom:33.1.0')  // Dernière version
    implementation 'com.google.firebase:firebase-auth'  // Authentification Firebase
    implementation 'com.google.android.gms:play-services-auth:21.1.0'  // Google Sign-In natif
}