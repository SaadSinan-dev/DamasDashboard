# R8 rules for release builds.
#
# The Flutter Gradle plugin already contributes rules for the engine and for
# plugin registration, so this file only needs to cover what is specific to this
# app. It is intentionally short: every `-keep` that is not needed is dead weight
# that stops the shrinker doing its job.

# Flutter's embedding is reached reflectively from the generated registrant.
-keep class io.flutter.embedding.** { *; }

# Keep the annotations R8 itself reads, and line numbers so that a stack trace
# from a release crash can still be mapped back to source.
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
