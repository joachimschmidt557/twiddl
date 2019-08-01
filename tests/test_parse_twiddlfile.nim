import unittest, os

import twiddl

test "parse twiddl's twiddlfile":
  let env = openTwiddlEnv("..")

test "open twiddl's twiddlfile and then save it again":
  let contentBefore = readFile(".." / "twiddlfile")
  
  let env = openTwiddlEnv("..")
  env.twiddlfile.saveTwiddlfile()

  writeFile(".." / "twiddlfile", contentBefore)
