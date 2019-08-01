import twiddl

type Runner* = ref object
  ## A runner is an implementation of this
  ## interface. It provides procedures
  ## for starting new builds, canceling builds
  ## and querying running builds
  runBuild*: proc (build: var Build): void
  cancelBuild*: proc (build: var Build): void
  listRunningBuilds*: proc (): seq[Build]

#
# Procedures which can be applied to any runner
#

proc newBuild(j:Job): Build =
  result.job = j
  result.status = bsPlanned
  result.saveBuildFile()

proc rerunBuild(r:Runner, b:Build) =
  var newBuild = newBuild(b.job)
  r.runBuild(newBuild)
