import twiddl

type Runner* = object
  createBuild*: proc (job:Job): Build

proc runBuild(build:var Build) =
  if build.status == bsFinishedSuccessful or
     build.status == bsFinishedCanceled or
     build.status == bsFinishedFailed:
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
