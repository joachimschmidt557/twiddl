import os

type
  TwiddlEnv* = object
    path*:string
    twiddlfile*:Twiddlfile
    builds*:seq[Build]
  Twiddlfile* = object
    path*:string

  BuildStatus* = enum
    bsPlanned,
    bsPending,
    bsRunning,
    bsFinished

  Build* = object
    id*:int
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

proc openTwiddlEnv*(path:string): TwiddlEnv =
  result.path = path
  result.twiddlfile = readTwiddlfile(path / "twiddlfile")
  discard
