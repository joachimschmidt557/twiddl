import twiddl

type
  Runner* = object
    ## A runner is an implementation of this
    ## interface. It provides procedures
    ## for starting new builds, canceling builds
    ## and querying running builds
    runBuild*: proc (build: var Build): void
    cancelBuild*: proc (build: var Build): void
    listRunningBuilds*: proc (): seq[Build]
