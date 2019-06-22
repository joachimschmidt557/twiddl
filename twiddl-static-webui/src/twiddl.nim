import os, json, strutils, times, options, sequtils

const
  timeFmt = initTimeFormat("yyyy-MM-dd HH:mm:ss")

type
  TwiddlEnv* = object
    ## Holds all important data about a twiddl
    ## environment
    path*:string
    twiddlfile*:Twiddlfile
    builds*:seq[Build]
  Twiddlfile* = object
    ## Holds all configuration data for a twiddl
    ## environment
    path*:string
    name*:string
    jobs*:seq[Job]

  Job* = object
    commands*:seq[string]
    artifacts*:seq[string]

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
    job*:Job
    timeStarted*:Option[DateTime]
    timeFinished*:Option[DateTime]
    status*:BuildStatus
    logs*:seq[Log]
    artifacts*:seq[Artifact]

  Artifact* = object
    path*:string

  Log* = object
    path*:string

proc readTwiddlfile(path:string): Twiddlfile =
  result.path = path
  let jsonNode = parseJson(readFile(path))

  result.name = jsonNode["name"].getStr()
  for job in jsonNode["jobs"].items:
    var
      commands:seq[string]
      artifacts:seq[string]
    for command in job["commands"].items:
      commands.add(command.getStr())
    for artifact in job["artifacts"].items:
      artifacts.add(artifact.getStr())
    result.jobs.add(Job(commands:commands, artifacts:artifacts))

proc readBuildFile(path:string): Build =
  let
    jsonNode = parseJson(readFile(path))
    job = jsonNode["job"]

  result.id = jsonNode["id"].getInt()
  result.comment = jsonNode["comment"].getStr()
  result.status = jsonNode["status"].getStr().parseEnum(bsUnknown)

  for command in job["commands"].items:
    result.job.commands.add(command.getStr())
  for artifact in job["artifacts"].items:
    result.job.artifacts.add(artifact.getStr())

  if jsonNode.hasKey("startTime"):
    result.timeStarted = some(jsonNode["startTime"].getStr().parse(timeFmt))
  if jsonNode.hasKey("finishTime"):
    result.timeFinished = some(jsonNode["finishTime"].getStr().parse(timeFmt))
  for log in jsonNode["logs"].items:
    result.logs.add(Log(path:log.getStr()))
  for artifact in jsonNode["artifacts"].items:
    result.artifacts.add(Artifact(path:artifact.getStr()))

proc saveBuildFile(b:Build, path:string) =
  var result = %* {"id" : b.id,
    "comment" : b.comment,
    "status" : $b.status}

  result["job"] = %* {"commands" : b.job.commands,
    "artifacts" : b.job.artifacts}

  if b.timeStarted.isSome:
    result["startTime"] = % b.timeStarted.get.format(timeFmt)
  if b.timeFinished.isSome:
    result["finishTime"] = % b.timeFinished.get.format(timeFmt)

  result["logs"] = % b.logs.mapIt(it.path)
  result["artifacts"] = % b.artifacts.mapIt(it.path)
  writeFile(path, $result)

proc openBuilds(path:string): seq[Build] =
  for kind, file in walkDir(path):
    result.add(readBuildFile(file))

proc openTwiddlEnv*(path:string): TwiddlEnv =
  ## Opens a twiddle environment
  result.path = path
  result.twiddlfile = readTwiddlfile(path / "twiddlfile")
  result.builds = openBuilds(path / ".twiddl" / "builds")
