import unittest, os

import twiddl
import twiddl/[runners, unsupervised]

test "run empty job":
  let job = Job(name: "Job",
                runner: "unsupervised",
                commands: @[],
                artifacts: @[])
