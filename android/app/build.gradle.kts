// 1. 파일의 맨 윗부분에 import 구문을 추가합니다.
import java.util.Properties
import java.io.FileInputStream

// ... (plugins {...} 블록 등이 이어서 나옵니다) ...

// 2. .env 파일을 읽는 코드를 Groovy가 아닌 Kotlin 문법으로 수정합니다.
//    (android { ... } 블록이 시작되기 *전*에 넣어주세요.)
val properties = Properties()
val envFile = File(project.rootDir.parentFile, ".env")
if (envFile.exists()) {
    properties.load(FileInputStream(envFile))
    println("✅ Loaded .env file from: ${envFile.absolutePath}") // 로그 확인용
} else {
    println("❌ Could not find .env file at: ${envFile.absolutePath}") // 로그 확인용
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.all_new_uniplan"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.all_new_uniplan"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24 // flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        val apiKey = properties.getProperty("GOOGLE_MAPS_API_KEY")
        
        if (apiKey == null) {
            println("⚠️ GOOGLE_MAPS_API_KEY not found in .env, using default.")
        }

        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = apiKey ?: "YOUR_DEFAULT_KEY"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
