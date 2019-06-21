import ropes

import ../twiddl

proc buildIndex*(tw:TwiddlEnv): string =
  const
    header = slurp("common-header.html")
    footer = slurp("common-footer.html")
  var result = rope()
  result.add(header)
  result.add("<h1>Latest build</h1>\n")
  result.add("<h1>Latest builds</h1>\n")
  for build in tw.builds:
    discard
  result.add(footer)
  return $result
