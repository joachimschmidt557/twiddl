import os, osproc, ropes

import twiddl
import twiddl/runner

proc runBuildInternal(env: TwiddlEnv, build:var Build) =
  var
    internalLog = rope()

  if build.status == bsFinishedSuccessful or
     build.status == bsFinishedCanceled or
     build.status == bsFinishedFailed:
    return

  build.status = bsRunning
  build.saveBuildfile()

  # Run commands
  for command in build.job.commands:
    let (output, exitCode) = execCmdEx(command)
    if exitCode != 0:
      build.status = bsFinishedFailed
      build.saveBuildFile()
      return

  # Handle artifacts
  for artifact in build.job.artifacts:
    discard

  # Finish
  build.status = bsFinishedSuccessful
  build.saveBuildfile()

  # Save internal log
  writeFile(env.logsPath / "runner.log", $internalLog)

let
  unsupervisedRunner* = Runner(runBuild: proc(env: TwiddlEnv, build:var Build) = runBuildInternal(env, build),
    cancelBuild: proc(env: TwiddlEnv, build:var Build) = discard,
    listRunningBuilds: proc (): seq[Build] = @[])
