if exists('g:loaded_repl_nvim')
  finish
endif
let g:loaded_repl_nvim = 1

command! -bar -nargs=1 ReplOpen call repl#open(<q-args>) | call repl#map_keys()
command! -nargs=1 ReplSendln call repl#sendln(<q-args>)
