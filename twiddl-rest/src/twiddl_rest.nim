import asynchttpserver, asyncdispatch

proc requestHandler(req:Request) {.async.} =
  await req.respond(Http200, "asdf")

when isMainModule:
  var server = newAsyncHttpServer()
  waitFor server.serve(Port(8080), requestHandler)
