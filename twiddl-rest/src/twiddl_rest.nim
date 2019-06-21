import asynchttpserver, asyncdispatch
import osproc, strutils

import apiv1

proc requestHandler(req:Request) {.async.} =
  if req.url.path.startswith("/v1"):
    apiv1.requestHandler(req)
  else:
    await req.respond(Http404, "Not a valid API call")

when isMainModule:
  var server = newAsyncHttpServer()
  waitFor server.serve(Port(8080), requestHandler)
