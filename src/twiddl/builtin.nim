import options

import twiddl
import twiddl/runner
import twiddl/unsupervised

proc matchRunner*(str:string): Option[Runner] =
  case str
  of "unsupervised": some unsupervisedRunner
  else: none Runner
