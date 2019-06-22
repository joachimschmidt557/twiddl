import ropes

import ../twiddl

proc buildListView*(tw:TwiddlEnv):string =
  const
    header = slurp("common-header.html")
    footer = slurp("common-footer.html")
  var result = rope()
  result.add(header)

  result.add("<h1>All builds</h1>\n")
  if tw.builds.len > 0:
    result.add("<table>\n")

    result.add("<tr>\n")
    result.add("<th>ID</th> <th>Status</th> <th>Comment</th>\n")
    result.add("</tr>\n")

    for i in countdown(tw.builds.high, tw.builds.low):
      let build = tw.builds[i]
      result.add("<tr>\n")
      result.addf("<td><a href=\"builds/$1.html\">$1</a></td>", [rope($build.id)])
      result.addf("<td>$1</td>", [rope($build.status)])
      result.addf("<td>$1</td>", [rope($build.comment)])
      result.add("</tr>\n")

    result.add("</table>\n")
  else:
    result.add("No builds yet!\n")

  result.add(footer)
  return $result
