import os, osproc, ropes, times, options

import twiddl
import twiddl/runner

type
  Container = object
    image:string
    name:string

proc launchLxcContainer(c:Container) =
  discard execCmd("lxc launch " & c.image & " " & c.name)

proc startLxcContainer(c:Container) =
  discard execCmd("lxc start " & c.name)

proc stopLxcContainer(c:Container) =
  discard execCmd("lxc stop " & c.name)

proc execLxcContainer(c:Container, cmd:string) =
  discard execCmd("lxc exec " & c.name & " -- " & cmd)

proc pushLxcContainer(c:Container, item:string, dest:string) =
  discard execCmd("lxc file push " & item & " " & c.name & dest & " -r -p")

proc containerForBuild(env:TwiddlEnv, build:Build): Container =
  Container(image: "ubuntu:18.04", name:"tw-" & env.twiddlfile.name & "-" & $build.id)

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

  internalLog.add("twiddl's LXC runner.\n")
  internalLog.add("Starting build\n")

  build.status = bsRunning
  build.timeStarted = some now()
  build.logs.add(Log(id:0, path:logDir / "runner.log"))
  build.saveBuildfile()

  # Create dirs if necessary
  createDir(logDir)
  createDir(artifactsDir)

  # Create container
  let
    c = containerForBuild(env, build)

  c.launchLxcContainer()
  c.pushLxcContainer(env.path, "/tmp/twiddl/")

  # Run commands
  for i, command in build.job.commands:
    c.execLxcContainer(command)
#    let
#      (output, exitCode) = execCmdEx(command)
#      logPath = logDir / ($(i + 1)).addFileExt("log")
#
#    writeFile(logPath, output)
#    build.logs.add(Log(id:i + 1, path:logPath))
#
#    if exitCode != 0:
#      internalLog.addf("Command $1 exited with non-zero exit code. Aborting\n", [i.rope])
#      error = true
#      break

  # Handle artifacts
  #for i, artifact in build.job.artifacts:
  #  if existsFile(artifact):
  #    let path = artifactsDir / $i
  #    moveFile(artifact, path)
  #    build.artifacts.add(Artifact(id:i, originalPath:artifact, path:path))
  #  else:
  #    internalLog.addf("Artifact $1 doesn't exist. Skipping.\n", [artifact.rope])

  # Delete container
  c.stopLxcContainer()

  # Finish
  build.status = if error: bsFinishedFailed else: bsFinishedSuccessful
  build.timeFinished = some now()
  build.saveBuildfile()

  internalLog.add("Finished\n")

  # Save internal log
  writeFile(logDir / "runner.log", $internalLog)

let
  lxcRunner* = Runner(runBuild: proc(env: TwiddlEnv, build:var Build) = runBuildInternal(env, build),
    cancelBuild: proc(env: TwiddlEnv, build:var Build) = discard,
    listRunningBuilds: proc (): seq[Build] = @[])
