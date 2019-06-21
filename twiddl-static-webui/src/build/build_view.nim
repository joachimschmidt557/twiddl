import ropes

import ../twiddl

proc buildBuildView*(b:Build):string =
  const
    header = slurp("common-header.html")
    footer = slurp("common-footer.html")
  var result = rope()
  result.add(header)
  result.addf("<h1>Build $1</h1>", [rope(b.id)])
  result.add(footer)
  return $result
