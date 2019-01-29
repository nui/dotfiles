import Dependencies._

lazy val root = (project in file(".")).
  settings(
    inThisBuild(List(
      organization := "com.nuimk",
      scalaVersion := "2.12.8",
      version := "0.1.0-SNAPSHOT"
    )),
    name := "nmk",
    libraryDependencies ++= Seq(
      scalaGuice,
      jackson,
    )
  )
