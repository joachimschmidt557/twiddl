import os, json, strutils, times, options

type
  TwiddlEnv* = object
    path*:string
    twiddlfile*:Twiddlfile
    builds*:seq[Build]
  Twiddlfile* = object
    path*:string

  BuildStatus* = enum
    bsUnknown,
    bsPlanned,
    bsPending,
    bsRunning,
    bsFinishedSuccessful,
    bsFinishedCanceled,
    bsFinishedFailed

  Build* = object
    id*:int
    comment*:string
    timeStarted*:Option[DateTime]
    timeFinished*:Option[DateTime]
    status*:BuildStatus
    logs*:seq[Log]
    artifacts*:seq[Artifact]

  Artifact* = object
    path*:string
  Log* = object
    path*:string
    content*:string

proc readTwiddlfile*(path:string): Twiddlfile =
  result.path = path
  discard

proc readBuildFile(path:string): Build =
  let jsonNode = parseJson(readFile(path))
  result.id = jsonNode["id"].getInt()
  result.comment = jsonNode["comment"].getStr()
  result.status = jsonNode["status"].getStr().parseEnum(bsUnknown)

proc saveBuildFile(b:Build, path:string) =
  discard

proc openBuilds(path:string): seq[Build] =
  for file in walkDir(path):
    result.add(readBuildFile(path))

proc openTwiddlEnv*(path:string): TwiddlEnv =
  result.path = path
  result.twiddlfile = readTwiddlfile(path / "twiddlfile")
  result.builds = openBuilds(path / ".twiddl" / "builds")
  discard
