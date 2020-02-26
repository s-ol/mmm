# alivecoding: <mmm-embed wrap="raw" facet="description"></mmm-embed>
peristant expressions are an approach to livecoding that unifies direct
manipulation of a dataflow engine with a textual representation and
lisp-based programming language.

<mmm-embed wrap="raw" path="demo"></mmm-embed>

## shortcomings of repl-based programming
in repl-based environments, a scratch file is opened in a text editor. in it,
commands are staged and can be added, removed and edited without consequence.
the livecoding system generally has no knowledge about this scratch buffer at
all. the user is free to select and send individual commands (or groups of
commands) at any time and execute them by transmitting them to the server via
an editor plugin.

commands are incremental changes (deltas) that get sent to the server, which
keeps an entirely separate and invisible model of the project. generally no
feedback about the state of this model is made available to the user.

code is only executed when the user evaluates a block, although code run in
this fashion may cause other code to execute outside of the user-evaluated
execution flow via side effects, for example by registering a handler for
events such as incoming messages or scheduling execution based on system time.
these mechanisms however are implementation details within the code the user
executed originally, and no uniform mechanism for noticing, visualizing or
undoing these side-effects exists.

this design has the following consequences:

- the view of the scratch buffer is not correlated with the code and state the
  server is currently executing. this results in overhead for keeping the
  mental synchronized with what the system is actually performing for the user,
  but also makes it much harder for the audience to follow along.
- sessions cannot be reopened reliably, because the state of the server depends
  on the full sequence of commands that were sent to the server in order, which
  is not represented in the scratch buffer.
- if parts of the execution model on the server have not been explicitly
  labelled (i.e. assigned to a variable) in the textual representation, often
  many potentially important actions for modifying the current behaviour are
  unavailable: for example long-running sounds may not be cancellable, effects'
  parameters may not be adjustable without recreating the signal chain, etc.

## persistent expressions
the *persistent expression* paradigm, on the other hand, reconciles the user-
facing, text-based representation of the system and the server-internal model 
and execution flow.

### execution flow
code execution happens in two different phases alternatingly: at *eval-time*,
whenever the buffer is (re)evaluated; and at *run-time*, continuously between
evaluations.

at *eval-time*, execution is analogous to common functional and lisp-style
languages. expressions are evaluated depth-first starting from the root.
for each expression, the head of the expression is first evaluated, and
depending on the type of that subexpression different actions are taken. in the
general case, the head of an expression is an *op* (operator) type, an instance
of which will continue to run at *run-time*. in this case, all other arguments
are then evaluated and passed to the *op* instance, which is either created or
reused (see below).
on the other hand, some expressions (for example `def`, `use`, ...) do not
execute at *run-time*, but cause *eval-time* side-effects like declaring a
symbol in the active scope. because *eval-time* execution only happens once and
in a deterministic order, and no *eval-time* state persists across evaluations,
despite these side-effects, the *eval-time* execution is equivalent to 
functionally pure execution with an implicit scope parameter.

unlike normal lisps, when evaluating expressions, not only a value is
generated. in parallel to the tree of return values, a tree of *run-time*
dependencies is built, that tracks all instantiated *op*s and their inputs.

at *run-time*, *op* instances update based on this dependency tree. starting
from a periodic root event polled by the interpreter, dependent *op*s are
executed (following the outside-in, depth-first order that the dependencies have
been created in at *eval-time*). *op*s whose inputs are unchanged and 'pure'
subtrees that do not have any dependency on the root event are not executed.
in this way, the *run-time* behaviour of the system is that of a event-driven
dataflow language with clearly defined execution flow.

### expression tagging
in order to maintain the congruency between the representations across edits
and reevaluations, the identity of individual expressions is tracked using
tags. tags are noted using unique numbers in square brackets before the head of
expressions (e.g. `([1]head arg1 arg2...)`) and are optional when parsed.

at *eval-time* (see below), every expression that is not tagged will be
assigned a new unique tag number. 'cloned' expressions, such as the expressions
from a function definition body, are assigned composite tags that can be noted
as a list of tags joined by periods (e.g. `[2.1]`):

```
([1]defn add-two-and-multiply (a b)
  ([2]mul b ([3]add a 2)))

([4]add-two-and-multiply 1 2)
([5]add-two-and-multiply 3 4)
```

will be expanded (at *eval-time*) to approximately<span class="sidenote">
the actual implementation does not actually create sub expressions as shown
here, but the results behave equivalently.</span>:

```
(do
  (def a 1
       b 2)
  ([4.2]mul a ([4.3]add b 2)))
(do
  (def a 3
       b 4)
  ([5.2]mul a ([5.3]add b 2)))
```

the expression tags are used to associate the *run-time* representations (*op*
instances) of expressions with their textual representations, and track their
identity as the user changes the code. when the code is evaluated, *op*s are
instantiated whenever the expression was previously untagged, or when the head
of the expression no longer resolves to the same value. otherwise, the previous
*op* instance continues to exist and parameter changes are forward to it. *op*s
that are no longer referenced in the code are destroyed.

### benefits
this approach combines the benefits of dataflow programming for livecoding with
those of a textual representation and the user-controlled evaluation moment.

dataflow:

- direct manipulation of individual parameters of a system without disturbing
  the system at large
- execution and dataflow are aligned and evident in the editable representation
- state is isolated and compartmentalized in locally 
- opportunity to visualize dataflow and local state<span class="sidenote">
  visualizing state of individual *op*s in editor-dependent and editor-agnostic
  ways that integrate with the textual representation is an ongoing research
  direction of this project</span>

textual representation and user-controlled evaluation moment:

- high information density
- fast editing experience
- accessibility and editability from a wide range of tools (any text editor)
- ability to harness powerful meta-programming facilities (from Lisp)
- complex changes can be made without intermittently disrupting the system
