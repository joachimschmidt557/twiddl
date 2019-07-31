import twiddl

type Runner* = ref object
  runBuild*: proc (build: var Build): void
  cancelBuild*: proc (build: var Build): void
  listRunningBuilds*: proc (): seq[Build]
