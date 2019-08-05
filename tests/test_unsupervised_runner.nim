import unittest, os

import twiddl
import twiddl/runners

test "run empty job":
  let job = Job(name: "Job",
                runner: "unsupervised",
                commands: @[],
                artifacts: @[])
