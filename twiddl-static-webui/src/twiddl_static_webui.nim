import os

import twiddl

import build/index
import build/build_view
import build/list_view

proc build(path:string) =
  let tw = openTwiddlEnv(path)
  echo buildIndex(tw)
  echo buildListView(tw)
  for build in tw.builds:
    echo buildBuildView(build)

when isMainModule:
  build(getCurrentDir())
