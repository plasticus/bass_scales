allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Force the build directory to the project root so Flutter can find the APK
rootProject.layout.buildDirectory.set(layout.projectDirectory.dir("../build"))

subprojects {
    afterEvaluate {
        if (project.extensions.findByName("android") != null) {
            configure<com.android.build.gradle.BaseExtension> {
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
            }
        }
    }
}

subprojects {
    project.layout.buildDirectory.value(rootProject.layout.buildDirectory.map { it.dir(project.name) })
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {

subprojects {
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
}
}

subprojects {
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile>().configureEach {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }
}
