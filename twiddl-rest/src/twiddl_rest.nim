import asynchttpserver, asyncdispatch
import osproc

import apiv1

proc requestHandler(req:Request) {.async.} =
  if req.url.path == "/test":
    await req.respond(Http200, "asdf")
  if req.url.path == "/trigger-make":
    await req.respond(Http200, "Triggered make")
    discard execCmd("make")
  else:
    await req.respond(Http404, "Not a valid API call")

when isMainModule:
  var server = newAsyncHttpServer()
  waitFor server.serve(Port(8080), requestHandler)
