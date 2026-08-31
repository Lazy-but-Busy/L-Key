allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

// `flutter_pcm_sound` 3.3.3 declares `compileSdk 33` in its own module, which is
// older than the AndroidX versions the Flutter embedding resolves — androidx
// .fragment 1.7 requires 34 — so its AAR metadata check fails the build before a
// line of our code is compiled. Raising it here rather than vendoring the plugin
// keeps the fix to one place and to one sentence.
//
// This is the plugin's problem, not ours, and it is recorded in docs/adr/0016 as
// a maintenance cost of the dependency alongside its lack of Swift Package
// Manager support. Remove this block when the plugin catches up.
subprojects {
    afterEvaluate {
        val android = extensions.findByName("android")
        if (android is com.android.build.gradle.BaseExtension &&
            android.compileSdkVersion?.removePrefix("android-")?.toIntOrNull()
                ?.let { it < 34 } == true
        ) {
            android.compileSdkVersion(34)
        }
    }
}

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
