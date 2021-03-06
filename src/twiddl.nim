import os, json, strutils, times, options, sequtils, tables, algorithm

const
  ## The time format used throughout twiddl
  timeFmt = initTimeFormat("yyyy-MM-dd HH:mm:ss")

type
  TwiddlEnv* = object
    ## Holds all important data about a twiddl
    ## environment
    path*:string
    twiddlfile*:Twiddlfile
    buildsPath*:string
    artifactsPath*:string
    logsPath*:string
    builds*:seq[Build]

  Twiddlfile* = object
    ## Holds all configuration data for a twiddl
    ## environment
    path*:string
    name*:string
    jobs*:Table[string, Job]

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
    originalPath*:string
    path*:string

  Log* = object
    ## Holds all data tied to a build log
    id*:int
    path*:string

proc statusHumanReadable*(status:BuildStatus): string =
  ## Return a human-friendly description
  ## of this status
  case status
  of bsUnknown: "Unknown"
  of bsPlanned: "Planned"
  of bsPending: "Pending"
  of bsRunning: "Running"
  of bsFinishedSuccessful: "Successful"
  of bsFinishedFailed: "Failed"
  of bsFinishedCanceled: "Canceled"

proc readTwiddlfile(path:string): Twiddlfile =
  ## Parse this twiddlfile
  result.path = path
  let jsonNode = parseFile(path)

  result.name = jsonNode["name"].getStr()
  for name, job in jsonNode["jobs"].pairs:
    result.jobs[name] = Job(name:name,
                            runner:job["runner"].getStr(),
                            commands:toSeq(job["commands"].items).mapIt(it.getStr()),
                            artifacts:toSeq(job["artifacts"].items).mapIt(it.getStr()))

proc saveTwiddlfile*(twf:Twiddlfile) = 
  ## Saves the Twiddlfile
  var jsonResult = %* {"name" : twf.name}

  jsonResult["jobs"] = newJObject()
  for job in twf.jobs.values:
    jsonResult["jobs"]{job.name} = %* {"runner" : job.runner,
      "commands" : job.commands,
      "artifacts" : job.artifacts}

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
  result.job.commands = toSeq(job["commands"].items).mapIt(it.getStr())
  result.job.artifacts = toSeq(job["artifacts"].items).mapIt(it.getStr())

  if jsonNode.hasKey("startTime"):
    result.timeStarted = some(jsonNode["startTime"].getStr().parse(timeFmt))
  if jsonNode.hasKey("finishTime"):
    result.timeFinished = some(jsonNode["finishTime"].getStr().parse(timeFmt))

  for id, log in jsonNode["logs"].pairs:
    result.logs.add(Log(id:id.parseInt, path:log.getStr()))
  for id, artifact in jsonNode["artifacts"].pairs:
    result.artifacts.add(Artifact(id:id.parseInt,
                                  originalPath:artifact["original"].getStr(),
                                  path:artifact["path"].getStr()))

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

  jsonResult["logs"] = newJObject()
  for log in b.logs:
    jsonResult["logs"][$log.id] = % log.path

  jsonResult["artifacts"] = newJObject()
  for artifact in b.artifacts:
    jsonResult["artifacts"][$artifact.id] = %* {"original" : artifact.originalPath,
      "path" : artifact.path}

  writeFile(b.path, $jsonResult)

proc openBuilds(path:string): seq[Build] =
  ## Parse all build files in this path
  let cmpFilenameAsInt = proc (x,y: string): int = cmp(x.splitFile[1].parseInt, y.splitFile[1].parseInt)
  toSeq(walkDir(path)).mapIt(it[1]).sorted(cmpFilenameAsInt).mapIt(readBuildFile(it))

proc openTwiddlEnv*(path:string): TwiddlEnv =
  ## Opens a twiddl environment
  result.path = path
  result.twiddlfile = readTwiddlfile(path / "twiddlfile")
  result.buildsPath = path / ".twiddl" / "builds"
  result.artifactsPath = path / ".twiddl" / "artifacts"
  result.logsPath = path / ".twiddl" / "logs"

  # Create dirs if necessary
  createDir(result.buildsPath)
  createDir(result.artifactsPath)
  createDir(result.logsPath)

  result.builds = openBuilds(result.buildsPath)
