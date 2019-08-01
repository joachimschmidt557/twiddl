import htmlgen, ropes

import ../twiddl

proc buildIndex*(tw:TwiddlEnv): string =
  const
    header = slurp("common-header.html")
    footer = slurp("common-footer.html")
  var result = rope()
  result.add(header)

  result.add(h1("Latest build"))
  if tw.builds.len > 0:
    let latestBuild = tw.builds[tw.builds.high]
  else:
    result.add("No builds yet!\n")

  result.add(h1("Latest builds\n"))
  if tw.builds.len > 0:
    for build in tw.builds:
      discard
  else:
    result.add("No builds yet!\n")

  result.add(footer)
  return $result
