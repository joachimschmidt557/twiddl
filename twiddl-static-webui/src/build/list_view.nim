import ropes

import ../twiddl

proc buildListView*(tw:TwiddlEnv):string =
  const
    header = slurp("common-header.html")
    footer = slurp("common-footer.html")
  var result = rope()
  result.add(header)
  result.add("<h1>All builds</h1>\n")
  result.add(footer)
  return $result
