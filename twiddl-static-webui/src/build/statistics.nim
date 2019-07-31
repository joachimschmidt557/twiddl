import ropes

import ../twiddl

proc buildStatistics*(tw:TwiddlEnv): string =
  const
    header = slurp("common-header.html")
    footer = slurp("common-footer.html")
  var result = rope()
  result.add(header)

  result.add("<h1>Statistics</h1>\n")
  result.addf("Total number of builds: $1 \n", [tw.builds.len.rope])
  result.add("<h2>Success rate</h2>\n")

  result.add("<h2>Past 30 days</h2>\n")

  result.add(footer)

  return $result
