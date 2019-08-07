## Procedures which can be applied to any runner
import options

import twiddl

import twiddl/runner
import twiddl/builtin

proc genNewBuildId*(env:TwiddlEnv): int =
  ## Generates a new build ID
  env.builds.len

proc newBuild*(env:TwiddlEnv, j:Job): Build =
  ## Creates a new build from this job
  result.id = env.genNewBuildId
  result.job = j
  result.status = bsPlanned
  result.saveBuildFile()

proc runBuild*(env:Twiddlenv, b:var Build) =
  ## Selects the appropriate runner
  ## ands instructs that runner to run this
  ## build
  let r = matchRunner(b.job.runner)
  if r.isSome:
    r.get.runBuild(env, b)
  else:
    b.status = bsFinishedFailed
    b.comment = "Failed: No matching runner found.\n" & b.comment
    b.saveBuildFile()

proc rerunBuild*(env:Twiddlenv, b:Build) =
  ## Creates a new build with the same
  ## configuration and runs it
  var newB = newBuild(env, b.job)
  runBuild(env, newB)
