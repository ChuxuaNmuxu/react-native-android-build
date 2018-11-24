#!/bin/bash

chmod +x /cjhms_app_android_build/android/gradlew

/cjhms_app_android_build/android/gradlew clean aR -b /cjhms_app_android_build/android/app/build.gradle
