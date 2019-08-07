import os, json, strutils, times, options, sequtils

const
  ## The time format used throughout twiddl
  timeFmt = initTimeFormat("yyyy-MM-dd HH:mm:ss")

type
  TwiddlEnv* = object
    ## Holds all important data about a twiddl
    ## environment
    path*:string
    buildsPath*:string
    artifactsPath*:string
    logsPath*:string
    twiddlfile*:Twiddlfile
    builds*:seq[Build]

  Twiddlfile* = object
    ## Holds all configuration data for a twiddl
    ## environment
    path*:string
    name*:string
    jobs*:seq[Job]

  Job* = object
    ## Holds all data representing a specific job,
    ## something that can be run
    name*:string
    runner*:string
    commands*:seq[string]
    artifacts*:seq[string]

  BuildStatus* = enum
    ## All possible states of a build
    bsUnknown,
    bsPlanned,
    bsPending,
    bsRunning,
    bsFinishedSuccessful,
    bsFinishedCanceled,
    bsFinishedFailed,

  Build* = object
    ## Holds all data tied to a build
    path*:string
    id*:int
    comment*:string
    job*:Job
    timeStarted*:Option[DateTime]
    timeFinished*:Option[DateTime]
    status*:BuildStatus
    logs*:seq[Log]
    artifacts*:seq[Artifact]

  Artifact* = object
    ## Holds all data tied to a build artifact
    ## which was generated
    id*:int
    path*:string

  Log* = object
    ## Holds all data tied to a build log
    id*:int
    path*:string

proc readTwiddlfile(path:string): Twiddlfile =
  ## Parse this twiddlfile
  result.path = path
  let jsonNode = parseFile(path)

  result.name = jsonNode["name"].getStr()
  for name, job in jsonNode["jobs"].pairs:
    var
      commands:seq[string]
      artifacts:seq[string]

    for command in job["commands"].items:
      commands.add(command.getStr())
    for artifact in job["artifacts"].items:
      artifacts.add(artifact.getStr())

    result.jobs.add(Job(name:name,
                        runner:job["runner"].getStr(),
                        commands:commands,
                        artifacts:artifacts))

proc saveTwiddlfile*(twf:Twiddlfile) = 
  ## Saves the Twiddlfile
  var jsonResult = %* {"name" : twf.name}

  for jobs in twf.jobs:
    jsonResult["jobs"]{jobs.name} = %* {"runner" : jobs.runner,
      "commands" : jobs.commands,
      "artifacts" : jobs.artifacts}

  writeFile(twf.path, $jsonResult)

proc readBuildFile(path:string): Build =
  ## Parse this build file
  let
    jsonNode = parseFile(path)
    job = jsonNode["job"]

  result.id = jsonNode["id"].getInt()
  result.comment = jsonNode["comment"].getStr()
  result.status = jsonNode["status"].getStr().parseEnum(bsUnknown)

  result.job.name = job["name"].getStr()
  result.job.runner = job["runner"].getStr()
  for command in job["commands"].items:
    result.job.commands.add(command.getStr())
  for artifact in job["artifacts"].items:
    result.job.artifacts.add(artifact.getStr())

  if jsonNode.hasKey("startTime"):
    result.timeStarted = some(jsonNode["startTime"].getStr().parse(timeFmt))
  if jsonNode.hasKey("finishTime"):
    result.timeFinished = some(jsonNode["finishTime"].getStr().parse(timeFmt))

  for id, log in jsonNode["logs"].pairs:
    result.logs.add(Log(id:id.parseInt, path:log.getStr()))
  for id, artifact in jsonNode["artifacts"].pairs:
    result.artifacts.add(Artifact(id:id.parseInt, path:artifact.getStr()))

proc saveBuildFile*(b:Build) =
  ## Saves the build configuration
  var jsonResult = %* {"id" : b.id,
    "comment" : b.comment,
    "status" : $b.status}

  jsonResult["job"] = %* {"name" : b.job.name,
    "runner" : b.job.runner,
    "commands" : b.job.commands,
    "artifacts" : b.job.artifacts}

  if b.timeStarted.isSome:
    jsonResult["startTime"] = % b.timeStarted.get.format(timeFmt)
  if b.timeFinished.isSome:
    jsonResult["finishTime"] = % b.timeFinished.get.format(timeFmt)

  for log in b.logs:
    jsonResult["logs"][$log.id] = % log.path
  for artifact in b.artifacts:
    jsonResult["artifacts"][$artifact.id] = % artifact.path

  writeFile(b.path, $jsonResult)

proc openBuilds(path:string): seq[Build] =
  ## Parse all build files in this path
  for kind, file in walkDir(path):
    result.add(readBuildFile(file))

proc openTwiddlEnv*(path:string): TwiddlEnv =
  ## Opens a twiddl environment
  result.path = path
  result.buildsPath = path / ".twiddl" / "builds"
  result.artifactsPath = path / ".twiddl" / "artifacts"
  result.logsPath = path / ".twiddl" / "logs"
  result.twiddlfile = readTwiddlfile(path / "twiddlfile")
  result.builds = openBuilds(result.buildsPath)
