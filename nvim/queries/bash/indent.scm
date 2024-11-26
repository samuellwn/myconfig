;; @!os:unix
;; @!install:644:$HOME/.config/nvim/queries/bash/indent.scm

([
  (subshell)
  "{"
  "["
  "(("
  "[["
  (do_group)
  (case_statement)
  (case_item)
  (if_statement)
  "then"
  (array)
  (expansion)
  (command_substitution)
  (arithmetic_expansion)
  (process_substitution)
] @indent.begin (#set! indent.immediate 1))

([
  "}"
  "]"
  "))"
  "]]"
  "done"
  "esac"
  ";;"
  ";&"
  ";;&"
  "elif"
  (elif_clause)
  "else"
  (else_clause)
] @indent.branch (#set! indent.immediate 1))

[
  "}"
  "]"
  "))"
  "]]"
  "done"
  "esac"
  ";;"
  ";&"
  ";;&"
  "fi"
] @indent.end

;; case_item contains ")", so we can't just include it in the general @indent blocks
(subshell ")" @indent.branch)
(subshell ")" @indent.end)
(array ")" @indent.branch)
(array ")" @indent.end)
(command_substitution ")" @indent.branch)
(command_substitution ")" @indent.end)
(process_substitution ")" @indent.branch)
(process_substitution ")" @indent.end)

(command_substitution "`" @indent.branch)
(command_substitution "`" @indent.end)

(comment) @indent.ignore
(heredoc_body) @indent.ignore
