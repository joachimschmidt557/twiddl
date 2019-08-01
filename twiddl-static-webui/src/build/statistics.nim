import htmlgen, ropes

import ../twiddl

proc buildStatistics*(tw:TwiddlEnv): string =
  const
    header = slurp("common-header.html")
    footer = slurp("common-footer.html")
  var result = rope()
  result.add(header)

  result.add(h1("Statistics"))
  result.addf("Total number of builds: $1 \n", [tw.builds.len.rope])
  result.add(h2("Success rate"))

  result.add(h2("Past 30 days"))

  result.add(footer)

  return $result
