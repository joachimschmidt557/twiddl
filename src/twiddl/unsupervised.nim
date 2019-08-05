import os, osproc

import twiddl
import twiddl/runners

proc runBuildInternal(build:var Build) =
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


  # Finish
  build.status = bsFinishedSuccessful
  build.saveBuildfile()

let
  unsupervisedRunner* = Runner(runBuild: proc(build:var Build) = runBuildInternal(build),
    cancelBuild: proc(build:var Build) = discard,
    listRunningBuilds: proc (): seq[Build] = @[])
