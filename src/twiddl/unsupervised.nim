import os, osproc, ropes, times, options

import twiddl
import twiddl/runner

proc runBuildInternal(env: TwiddlEnv, build:var Build) =
  let
    logDir = env.logsPath / $build.id
    artifactsDir = env.artifactsPath / $build.id
  var
    internalLog = rope()

  if build.status == bsFinishedSuccessful or
     build.status == bsFinishedCanceled or
     build.status == bsFinishedFailed:
    return

  build.status = bsRunning
  build.timeStarted = some now()
  build.saveBuildfile()

  # Create dirs if necessary
  createDir(logDir)
  createDir(artifactsDir)

  # Run commands
  for i, command in build.job.commands:
    let
      (output, exitCode) = execCmdEx(command)
      logPath = logDir / ($(i + 1)).addFileExt("log")

    writeFile(logPath , output)
    build.logs.add(Log(id:i + 1, path:logPath))

    if exitCode != 0:
      build.status = bsFinishedFailed
      build.saveBuildFile()
      return

  # Handle artifacts
  for i, artifact in build.job.artifacts:
    if existsFile(artifact):
      let path = artifactsDir / $i
      moveFile(artifact, path)
      build.artifacts.add(Artifact(id:i, path:path))

  # Finish
  build.status = bsFinishedSuccessful
  build.timeFinished = some now()
  build.saveBuildfile()

  # Save internal log
  writeFile(logDir / "runner.log", $internalLog)
  build.logs.add(Log(id:0, path:logDir / "runner.log"))
  build.saveBuildFile()

let
  unsupervisedRunner* = Runner(runBuild: proc(env: TwiddlEnv, build:var Build) = runBuildInternal(env, build),
    cancelBuild: proc(env: TwiddlEnv, build:var Build) = discard,
    listRunningBuilds: proc (): seq[Build] = @[])
