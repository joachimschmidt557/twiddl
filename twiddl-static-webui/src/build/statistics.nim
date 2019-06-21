import ropes

import ../twiddl

proc buildStatistics*(tw:TwiddlEnv): string =
  const
    header = slurp("common-header.html")
    footer = slurp("common-footer.html")
  var result = rope()
  result.add(header)
  result.add("<h1>Statistics</h1>\n")
  result.add(footer)
  return $result
