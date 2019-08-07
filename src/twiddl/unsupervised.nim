import os, osproc, ropes, times, options

import twiddl
import twiddl/runner

proc runBuildInternal(env: TwiddlEnv, build:var Build) =
  let
    logDir = env.logsPath / $build.id
    artifactsDir = env.artifactsPath / $build.id
  var
    internalLog = rope()
    error = false

  if build.status == bsFinishedSuccessful or
     build.status == bsFinishedCanceled or
     build.status == bsFinishedFailed:
    return

  internalLog.add("twiddl's unsupervised runner.\n")
  internalLog.add("Starting build\n")

  build.status = bsRunning
  build.timeStarted = some now()
  build.logs.add(Log(id:0, path:logDir / "runner.log"))
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
      internalLog.addf("Command $1 exited with non-zero exit code. Aborting", [i.rope])
      error = true
      break

  # Handle artifacts
  for i, artifact in build.job.artifacts:
    if existsFile(artifact):
      let path = artifactsDir / $i
      moveFile(artifact, path)
      build.artifacts.add(Artifact(id:i, originalPath:artifact, path:path))
    else:
      internalLog.addf("Artifact $1 doesn't exist. Skipping.\n", [artifact.rope])

  # Finish
  build.status = if error: bsFinishedFailed else: bsFinishedSuccessful
  build.timeFinished = some now()
  build.saveBuildfile()

  internalLog.add("Finished\n")

  # Save internal log
  writeFile(logDir / "runner.log", $internalLog)

let
  unsupervisedRunner* = Runner(runBuild: proc(env: TwiddlEnv, build:var Build) = runBuildInternal(env, build),
    cancelBuild: proc(env: TwiddlEnv, build:var Build) = discard,
    listRunningBuilds: proc (): seq[Build] = @[])
