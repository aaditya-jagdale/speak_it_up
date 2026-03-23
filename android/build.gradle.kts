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

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    // Fix for text_to_speech 0.2.3: its build.gradle has no `namespace`
    // which AGP 8+ requires. Inject it here so we don't edit the pub cache.
    afterEvaluate {
        if (project.name == "text_to_speech") {
            extensions.findByName("android")?.let { ext ->
                val androidExt = ext as com.android.build.gradle.LibraryExtension
                
                // Force compileSdk to 34 to resolve modern resource issues (e.g., lStar)
                androidExt.compileSdk = 34
                
                if (androidExt.namespace == null) {
                    androidExt.namespace = "com.ixsans.text_to_speech"
                }

                // Force JVM target 17 for this plugin to align with the app module
                // (which is now using 17 due to system JDK restrictions).
                androidExt.compileOptions.sourceCompatibility = JavaVersion.VERSION_17
                androidExt.compileOptions.targetCompatibility = JavaVersion.VERSION_17
            }
            tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
                compilerOptions {
                    jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
                }
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}


tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
