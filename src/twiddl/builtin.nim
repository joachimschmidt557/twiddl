import options

import twiddl
import twiddl/runner
import twiddl/unsupervised
import twiddl/lxc

proc matchRunner*(str:string): Option[Runner] =
  case str
  of "unsupervised": some unsupervisedRunner
  of "lxc": some lxcRunner
  else: none Runner
