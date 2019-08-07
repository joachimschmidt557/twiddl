import unittest, os

import twiddl
import twiddl/runners

test "run empty job":
  var env = openTwiddlEnv(".")
  let job = Job(name: "Job",
                runner: "unsupervised",
                commands: @[],
                artifacts: @[])
  var b = newBuild(env, job)
  env.runBuild(b)

test "run simple file write job":
  var env = openTwiddlEnv(".")
  let job = Job(name: "Job",
                runner: "unsupervised",
                commands: @["echo asdf > file"],
                artifacts: @["file"])
  var b = newBuild(env, job)
  env.runBuild(b)
