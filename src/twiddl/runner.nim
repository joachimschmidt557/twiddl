import twiddl

type
  Runner* = object
    ## A runner is an implementation of this
    ## interface. It provides procedures
    ## for starting new builds, canceling builds
    ## and querying running builds
    runBuild*: proc (env: TwiddlEnv, build: var Build): void
    cancelBuild*: proc (env: TwiddlEnv, build: var Build): void
    listRunningBuilds*: proc (): seq[Build]
